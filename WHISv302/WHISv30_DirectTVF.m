%
%      WHIS: Wadai Hearing Impairment Simulator v300 --  Direct  Time-Varying Filter
%      IRINO T.
%       Created:   12 Aug 2021 from HIsimFastGC.m
%       Modified:   12 Aug 2021
%       Modified:   6  Mar 2022   WHISv300_func --> WHISv30_func 
%
%   function [SndOut, WHISparam] = _DirectTVF(SndIn, WHISparam);
%   INPUT:  SndIn : input sound
%                WHISparam: parameters
%   OUTPUT: SndOut: processed sound
%                  WHISparam: parameters
%
%
function [SndOut, WHISparam] = WHISv30_DirectTVF(SndIn, WHISparam)

SwPlot = 0;

GainReductdB = WHISparam.GainReductdB;
% RatioGainReduct = RatioGainReduct.^4; %%%%  このようにすると、音が歪む方向へ。　ーーー　filterbankとのズレがある様子

GCparam = WHISparam.GCparamHL;
[NumCh, LenFrameGC] = size(GainReductdB);

%% %%%%%%%%%%%%%%%%%%%%%%%
% Setup Analysis
%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(WHISparam,'TVFparam') == 1, TVFparam = WHISparam.TVFparam; end   % もし外部で定義していれば引き継ぐ
fs  = WHISparam.fs;
TVFparam.fs  = fs;
TVFparam.Ctrl = 'ana';
% TVFparam.Twin = 0.010; ずれる。default 0.020よりnoisyになるとも書いてある。
[~, WinFrame, TVFparam ] = SimTimeVaryFilter_AnaSyn(SndIn,[],TVFparam); % default ana

%% %%%%%
% convert  WHISparam.RatioGainReduct --> pwrAFG
%%%%%%%
%pwrAFG1 =(1/RatioGainReduct).^2;    % GainReduction を Gainに変換：　元のプログラムをそのまま使うため
% GCparam.DynHPAF.fs = 2000 Hz ---  0.5 (ms)
% TVFparam.Twin = 0.020;   % (sec) == 20 (ms) -- default  50 Hz
% TVFparam.Tshift  = TVFparam.Twin/2; % ms -- 10 (ms)  -- 100 Hz
%
TVFparam.fsShift = 1/TVFparam.Tshift;
GainReductdBTVF = zeros(NumCh,TVFparam.LenFrame);
fsRatio = GCparam.DynHPAF.fs/TVFparam.fsShift;

for nch = 1:NumCh
    % resampleを使うと、transientのリップルが生じる。ーー　NG
    % GainReductdBTVF_rsmpl(nch,:) = resample(GainReductdB(nch,:), TVFparam.fsShift,GCparam.DynHPAF.fs);
    FrameMtrx = SetFrame4TimeSequence(GainReductdB(nch,:),fsRatio*2,fsRatio);  % すこしoverlapがあった方が無難
    % GainReductdBTVF_mean(nch,:)= mean(Frame1); %
    WinWeight = hanning(fsRatio*2); %つなぎをなめらかにするため
    WinWeight = WinWeight(:)'/(mean(WinWeight)*fsRatio*2);
    FrameWin  = WinWeight*FrameMtrx;
    GainReductdBTVF(nch,1:length(FrameWin))= FrameWin;

    %     if rem(nch,20) == 0
    %         nch
    %         subplot(2,1,1)
    %         plot(GainReductdB(nch,:))
    %         subplot(2,1,2)
    %         nnn = 1:TVFparam.LenFrame;
    %         plot(nnn, GainReductdBTVF(nch,:),nnn,GainReductdBTVF_mean(nch,:),'-.',nnn,GainReductdBTVF_rsmpl(nch,:),'--')
    %         nch
    %     end
end
pwrAFG1 = 10.^(GainReductdBTVF/10);  % dB--> pwr

%%%%%%%%%%%
%% Filter setting & frequecy range
%%%%%%%%%%%
TVFparam.TresponseLength  = 0.004; % Nishi : koNnichiwaの場合0.004s(responseLength)までで十分？？
% TVFparam.TresponseLength  = 0.008; %NG 長いとかえって雑音が入る。Irino, 26Dec13
TVFparam.TresponseLength  = 0.010; % WHISv300 これで音色比較 24 Sep 21
TVFparam.Nfft   = 1024;  % with truncation it works.
freqBin = linspace(0,fs/2,TVFparam.Nfft/2+1); %  for linear power & minimum phase filter

% まず、GCFBの範囲は、GCparam.Fr1:  100 Hz ~ 10 kHz --> これをFFTの全帯域に広げる。
Fr1ExtL = [0:20:min(GCparam.Fr1)*0.99]';   % 0 ~ 80 Hzで連続的に上昇
pwrExtL = 2.^(Fr1ExtL(:)/max(Fr1ExtL)-1)*pwrAFG1(1,:); % +3dB/oct
Fr1ExtU = ((max(GCparam.Fr1)+500):500:fs/2)'; %
if isempty(Fr1ExtU)
    pwrExtU = [];
else
    pwrExtU = 2.^(-Fr1ExtU(:)/min(Fr1ExtU)+1)*pwrAFG1(end,:);  % -3dB/oct
end
FrAll  = [Fr1ExtL(:); GCparam.Fr1; Fr1ExtU(:)];
pwrAFG = [pwrExtL; pwrAFG1; pwrExtU];


%% %%%%%%%%%
% ２重filtering の実行
%　　　２重にかけるのはdynamic rangeを広げるため。計算上、あまり小さい係数は使えないため。
%%%%%%%%%%%%
disp('##### Minimum phase filtering #####');
WinFrameMod = zeros(size(WinFrame));
for nf = 1:TVFparam.LenFrame

    % Gain(Fr1) --> Gain(FFT bin)
    pwrSpec = exp(interp1(FrAll, log(pwrAFG(:,nf)),freqBin,'linear','extrap'));
    % pwrSpec  = CmpnstPwr.*pwrSpec1;   %%  ここで補正。12 Dec 2018 %%%%

    % double filtering with rms amp filter
    if nf==1, disp('--- Double AmpSpec Minimum phase filtering (default) ---'); end
    AmpSpec = sqrt(pwrSpec(:)); 
    % To make the dynamic range wider, double filtering is important. 
    % sqrt のfilterを使い、2回 filteringを行う。　これにより、Dynamic rangeを確保。
    FilterMinPhsFull      = PwrSpec2MinPhaseFilter(freqBin,AmpSpec,fs);  % function renamed 26 Oct 21
    FilterMinPhsHalf      = FilterMinPhsFull(1:ceil(TVFparam.TresponseLength*fs));
    tmpRsp                  = filter(FilterMinPhsHalf,1,WinFrame(:,nf));    % 1st filter  sufficiently fast ~= fftfilt
    WinFrameMod(:,nf) = filter(FilterMinPhsHalf,1,tmpRsp);               % 2nd filter
    % disp('OK double filtering');

    if SwPlot == 1
        subplot(3,1,2)
        plot(mpResponse);
        grid on;
        [frsp1, freq1] = freqz(mpResponse,1,TVFparam.Nfft/2,fs);

        subplot(3,1,3)
        semilogx(freqBin,10*log10(pwrSpec),freq1,20*log10(abs(frsp1)));
        grid on;
        %axis([50 20000 -30 20]);
        %pause(1)
    end

    if nf == 1 | rem(nf,50)==0
        disp(['Frame #' num2str(nf) ' / #' num2str(TVFparam.LenFrame)]);
        drawnow
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Synthesis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TVFparam.Ctrl = 'syn';
[SndOut, WinFrame, TVFparam ] = SimTimeVaryFilter_AnaSyn([],WinFrameMod,TVFparam);

WHISparam.TVFparam = TVFparam;
end


%% %%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%
    % previous version
    % mpResponse1      = powerSpectrum2minimumPhase(AmpSpec,fs)';
    % mpResponseHalf  = mpResponse1(1:ceil(TVFparam.TresponseLength*fs));
    % tmpRsp                   = filter(mpResponseHalf,1,WinFrame(:,nf));    % 1st filter  sufficiently fast ~= fftfilt
    % WinFrameMod(:,nf) = filter(mpResponseHalf,1,tmpRsp);                % 2nd filter
    % disp('OK double filtering');

% HIsimFastGCでは入っていたもの。実験的なものなので、ここでは不要。
%
%     if HISparam.SwMethodModSpec == 2,
%         if nf==1, warning('--- STFT modified amplitude + original phase [for comparion] --'); end;
%         FFTSpec      = fft(WinFrame(:,nf),HISparam.Nfft);
%         AmpModSpec1  = abs(FFTSpec(1:HISparam.Nfft/2+1)).*sqrt(pwrSpec(:)); % Signal x Filter
%         %NG: pwrSpec(:)/sqrt(mean(pwrSpec(:).^2))*sqrt(mean(AmpFFTSpec.^2));
%         AmpModSpec = [AmpModSpec1; flipud(AmpModSpec1(2:end-1))];
%         Rsp1 = ifft(AmpModSpec.*exp(j*angle(FFTSpec)));
%         if sqrt(mean(imag(Rsp1).^2))/sqrt(mean(real(Rsp1).^2)) > 100*eps,
%             error('Something wrong with FFT/IFFT');
%         end;
%         Rsp2 = real(Rsp1(1:length(WinFrame(:,nf))));
%         % compenate the level and override the results
%         AmpCmpnst = sqrt(mean(WinFrameMod(:,nf).^2))/sqrt(mean(Rsp2.^2));
%         WinFrameMod(:,nf) = AmpCmpnst*Rsp2;
%     end;
%     % filtering
%     %WinFrameMod(:,nf) = fftfilt(mpResponse,WinFrame(:,nf));

% if HISparam.SwMethodModSpec == 0, % single power filter
%     if nf== 1, disp('--- Original PwrSpec Minimum phase filtering ---'); end;
%     mpResponse1 = powerSpectrum2minimumPhase(pwrSpec(:),fs)';
%     mpResponse = mpResponse1(1:ceil(HISparam.TresponseLength*fs));
%     WinFrameMod(:,nf) = filter(mpResponse,1,WinFrame(:,nf));  % sufficiently fast ~= fftfilt
%
% elseif HISparam.SwMethodModSpec == 1     || HISparam.SwMethodModSpec == 2


% % WHISparam.Gain4CmpnstdBって、WHISv300では使わない気がする。
% if WHISparam.SwAmpCmpnst == 1,
%     CmpnstPwr = ones(size(WHISparam.FaudgramList));
% elseif WHISparam.SwAmpCmpnst == 2,
%     %% Gain の補正　Gain4Cmpnst   12 Dec 2018 %%%%%%%%%%%
%     LogFag         = log10(HISparam.FaudgramList); %対数上で線形補間。
%     LogfreqBin   = log10(max(freqBin,10));  % 0を避けるためmax(freqBin,10)
%     CmpnstPwr  = 10.^(interp1(LogFag, -WHISparam.Gain4CmpnstdB/10, LogfreqBin,'linear','extrap'));
%     % for check
%     %CmpnstPwr = 0.01*ones(size(CmpnstPwr));  %ちゃんと-20dB落ちる。Linear領域で掛けている
%     %%%  ここまで 12 Dec 2018  %%%%%%%%%%%
% end;

% 解消
% OK  良いが、v225よりも大きな音。
% pwrAFG1 = GainReductdBTVF.^3;  % test  --- たしかに小さくなるが、理由説明不可能。v225よりも低域が小さく、少々高域が大きい
% はて。悩みどころ



