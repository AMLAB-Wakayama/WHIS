%
%      WHIS: Wadai Hearing Impairment Simulator v300
%      IRINO T.
%      Created:     9 Feb  21 from HIsimFastGC.m
%      Modified:     9 Feb  21
%      Modified:   23 Feb 21  (OneThirdOctFB���p + TMTF lowpass)
%      Modified:   23 Feb 21  (GCFB ana/syn   + TMTF lowpass�ł�OneThirdOctFB���p)
%      Modified:    6 Mar  21  (GCFB ana/syn   + TMTF lowpass��S��GCFB�ŁB�[�[�@NG�ۂ�)%
%      Modified:   25 Jul  21  (HISparam --> WHISparam)
%      Modified:   12 Aug 21  (Qualty improvement using TimeVarying filter.)
%      Modified:   13 Aug 21  (debug WHISparam.fs)
%      Modified:   18 Aug 21  (debug using ReductdB_CmprsHlth & dB calculation)
%      Modified:    1 Sep 21   using GCFBv231
%      Modified:  10 Sep 21  
%      Modified:  26 Sep 21  EMLoss  (modified name WHISv300 --> WHISv300dtvf)
%      Modified:  20 Oct  21  ���ʕ������o�BWHISv300dtvf, WHISv300fabs�������ŕ��� -- control  GCparam
%      Modified:  26 Oct  21  introducing MkFilterField2Cochlea
%
%
%   function [SndOut, WHISparam] = WHISv300(SrcSnd, WHISparam);
%   INPUT:  SrcSnd : input sound
%           WHISparam: parameters
%   OUTPUT: SndOut: processed sound
%           WHISparam: parameters
%
%
function [SndOut, WHISparam] = WHISv300(SrcSnd, WHISparam)


disp(' ');
disp(['------------------ ' mfilename ' --------------------']);

if nargin < 1,
    str = ['help ' mfilename];
    eval(str);
end;
if nargin < 2, WHISparam = []; end;

%%%%%%%%
% Setting tool path
StartupWHIS 


%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Prameter settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(WHISparam,'fs') == 0, WHISparam.fs = 48000; end
nfs = find([48000, 24000] == WHISparam.fs);  % debug
if length(nfs) == 0
    error(['Sampling rate should be 48000 or 24000. --- No 44100 Hz nor other fs']);
    % frame-base�����ł́A44100�͂����Ƃ��܂������Ȃ��B
end
fs = WHISparam.fs;

% errors for specifying essential parameters 
if isfield(WHISparam.HLoss,'Type') == 0
     error(['Specify Type. (e.g. WHISparam.HLoss.Type = ''HL3'')']); % example ISO7029 70yr �j      --  HISparam.AudiogramNum
end
if isfield(WHISparam.HLoss,'CompressionHealth') == 0
     error(['Specify CompressionHealth.  (e.g. WHISparam.HLoss.CompressionHealth = 0.5)']); % Initial value of compression  --  HISparam.getComp
end
if isfield(WHISparam.CalibTone,'SPLdB') == 0
    error(['Specify CalibTone.SPLdB. (e.g. WHISparam.CalibTone.SPLdB = 80)']);
end
if isfield(WHISparam.SrcSnd,'SPLdB') == 0
    error(['Specify SrcSnd.SPLdB. (e.g. WHISparam.SrcSnd.SPLdB=65)']);
end

%
if isfield(WHISparam,'SwPlot') == 0  % plot OHC loss , IHC loss
    WHISparam.SwPlot = 0;
end

if isfield(WHISparam,'AllowDownSampling') == 0
    WHISparam.AllowDownSampling = 0;  % defualt�ł�down sampling ���Ȃ��B
end
if WHISparam.AllowDownSampling == 1
    WHISparam.RateDownSampling = 2;
    WHISparam.fsOrig = WHISparam.fs;
    WHISparam.fs = WHISparam.fsOrig/WHISparam.RateDownSampling;
    Snd4Ana = resample(SrcSnd,WHISparam.fs,WHISparam.fsOrig);
    disp(['Down-sampling for calculation: ' int2str(WHISparam.fsOrig) ...
        ' --> ' int2str(WHISparam.fs) ' Hz']) ;
else
    Snd4Ana = SrcSnd;
    WHISparam.AllowDownSampling = 0;
end

% GCparam  setting
GCparam = [];
if isfield(WHISparam,'GCparam') == 1 
    GCparam = WHISparam.GCparam; 
end

if isfield(GCparam,'fs') == 0,  GCparam.fs     = fs; 
else
    if GCparam.fs ~= WHISparam.fs
        error('GCparam.fs ~= WHISparam.fs')
    end
end

if isfield(GCparam,'NumCh') == 0,   GCparam.NumCh  = 100; end

if isfield(GCparam,'FRange') == 0
    GCparam.FRange = [100, 12000];
    if WHISparam.AllowDownSampling == 1 % quality may be degraded
        GCparam.FRange = [100, 8000];  % Upper limit
    end
end

if isfield(GCparam,'OutMidCrct') == 0
    % GCparam.OutMidCrct = 'ELC';  % also MAF/MAP is OK
    GCparam.OutMidCrct = 'FreeField'; % 25 Oct 2021
end
GCparam.Ctrl = 'dynamic';  % No other choice
GCparam.DynHPAF.StrPrc = 'frame-base'; % No other choice

WHISparam.GCparam = GCparam; % �߂��B

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GCFB  calculation of difference between NH and HI excitation pattern
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input level setting:  Normalized by Eqlz2MeddisHCLevel
[Snd4GCFB, AmpdB] = Eqlz2MeddisHCLevel(Snd4Ana,WHISparam.SrcSnd.SPLdB);
WHISparam.Eqlz2MeddisHCLevel_AmpdB = AmpdB;
Tsnd = (length(Snd4GCFB)/fs);

tic;
%%%%%%%%
%  NH GCframe
%%%%%%%%
% �v�Z����K�v�Ȃ��B
% GCparam.HLoss.Type = 'NH'; %����͂��Ȃ炸NH
% [dcGCframeNH, scGCsmplNH,GCparamNH,GCrespNH] = GCFBv231(Snd4GCFB,GCparam); 
% GCparamNH.HLoss.FB_CompressionHealth = ones(1,GCparam.NumCh);   %���ꂾ���K�v�����A1�Ɛݒ肷��Ώ\��
% WHISparam.NumERBFr1  = Freq2ERB(GCresp.Fr1);
% EMframeNH = abs(hilbert(dcGCframeNH));  %�@����Ȃ��BdcGCframeNH�͕K�����Ȃ̂ŁB����̗����オ��^����������̔g�`���݂�B

%%%%%%%%
%  HL GCframe
%%%%%%%%
GCparam.HLoss = WHISparam.HLoss;  % ����ŊO������HLoss��Param�𓱓�. HLoss.Type�������œ��������
[dcGCframeHL, scGCsmplHL,GCparamHL,GCrespHL] = GCFBv231(Snd4GCFB,GCparam);
% GCrespHL.LvldBframe;
% GCrespHL.pGCframe;
% GCrespHL.scGCframe;
% EMframeHL = abs(hilbert(dcGCframeHL));  --- No Use

tElps(1) = toc;
% disp(['---   Elapsed time is ' num2str(tElps(1),4) ' (sec) = '  num2str(tElps(1)/Tsnd,4) ' times RealTime.']);

WHISparam.HLoss = GCparamHL.HLoss;
LenSnd = length(Snd4GCFB);

% �ȏ�͋���
% ������DTVF��FABS�̕���
if strcmp(WHISparam.SynthMethod,'DTVF') == 1
    StrSynthMethod = 'dtvf';
    WHISv300dtvf;   %  GCparam.OutMidCrct �̕␳�s�v�B���ڔg�`��filter�������Ă���̂ŁB
elseif strcmp(WHISparam.SynthMethod,'FBAnaSyn') == 1
    StrSynthMethod = 'fbas';
    WHISv300fbas;    %  GCparam.OutMidCrct �̕␳�ρBfilterbank�̘a�̎��̏d�ݕt���͕K�v�B
else
    error('Specify WHISparam.SynthMethod:  "DTVF" or "FBAnaSyn"');
end 
WHISparam.version = [mfilename StrSynthMethod];

end


%% %%%%%%%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%%%%%%
%     PindB_NH_NH = GCFBv231_AsymFuncInOut_InvIOfunc(GCparamNH,GCrespNH, Fr1query, CompressionHealthNH,IOfuncdB_HL);
%     rms(PindB_NH-PindB_NH_NH)


%% %%%%%%%%%%%%%%%%%%
% Sound output
%%%%%%%%%%%%%%%%%%%%
% Level correction
%SndOut =10^(-AmpdB(2)/20)*SndEMLoss;  % Eqlz2MeddisHCLevel��␳


%% %%%%
% plot
%%%%%%%%
% if SwPlot  == 2
% SclImg = 256;
%
% subplot(5,1,1)
% image(dcGCframeNH*SclImg/40);
% set(gca,'YDir','normal');
% title('dcGCframeNH');
% max(max(dcGCframeNH))
%
% subplot(5,1,2);
% GainDynStaticGCNHdB = 20*log10(GainDynStaticGCNH);
% image(GainDynStaticGCNH*SclImg/40)
% %image(GainDynStaticGCNHdB*SclImg/40)
% set(gca,'YDir','normal');
% title('GainDynStaticGCNH');
% max(max(GainDynStaticGCNH))
% max(max(GainDynStaticGCNHdB))
%
% subplot(5,1,3)
% image(dcGCframeHL*SclImg/40);
% set(gca,'YDir','normal');
% title('dcGCframeHL');
% max(max(dcGCframeHL))
%
% subplot(5,1,4);
% GainDynStaticGCHLdB = 20*log10(GainDynStaticGCHL);
% % image(GainDynStaticGCHLdB*SclImg)
% image(GainDynStaticGCHL*SclImg/20)
% set(gca,'YDir','normal');
% title('GainDynStaticGCHL');
% max(max(GainDynStaticGCHL))
% min(min(GainDynStaticGCHL))
% max(max(GainDynStaticGCHLdB))
% min(min(GainDynStaticGCHLdB))
%
% subplot(5,1,5)
% imagesc(RatioGainGCframe)
% set(gca,'YDir','normal');
% title('RatioGainGCframe');
%
% end



%     [dummy IOfuncdB_HL_NH] = GCFBv231_AsymFuncInOut(GCparamNH,GCrespNH, Fr1query, CompressionHealthHL,PindB_HL);
%     rms(IOfuncdB_HL-IOfuncdB_HL_NH) == 0 �Ȃ̂ŁANH���g���K�v�Ȃ��B




%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Set WHISparam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if isfield(WHISparam,'FaudgramList') == 0,  GCFB�Őݒ肷��̂ŕs�v
%    WHISparam.FaudgramList = 125*2.^(0:6);
% end;
% WHISparam.NumERBaudgramList = Freq2ERB(WHISparam.FaudgramList);
%
% if length(WHISparam.DegreeCompression) == 1, % vectorize
%     WHISparam.DegreeCompression = ...
%         WHISparam.DegreeCompression*ones(size(WHISparam.FaudgramList));
%     warning('Specify WHISparam.DegreeCompression vector or set to "Full compression loss"');
% else
%     if length(WHISparam.DegreeCompression) ~= length(WHISparam.FaudgramList)
%         error('length(WHISparam.DegreeCompression) ~= length(WHISparam.FaudgramList)');
%     end;
% end;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% GCFB���LPF --- ����A���܂肤�܂������Ȃ��B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% if 0
%     EMLoss = WHISparam.EMLoss;
%     EMLoss.Fcutoff
%     % TMTF LPF  ����Amodulation ��suppress�ł��Ȃ��B
%     fsTMTF = GCparamNH.DynHPAF.fs;
%     [bzLP, apLP] = butter(2,EMLoss.Fcutoff/(fsTMTF/2));  % modulation cutoff
%     NumPeakDelay = round(fsTMTF/EMLoss.Fcutoff*0.176); % see testImpRspLPF
%     [NumCh LenFrame] = size(dcGCframeHL);
%     EMframeHL = zeros(NumCh, LenFrame);
%     for nch = 1:NumCh
%         EMframe1 = [abs(hilbert(dcGCframeHL(nch,:))), zeros(1,NumPeakDelay)];
%         EMframe2 = filter(bzLP, apLP, EMframe1);
%         EMframeHL(nch,:) = EMframe2(NumPeakDelay+1:end);
%     end;
% end;


% GCparamNH.DynHPAF.fs (default 2000 Hz = 1/0.5ms���Ƃɏ����B)
% [RatioGainGCframeDC] = GCFBv230_DelayCmpnst(RatioGainGCframe,GCparamNH,DCparam);

%

% % mod
% [NumCh LenSnd] = size(scGCsmplNH);
% scGCmod = zeros(NumCh, LenSnd);
% for nch = 1:NumCh
%     RGRsmpl = resample(RatioGainGCframe(nch,:),GCparamNH.fs, GCparamNH.DynHPAF.fs);
%     % resample���ǂ��H
%     % resample �̓A���`�G�C���A�V���O FIR ���[�p�X �t�B���^�[�� x �ɓK�p���A�t�B���^�[�ɂ���Đ�����x����␳���܂��B
%     % RGRsmpl = interp1(RatioGainGCframe(nch,:),round(GCparamNH.fs/GCparamNH.DynHPAF.fs));  % NaN������
%     LenRGR = length(RGRsmpl);
%     RGRsmpl = [RGRsmpl(1:min(LenRGR,LenSnd)), zeros(1,LenSnd-LenRGR)];
%     scGCmod(nch,:) = RGRsmpl.*scGCsmplNH(nch,:);  % Modifying Amplitude
% end;
%
% % Synthesis
% DCparam.fs = GCparamNH.fs;
% [scGCmodDC] = GCFBv230_DelayCmpnst(scGCmod,GCparamNH,DCparam);

%   ���̕��@�́A���������ɎG���^�c�݂������B�@������g�킸�ɁATime-varying filter�ō���
%�@SndHLoss = GCFBv230_SynthSnd(scGCmodDC,GCparamNH);
%
% ����ƁAModulation�̕�����������ɏ����ł���B���_�B
% if isfield(WHISparam,'EMLoss') == 1
%     % Envelope Modulation Loss (TMTF LPF) by One-third Octave filter
%     [SndEMLoss, WHISparam] = WHISv300_EnvModLoss(SndHLoss,GCparamHL,WHISparam);
% else
%     SndEMLoss = SndHLoss;  % ���ԕ����򉻂����Ȃ��΂���
% end


%         figure(11); clf
%     subplot(2,1,1);
%     plot(1:LenFrame,PindB_HL, 1:LenFrame,IOfuncdB_HL,'--')
%     [nch GCparamHL.Fr1(nch)]
%     pause(0.2);

%
%     if rem(nch,10) == 0
%         nch
%         nF = 1:length(PindB_HL);
%         plot(nF,PindB_HL, nF,PindB_NH,'-.',nF,IOfuncdB_HL,'-.', nF,GainReductdB_OHC(nch,:),'-o')
%         nch
%     end