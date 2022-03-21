%
%       FBAnaSyn of WHIS: Wadai Hearing Impairment Simulator v301
%       IRINO T.
%       Created:  20 Oct  2021 Separeted from the main body WHISv300
%       Modified:  20 Oct  2021 
%       Modified:   6  Mar 2022   WHISv300_func --> WHISv30_func, GCFBv231--> GCFBv232
%       Modified:  20 Mar 2022  v302  <--- GCFBv233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%
%

%% %%%%%%%%%%%
%   Envelope modulation loss設定。　FBレベルでの処理。
%%%%%%%%%
apLP=1;
bzLP=1;
SwEnvModLoss = 0;
if isfield(WHISparam,'EMLoss')== 1 && isfield(WHISparam.EMLoss, 'LPFfc')== 1
    SwEnvModLoss = 1;
    [bzLP, apLP] = butter(WHISparam.EMLoss.LPForder,WHISparam.EMLoss.LPFfc/(GCparamHL.DynHPAF.fs/2));  % modulation cutoff
    StrEMLoss = ['Envelop modulation LPF, fcMod = ' int2str(WHISparam.EMLoss.LPFfc) ' (Hz)'];
    disp(StrEMLoss);
end

%%　％％％%%%%%%%%
%  Filterbank analysis synthesis
%%%%%%%%%%%%
[NumCh, LenFrame] = size(dcGCframeHL);
for nch = 1:NumCh
    Fr1query = GCparamHL.Fr1(nch);
    % CompressionHealthNH = GCparamNH.HLoss.FB_CompressionHealth(nch);
    CompressionHealthNH = 1;
    CompressionHealthHL  = GCparamHL.HLoss.FB_CompressionHealth(nch);
    
    %%  %%%
    %  Peripheral Hearing Loss   HL_total = HL_ACT + HL_PAS
    %%%%%
    PindB_HL = GCrespHL.LvldBframe(nch,:);
    [dummy, IOfuncdB_HL] = GCFBv23_AsymFuncInOut(GCparamHL,GCrespHL, Fr1query, CompressionHealthHL,PindB_HL);
    PindB_NH = GCFBv23_AsymFuncInOut_InvIOfunc(GCparamHL,GCrespHL, Fr1query, CompressionHealthNH,IOfuncdB_HL);
    GainReductdB_ACT(nch,:) = -(PindB_HL - PindB_NH);         % < 0  ACT  negative

    GainReductdB_PAS(nch,:) = -GCparamHL.HLoss.FB_PinLossdB_PAS(nch)*ones(1,LenFrame);
    GainReductdB(nch,:) = GainReductdB_ACT(nch,:) + GainReductdB_PAS(nch,:);
    %dB上でのinterpolationの方が変化が小さいのでよさそう。ーーー　結果的にはあまりかわらない。
    GainReductdB_smpl = resample(GainReductdB(nch,:),GCparamHL.fs, GCparamHL.DynHPAF.fs);
    LenGRR = length(GainReductdB_smpl);
    GainReductdB_smpl = [GainReductdB_smpl(1:min(LenGRR,LenSnd)), zeros(1,LenSnd-LenGRR)]; 
    GainReductRatio_smpl = 10.^(GainReductdB_smpl/20);
    
    %% %%%%%
    % sample 点のgain重み付け
    %%%%%%%%
    % ＊　HIのsample値にgainをかける。　NHの特性をGCFBv231を求める必要なし。simple.　2021/10/10から
    scGC_smpl = GainReductRatio_smpl.*scGCsmplHL(nch,:);  
   
    %＊　OLD vesion 2021/10/9まで
    % NHのsample値にgainをかける　NHの特性をGCFBv231を求める必要がある。 
    % scGC_smpl = GainReductRatio_smpl.*scGCsmplNH(nch,:);
    %
    %  確認したところ、HLの特性でフィルタの違いは出るが、位相が若干ずれるだけ。
    %  scGCsmplHL(nch,:)から求めたもの振幅もほとんど同じ。　差分を取っても、ほぼ元の振幅になる。
    %  位相の違いしかないのであれば、以下の式を使った方が計算時間短縮になる。
    %  block diagramもシンプルになる。
    %
    
    if  SwEnvModLoss == 0
        % no modulation loss
        scGCmod(nch,:) = scGC_smpl;
    else
        %%  %%%
        %  Envelope Modulation Loss
        %%%%%%
        scGC_amp = abs(hilbert(scGC_smpl));
        scGC_phase = angle(hilbert(scGC_smpl));
        scGC_frame = resample(scGC_amp, GCparamHL.DynHPAF.fs,GCparamHL.fs);
        scGC_frame_mod = filter(bzLP, apLP,abs(scGC_frame));
        scGC_amp_mod  = resample(scGC_frame_mod,GCparamHL.fs, GCparamHL.DynHPAF.fs);
        LenSFM = length(scGC_amp_mod);
        scGC_amp_mod = [scGC_amp_mod(1:min(LenSFM,LenSnd)), zeros(1,LenSnd-LenSFM)];
        scGCmod(nch,:)  = real(scGC_amp_mod.*exp(j*scGC_phase));
    end
        
end

%% %%%%%%%%
% Synthesis
%%%%%%%%%%
DCparam.fs = GCparamHL.fs;   %　GCparamHLを使う：　fsや以下で使うGCparamNHの係数は同じなので。
[scGCmodDC] = GCFBv23_DelayCmpnst(scGCmod,GCparamHL,DCparam); %% Filterbank 位相ズレ補正
% GCparam.OutMidCrct の補正は必要。　
SndHLoss = GCFBv23_SynthSnd(scGCmodDC,GCparamHL);   % OutMidFilterの逆補正はここでしている。

% Level correction
SndOut =10^(-AmpdB(2)/20)*SndHLoss;  % Eqlz2MeddisHCLevelを補正

if WHISparam.SwPlot == 1
    %% plot %%%%%%
    figure(10); clf;
    nchAll = 1:100;
    GainRdB = mean(GainReductdB_ACT);
    tFrame = (0:length(GainRdB)-1)/2000;
    subplot(4,1,1)
    plot((0:length(SrcSnd)-1)/fs,SrcSnd*100 + mean(GainRdB),tFrame,GainRdB);
    subplot(4,1,2)
    imagesc(GainReductdB_ACT*(-1));
    set(gca,'YDir','normal');
    subplot(4,1,3)
    %imagesc(GainReductdB_Dcmpnst*(-1));
    %set(gca,'YDir','normal');
    plot(nchAll, mean(GCrespHL.LvldBframe,2)); 
    subplot(4,1,4)
    plot(nchAll, mean(GainReductdB,2), nchAll,mean(GainReductdB_ACT,2),'--',nchAll,mean(GainReductdB_PAS,2),'-.') 
    
 end

% down samplingでGCFBを計算している場合、元のfsに戻す必要あり。
if WHISparam.AllowDownSampling == 1
    disp(['Up-sampling for sound output: ' int2str(WHISparam.fs) ' --> ' int2str(WHISparam.fsOrig) ' Hz']) ;
    GainReductdBUp = zeros(NumCh,LenFrame*WHISparam.RateDownSampling);
    for nch = 1:GCparam.NumCh
        GainReductdBUp(nch,:) = resample(GainReductdB(nch,:),WHISparam.fsOrig,WHISparam.fs);
    end
    GainReductdB = GainReductdBUp;
    WHISparam.fs = WHISparam.fsOrig;
end

% WHISparam.GCparamNH = GCparamNH;
WHISparam.GCparamHL= GCparamHL;
WHISparam.GainReductdB = GainReductdB;

tElps(2) = toc;
disp(['Elapsed time is ' num2str(tElps(2),4) ' (sec) = ' num2str(tElps(2)/Tsnd,4) ' times RealTime.']);

return

