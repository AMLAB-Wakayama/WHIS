%
%      WHIS: Wadai Hearing Impairment Simulator v300
%      IRINO T.
%      Created:     9 Feb  2021 from HIsimFastGC.m
%      Modified:     9 Feb 2021
%      Modified:   23 Feb 2021  (OneThirdOctFB���p + TMTF lowpass)
%      Modified:   23 Feb 2021  (GCFB ana/syn   + TMTF lowpass�ł�OneThirdOctFB���p)
%      Modified:    6 Mar 2021  (GCFB ana/syn   + TMTF lowpass��S��GCFB�ŁB�[�[�@NG�ۂ�)%
%      Modified:   25 Jul  2021  (HISparam --> WHISparam)
%      Modified:   12 Aug 2021  (Qualty improvement using TimeVarying filter.)
%      Modified:   13 Aug 2021  (debug WHISparam.fs)
%      Modified:   18 Aug 2021  (debug using ReductdB_CmprsHlth & dB calculation)
%      Modified:    1 Sep 2021   using GCFBv231
%      Modified:  10 Sep 2021  
%      Modified:  26 Sep 2021  EMLoss  (modified name WHISv300 --> WHISv300dtvf)
%      Modified:  20 Oct  2021  ���ʕ������o�BWHISv300dtvf, WHISv300fabs�������ŕ��� -- control  GCparam
%      Modified:  26 Oct  2021  introducing MkFilterField2Cochlea
%      Modified:   6  Mar 2022   v301  WHISv300_func --> WHISv30_func, GCFBv231--> GCFBv232
%      Modified:  20 Mar 2022  v302  <--- GCFBv233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%      Modified:  19 Oct 2022  v302  GCFBv234 <-- GCFBv233
%
%
%   function [SndOut, WHISparam] = WHISv300(SrcSnd, WHISparam);
%   INPUT:  SrcSnd : input sound
%           WHISparam: parameters
%   OUTPUT: SndOut: processed sound
%           WHISparam: parameters
%
%
function [SndOut, WHISparam] = WHISv302(SrcSnd, WHISparam)


disp(' ');
disp(['------------------ ' mfilename ' --------------------']);

if nargin < 1
    str = ['help ' mfilename];
    eval(str);
end
if nargin < 2, WHISparam = []; end;

%%%%%%%%
% Setting path to tool and GCFB
StartupWHIS;

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
if isfield(WHISparam,'SwPlot') == 0  % plot ACTive loss , PASsive loss
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
[dcGCframeHL, scGCsmplHL,GCparamHL,GCrespHL] = GCFBv234(Snd4GCFB,GCparam);
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
    WHISv302dtvf;   %  GCparam.OutMidCrct �̕␳�s�v�B���ڔg�`��filter�������Ă���̂ŁB
elseif strcmp(WHISparam.SynthMethod,'FBAnaSyn') == 1
    StrSynthMethod = 'fbas';
    WHISv302fbas;    %  GCparam.OutMidCrct �̕␳�ρBfilterbank�̘a�̎��̏d�ݕt���͕K�v�B
else
    error('Specify WHISparam.SynthMethod:  "DTVF" or "FBAnaSyn"');
end 
WHISparam.version = [mfilename StrSynthMethod];

end

