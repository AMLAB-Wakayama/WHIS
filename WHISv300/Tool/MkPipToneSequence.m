%
%   Making Piptone sequence
%   Irino T.,
%   Created:  30 Sep 21 (extracted from ExpSpIntelWHIS_MkPipLeadSnd)
%   Modified:  30 Sep 21
%
%   [SndPip, ParamPip] = MkPipToneSequence(Fpip,fs,RefRMSleveldB,SwPlay)
%   INPUT:  Fpip: piptone freq
%               fs: sampling freq
%               RefRMSleveldB: RMS digital level of leading sound and first pip tone
%               SpPlay: play sound 
%  OUPUT: SndPip: pip tone sequence
%               ParamPip: pip tone paremeter
%
function [SndPip, ParamPip] = MkPipToneSequence(Fpip,fs,RefRMSleveldB,SwPlay)

if nargin < 1, Fpip = []; end
if length(Fpip) == 0, Fpip = 1000; end
if nargin < 2, fs = []; end
if length(fs) == 0, fs = 48000; end
if nargin < 3, RefRMSleveldB = []; end
if length(RefRMSleveldB) == 0, RefRMSleveldB = -26; end
if nargin < 4, SwPlay = 0; end

%% %%%%
% Parameters: Piptone sequence
%%%%%%
ParamPip.fs = fs;
ParamPip.Fpip = Fpip;
ParamPip.RefRMSleveldB = RefRMSleveldB;
ParamPip.Name = ['Snd_PipToneSqnc_'  int2str(Fpip) 'Hz'];
ParamPip.Tpip        = 0.1; % 100 msec
ParamPip.Tlead      = 1;  % 1 sec
ParamPip.Tinterval = 0.35;
ParamPip.Ttaper    = 0.005; % 5ms
ParamPip.StepdB   = -5;
ParamPip.StepNum = 15;  % -26-5*13 = -91;  12ŒÂ‚Í’®‚±‚¦‚é
% 16 bit‚¾‚ÆADynamic Range‚Í20*log10(2^15-1)= 90.3 dB ‚±‚êˆÈ‰º‚É‚Í‚Å‚«‚È‚¢
ParamPip.SwPlay = SwPlay;

%% %%%
%
%%%%%
LenPip     = ParamPip.Tpip*fs;
LenTaper = ParamPip.Ttaper*fs;
TaperWin = TaperWindow(LenPip,'han',LenTaper);
LenPreSnd =  ParamPip.Tlead*fs;
TaperWinPreSnd = TaperWindow(LenPreSnd,'han',LenTaper);
SndZero = zeros(1,ParamPip.Tinterval* fs);

AmpFirst = 10^(ParamPip.RefRMSleveldB/20);
SndOnePip = AmpFirst*TaperWin.*sin(2*pi*Fpip*(0:LenPip-1)/fs);
SndPreSnd = AmpFirst*TaperWinPreSnd.*sin(2*pi*Fpip*(0:LenPreSnd-1)/fs);
SndPip       = [SndPreSnd, SndZero, SndZero(1:end/2)]; %Å‰‚ÌPreSnd‚©‚ç‚Í1.5”{‚­‚ç‚¢‚ÌŠÔŠu‚ª—Ç‚¢
for nStep = 1:ParamPip.StepNum
    Amp = 10^(((nStep-1)*ParamPip.StepdB )/20);
    SndPip = [SndPip Amp*SndOnePip SndZero];
    RatioAmpRe1(nStep) = Amp/(2^(-15));
end
SndPip = [SndPip SndZero];

if ParamPip.SwPlay == 1
    ap0 = audioplayer(SndPip,fs);
    playblocking(ap0);
end

return

