%
%      DTVF of WHIS: Wadai Hearing Impairment Simulator v300
%      IRINO T.
%      Created:   20 Oct  21  Separeted from the main body WHISv300
%      Modified:  20 Oct  21 
%
%

%% ������%%%%%%%%
%  Filterbank analysis 
%%%%%%%%%%%%
[NumCh, LenFrame] = size(dcGCframeHL);
for nch = 1:NumCh
    Fr1query = GCparamHL.Fr1(nch);
    % CompressionHealthNH = GCparamNH.HLoss.FB_CompressionHealth(nch);
    CompressionHealthNH = 1;
    CompressionHealthHL  = GCparamHL.HLoss.FB_CompressionHealth(nch);
    
    PindB_HL = GCrespHL.LvldBframe(nch,:);
    [dummy, IOfuncdB_HL] = GCFBv231_AsymFuncInOut(GCparamHL,GCrespHL, Fr1query, CompressionHealthHL,PindB_HL);
    PindB_NH = GCFBv231_AsymFuncInOut_InvIOfunc(GCparamHL,GCrespHL, Fr1query, CompressionHealthNH,IOfuncdB_HL);
    GainReductdB_OHC(nch,:) = -(PindB_HL - PindB_NH);         % < 0  OHC  negative

end
GainReductdB_IHC = -GCparamHL.HLoss.FB_PinLossdB_IHC*ones(1,LenFrame);         % < 0  IHC  negative
% gain reduction total gain
GainReductdB = GainReductdB_OHC + GainReductdB_IHC; % < 0 negative

%% Filterbank �ʑ��Y���␳
DCparam.fs = GCparamHL.DynHPAF.fs; % frame-base��sampling freq
[GainReductdB_Dcmpnst, DCparam]  = GCFBv231_DelayCmpnst(GainReductdB,GCparamHL,DCparam);
GainReductdB = GainReductdB_Dcmpnst;

if WHISparam.SwPlot == 1
    %% plot %%%%%%
    figure(10); clf;
    nchAll = 1:100;
    GainRdB = mean(GainReductdB_OHC);
    tFrame = (0:length(GainRdB)-1)/2000;
    subplot(4,1,1)
    plot((0:length(SrcSnd)-1)/fs,SrcSnd*100 + mean(GainRdB),tFrame,GainRdB);
    subplot(4,1,2)
    imagesc(GainReductdB_OHC*(-1));
    set(gca,'YDir','normal');
    subplot(4,1,3)
    %imagesc(GainReductdB_Dcmpnst*(-1));
    %set(gca,'YDir','normal');
    plot(nchAll, mean(GCrespHL.LvldBframe,2)); 
    subplot(4,1,4)
    plot(nchAll, mean(GainReductdB,2), nchAll,mean(GainReductdB_OHC,2),'--',nchAll,mean(GainReductdB_IHC,2),'-.') 
    
 end

% down sampling��GCFB���v�Z���Ă���ꍇ�A����fs�ɖ߂��K�v����B
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
[SndHLoss, WHISparam] = WHISv300_DirectTVF(SrcSnd,WHISparam);
SndOut = SndHLoss;

tElps(2) = toc;
disp(['Elapsed time is ' num2str(tElps(2),4) ' (sec) = ' num2str(tElps(2)/Tsnd,4) ' times RealTime.']);


%% %%%%%%%%%%%
%   Envelope modulation loss�͂����ɓ����B�@�����x���ł̏����B
%%%%%%%%%
if isfield(WHISparam,'EMLoss')== 1 && isfield(WHISparam.EMLoss, 'LPFfc')== 1
    disp('----  Envelope modulation loss  ----');
    ParamOct3.LPFfc = WHISparam.EMLoss.LPFfc; % 8,  16; % 256=16*16;
    ParamOct3.LPForder = WHISparam.EMLoss.LPForder;
    [SndEMLoss, FBoct3Mod, ParamOct3] = OneThirdOctAnaSyn_LPenv(SndHLoss,ParamOct3);
    SndOut = SndEMLoss;
end

return

%% %%%%%%%%%%%%
%  Trash
%%%%%%%%%%%%%%%
%% %%%%
% DTVF�ŁAGCparam.OutMidCrct �̕␳�͕K�v�Ȃ��I�@�@�@���ړ��͐M����filtering���Ă���̂ŁB�@25 Oct 21
%%%%
% if strcmp(GCparam.OutMidCrct,'No') == 0   % �␳���Ă����炻�̕����t�t�B���^
%     % InvCmpnOutMid = OutMidCrctFilt(GCparam.OutMidCrct,fs,0,1); %FIR linear phase inverse filter
%     InvCmpnOutMid = MkFilterField2Cochlea(GCparam.OutMidCrct,fs,-1); % Backward filter
%     SndTmp1 = filter(InvCmpnOutMid,1,SndOut);
%     20*log10([rms(SndOut) rms(SndTmp1)])
%     SndOut = SndTmp1;
%
%     �ȉ��̕␳�ł͑卷�Ȃ��B
%     ����ɕ␳�������ꍇ�B�@WHISv300fbas�ł́A�ȉ��͍s���Ă��Ȃ��B
%     nOrder = 5;
%     [bzLP,apLP] = butter(nOrder,1.2*GCparam.FRange(2)/(fs/2));  % 1.2*12kHz
%     SndTmp = filter(bzLP,apLP,SndTmp);
%     [bzHP,apHP] = butter(nOrder,0.8*GCparam.FRange(1)/(fs/2),'high'); % 0.8*100Hz
%     SndOut = filter(bzHP,apHP,SndTmp);
%
%
%% envelope lowpass filtering  -- �ȉ��͎g���Ȃ�
%%%%%%%%
%  HL Modulation Loss
%%%%%%%%
% if isfield(WHISparam,'EMLoss') == 1
%      EMframeHL = WHISv300_EnvModLoss(dcGCframeNH,GCparamHL,WHISparam);
% end
