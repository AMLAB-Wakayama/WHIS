%
%       DTVF of WHIS: Wadai Hearing Impairment Simulator v300
%       IRINO T.
%       Created:  20 Oct  2021  Separeted from the main body WHISv300
%       Modified: 20 Oct  2021 
%       Modified:　6  Mar 2022   WHISv300_func --> WHISv30_func, GCFBv231--> GCFBv232
%       Modified: 20 Mar 2022  v302  <--- GCFBv233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%       Modified: 26 Mar 2022 ( LenShift+1--> LenShift 問題で、SimTimeVaryFilter_AnaSynを変更。こちらは変更なし。）
%
%

%% ％％％%%%%%%%%
%  Filterbank analysis 
%%%%%%%%%%%%
[NumCh, LenFrame] = size(dcGCframeHL);
for nch = 1:NumCh
    Fr1query = GCparamHL.Fr1(nch);
    % CompressionHealthNH = GCparamNH.HLoss.FB_CompressionHealth(nch);
    CompressionHealthNH = 1;
    CompressionHealthHL  = GCparamHL.HLoss.FB_CompressionHealth(nch);
    
    PindB_HL = GCrespHL.LvldBframe(nch,:);
    [dummy, IOfuncdB_HL] = GCFBv23_AsymFuncInOut(GCparamHL,GCrespHL, Fr1query, CompressionHealthHL,PindB_HL);
    PindB_NH = GCFBv23_AsymFuncInOut_InvIOfunc(GCparamHL,GCrespHL, Fr1query, CompressionHealthNH,IOfuncdB_HL);
    GainReductdB_ACT(nch,:) = -(PindB_HL - PindB_NH);         % < 0  ACT  negative

end
GainReductdB_PAS = -GCparamHL.HLoss.FB_PinLossdB_PAS*ones(1,LenFrame);         % < 0  PAS  negative
% gain reduction total gain
GainReductdB = GainReductdB_ACT + GainReductdB_PAS; % < 0 negative

%% Filterbank 位相ズレ補正
DCparam.fs = GCparamHL.DynHPAF.fs; % frame-baseのsampling freq
[GainReductdB_Dcmpnst, DCparam]  = GCFBv23_DelayCmpnst(GainReductdB,GCparamHL,DCparam);
GainReductdB = GainReductdB_Dcmpnst;

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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Direct Time-Varying  filtering  DTVF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WHISparam.GCparamNH = GCparamNH;
WHISparam.GCparamHL= GCparamHL;
WHISparam.GainReductdB = GainReductdB;
[SndHLoss, WHISparam] = WHISv30_DirectTVF(SrcSnd,WHISparam);
SndOut = SndHLoss;

tElps(2) = toc;
disp(['Elapsed time is ' num2str(tElps(2),4) ' (sec) = ' num2str(tElps(2)/Tsnd,4) ' times RealTime.']);


%% %%%%%%%%%%%
%   Envelope modulation lossはここに導入。　音レベルでの処理。
%%%%%%%%%
if isfield(WHISparam,'EMLoss')== 1 && isfield(WHISparam.EMLoss, 'LPFfc')== 1
    disp('----  Envelope modulation loss  ----');
    ParamOct3.LPFfc = WHISparam.EMLoss.LPFfc; % 8,  16; % 256=16*16;
    ParamOct3.LPForder = WHISparam.EMLoss.LPForder;
    [SndEMLoss, FBoct3Mod, ParamOct3] = OneThirdOctAnaSyn_LPenv(SndHLoss,ParamOct3);
    SndOut = SndEMLoss;
end

return

