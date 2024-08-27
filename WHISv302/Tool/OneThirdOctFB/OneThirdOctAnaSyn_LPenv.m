%
%   Lowpass envelope using  OneThird Oct Filterbank
%   Irino T.,
%   Created:   2 Sep 2021  % from OneThirdOctAnaSyn
%   Modified:   2 Sep 2021 % 
%   Modified:  26 Sep 2021 % downsampling of envelope
%
%
function [SndSyn, FBoct3Mod, ParamOct3] = OneThirdOctAnaSyn_LPenv(Snd,ParamOct3)

disp(['### ' mfilename ' ###'])

if isfield(ParamOct3,'fs') == 0
    ParamOct3.fs = 48000;  % better than 44100
end

ParamOct3.fsEnv = 2000; % fs envelop should be as low as possible for definition of LPF

if isfield(ParamOct3,'FreqRange') == 0
    ParamOct3.FreqRange = [100 13000]; % 100-12500Hz
end
if isfield(ParamOct3,'StrNorm') ==0
    ParamOct3.StrNorm = 'Normlize2InputSnd';
end
if isfield(ParamOct3,'LPFfc') == 0
    ParamOct3.LPFfc = 16;
end
if isfield(ParamOct3,'LPForder') == 0
    ParamOct3.LPForder = 2;
end


[bzLP, apLP] = butter(ParamOct3.LPForder,ParamOct3.LPFfc/(ParamOct3.fsEnv/2));  % modulation cutoff
StrModify = ['Lowpass filter, fcMod = ' int2str(ParamOct3.LPFfc) ' (Hz)'];
disp([ ' ---  Modification: ' StrModify ' ---']);

%% %%%%%
% Analysis
%%%%%%%
[FBoct3, FBoct3DlyCmp, PwrdB, ParamOct3] = OneThirdOctFB(Snd,ParamOct3);

%% %%%%%%%%%%%%%%%
% Modification/Synthesis processing
%%%%%%%%%%%%%%%%%
[LenOct3, LenSnd] = size(FBoct3DlyCmp);
FBoct3Mod = zeros(LenOct3,LenSnd);

for nf = 1:LenOct3
    %% Ana
    Fout = FBoct3DlyCmp(nf,:); % compensatedの方で計算
    FoutAmp = abs(hilbert(Fout));
    FoutPhs   = angle(hilbert(Fout));
    
    %% Mod Lowpass filtering
    ModEnv = resample(FoutAmp,ParamOct3.fsEnv,ParamOct3.fs); 
    ModEnvLP = filter(bzLP,apLP,ModEnv);
    FoutAmpMod1 = resample(ModEnvLP,ParamOct3.fs,ParamOct3.fsEnv);
    LenMod = length(FoutAmpMod1);
    FoutAmpMod = [FoutAmpMod1(1:min(LenSnd,LenMod)), zeros(1,LenSnd-LenMod)];
    
    %% Synth %%%%
    FoutSyn = real(FoutAmpMod.*exp(j*FoutPhs));  %　resampleせずにAmpが同じなら完全にもどることを確認
    FBoct3Mod(nf,:)= FoutSyn;
    
    % ErrdB(nf) =  10*log10(mean((Fout-FoutSyn).^2)/mean(Fout.^2));
end
SndSyn0 = mean(FBoct3Mod);

ParamOct3.AmpNorm = ParamOct3.GainAnaSyn; % simple ana/synのレベル
if strcmp(ParamOct3.StrNorm,'Normlize2InputSnd') == 1
    ParamOct3.AmpNorm =  rms(Snd)/rms(SndSyn0);
end

SndSyn = ParamOct3.AmpNorm*SndSyn0;

return

%% %%%%%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%%%%%

% このバージョンでは、やれない。入れない方が間違いないと思われる。
% ParamOct3.FcShiftRatio = 1; % 通常シフトなし
% if isfield(ParamOct3,'SwShiftOct6') == 1 && ParamOct3.SwShiftOct6 == 1   % Fcを1/6octをずらす場合
%     ParamOct3.FcShiftRatio = 2^(1/6); % 1/6octシフト
%     disp(' ---   1/6 Octave shift of center frequency ---');
% end;
% if ParamOct3.FcShiftRatio ~= 1
%     ParamOct3.FcList = ParamOct3.FcList*ParamOct3.FcShiftRatio; % シフトも含め
%     ParamOct3.FcLabel = round(ParamOct3.FcLabel*ParamOct3.FcShiftRatio);  % これも一応変更
% end;


% ParamOct3.NumRange = find(ParamOct3.FcLabel >=  min(ParamOct3.FreqRange) & ...
%     ParamOct3.FcLabel <=  max(ParamOct3.FreqRange) );
% if isfield(ParamOct3,'SwCombReduction') == 1
%     %わざと１つ飛ばしにしてみる --   櫛形に削減
%     ParamOct3.NumRange = min(ParamOct3.NumRange):2:max(ParamOct3.NumRange);
% end
% ParamOct3.FcLabel = ParamOct3.FcLabel(ParamOct3.NumRange);
% ParamOct3.FcList    = ParamOct3.FcList(ParamOct3.NumRange);
% 
% FBoct3 = FBoct3(ParamOct3.NumRange,:);
% FBoct3DlyCmp = FBoct3DlyCmp(ParamOct3.NumRange,:);


% 48kHzに対して、16Hzのフィルタは作れない。
% resamplingして、16 Hzか。
%　modulation のサンプリング周波数の定義 --- GCFBと同じにしておこう。
% ParamOct3.fsMod = 100;
% [bzLP, apLP] = butter(2,ParamOct3.LPFfc/(ParamOct3.fsMod/2));  % modulation cutoff
% ParamOct3.LPFfc
%         if 0 resample する必要なし
%             EnvAmp = resample(FoutAmp,ParamOct3.fsMod,ParamOct3.fs); % downsampling
%             EnvAmpMod = filter(bzLP,apLP,EnvAmp); % LPF
%             FoutAmpMod1 = resample(EnvAmpMod,ParamOct3.fs,ParamOct3.fsMod); % upsampling
%             Len0 = length(FoutAmp);  Len1 = length(FoutAmpMod1);
%             [Len0 Len1]
%             FoutAmpMod = [FoutAmpMod1(1:min(Len0,Len1))  zeros(1,Len0-Len1)];
%         end
% 20*log10(rms(FoutAmpMod-FoutAmp)/rms(FoutAmp))



%         % あまり意味のある変形はないので、とりあえず使わない。
%         if 0      % 様々な変形を試してみる。
%             if ParamOct3.SwModify == 2
%                 StrModify = 'Add constant';
%                 FoutAmpMod = FoutAmp*0.1 + mean(FoutAmp)*ones(1,LenSnd); %  flat respose
%             elseif ParamOct3.SwModify == 3
%                 StrModify = 'Add randn';
%                 FoutAmpMod = FoutAmp*0.1 + 0.005*randn(1,LenSnd);
%                 %  まだwhite noise的なのでreallityとしては近い感じ。音声の質感を損なわない。単にSNRが悪くなった感じ。
%                 
%             elseif ParamOct3.SwModify == 4
%                 StrModify = 'Lowpass+SS';
%                 CoefSS = 0.8;
%                 CoefSS = 1;
%                 CoefReduct = 1; % --- これ意味ない気がする。 CoeffSSと分離すると制御は難しい。
%                 FoutAmp = filter(bzLP,apLP,FoutAmp);
%                 RmsFoutAmp = sqrt(mean(FoutAmp.^2));
%                 FoutAmp= max(CoefReduct * FoutAmp- CoefReduct*CoefSS*RmsFoutAmp,0); % Spec subtraction
%                 RmsFoutAmp2 = sqrt(mean(FoutAmp.^2));
%                 ReductiondB2(nf) = 20*log10(RmsFoutAmp2/RmsFoutAmp);
%                 % SSをいれることにより、余計な残響音的なものは消えるので良いかも。
%                 % ReductiondB は、-3から-8dB程度なので、これも使える気がする。
%                 % sin波をいれると、他の成分が若干でるが、mainを歪ませるほどではない。
%                 FoutAmpMod = FoutAmp* RmsFoutAmp0/RmsFoutAmp2; % 表現は元と同じrms値で出力--> audiogramに影響が出ないよう
%                 RmsFoutAmp3 = sqrt(mean(FoutAmpMod.^2));
%                 ReductiondB3(nf) = 20*log10(RmsFoutAmp3/RmsFoutAmp);
%                 
%                 %結局、もとに倍数でもどすので、modulation depthが戻る--- enhanceにすらなる。
%                 % modulation depth ---もう一度見ること
%                 %  --->   depth reductionについては、あきらめるしかないか。
%                 
%             elseif ParamOct3.SwModify == 5
%                 StrModify = 'SS';
%                 MeanFoutAmp = mean(FoutAmp);
%                 FoutAmp = FoutAmp*0.1 + MeanFoutAmp*ones(1,LenSnd); % modulation depthを減少
%                 FoutAmpMod= max(FoutAmp- MeanFoutAmp*1.1,0); % Spec subtraction
%                 % あまり音の変化なし。modulation depthをこのようにして変えるのは難しい
%             end
%         end
        