%
%   Simulated Time Vary Filtering
%   Irino T.
%   Created:   2 Dec 2013
%   Modified:  2 Dec 2013 
%   Modified: 26 Dec 2013 (default TVFparam.Twin = 0.020; in sec)
%   Modified:  3 Jan 2014 ( Ana sqrt(hanning) * Syn sqrt(hanning))
%   Modified: 12 Aug 2021 ( TVFparam.N --> Nshift, TVFparam.NumFrame --> LenFrame )
%   Modified: 17 Sep 2021 ( パラメータ名の整理。TVFparam.NumFrame --- LenFrame　-- LenShift)
%
%
% function [SndMod TVFparam] = SimTimeVaryFilter(Snd,TVFparam); 
%  INPUT : Snd
%          TVFparam
%  OUTPUT : SndMod : TV filtered Snd
%
%
function [SndMod WinFrame TVFparam] = SimTimeVaryFilter_AnaSyn(Snd,WinFrame,TVFparam)   % No control, ValCtrl);

if nargin < 2, WinFrame = []; end
if length(WinFrame) == 0,  TVFparam.Ctrl = 'ana'; end

if isfield(TVFparam,'Ctrl') == 0 
    error('Specify TVFparam.Cntl = ''ana'' or ''syn''');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strncmp(TVFparam.Ctrl,'ana',3) == 1
    if isfield(TVFparam,'fs')     == 0, TVFparam.fs = 48000; end
    if isfield(TVFparam,'Twin')   == 0
        % TVFparam.Twin = 0.010; % (sec) == 10 (ms) Noisy for HI simulation
        TVFparam.Twin = 0.020;   % (sec) == 20 (ms) -- default
    end
    if isfield(TVFparam,'Tshift') == 0
        TVFparam.Tshift  = TVFparam.Twin/2; % ms
    end
    if isfield(TVFparam,'NameWin')== 0 
        TVFparam.NameWin = 'hanning';
    end
    
    if isfield(TVFparam,'SwWinAnaSyn')== 0
        % TVFparam.SwWinAnaSyn = 'full-ones';
        TVFparam.SwWinAnaSyn = 'sqrt-sqrt';
    end

    if TVFparam.Tshift ~= TVFparam.Twin/2
        error('Tshift should be Twin/2.');
    end

    LenShift = TVFparam.Tshift*TVFparam.fs;  % = N
    LenWin = 2*LenShift+1;
    if  strcmp(TVFparam.NameWin,'hanning')
        WinAna = sqrt(hanning(LenWin));  % sqrt analysis - sqrt sybthesis
        WinSyn = WinAna;
        if strcmp(TVFparam.NameWin,'full-ones') == 1
            WinAna = hanning(LenWin);
            WinSyn = ones(size(WinAna));
        end
    else
        error('TVFparam.NameWin should be hanning');
    end

    LenSnd = length(Snd);
    LenFrame = ceil(LenSnd/(LenShift+1))+1; % なぜ最後に+1??
    ZpadPre  = zeros(1,LenShift);
    ZpadPost = zeros(1,LenFrame*(LenShift+1)-LenSnd);
    SndZp = [ZpadPre, Snd, ZpadPost]; % zeropad
    WinFrame = zeros(LenWin,LenFrame);
    
    for nf = 1:LenFrame
        nRange = (nf-1)*(LenShift+1) + (1:LenWin);
        WinFrame(1:LenWin,nf) = SndZp(nRange)'.*WinAna;
        NsmplSnd(nf) = (nf-1)*(LenShift+1)+1;
        % Some processing here
        % Synthesis 
        %    Snd2(nRange) = Snd2(nRange) + WinFrame;
    end;

    % keep params
    TVFparam.Nshift     = LenShift;  % Renamed from TVFparam.N to TVFparam.Nshift  12 Aug 21
    TVFparam.LenShift  = LenShift;  % 17 Sep 21
    TVFparam.N            = LenShift;  % 更新前のパラメータ for backward compativility
    TVFparam.LenWin   = LenWin;
    TVFparam.WinAna   = WinAna;
    TVFparam.WinSyn   = WinSyn;
    TVFparam.LenFrame = LenFrame;  % 17 Sep 21
    TVFparam.NumFrame = LenFrame; % 残す　Backward compativility
    TVFparam.LenSnd   = LenSnd;
    TVFparam.LenSndZp = length(SndZp);
    TVFparam.NsmplSnd = NsmplSnd;
    TVFparam.ZpadPre  = ZpadPre;
    TVFparam.ZpadPost = ZpadPost;

    TVFparam = orderfields(TVFparam);
    SndMod = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Synthesis %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strncmp(TVFparam.Ctrl,'syn',3) == 1
    % restore params
    LenWin     = TVFparam.LenWin;
    if isfield(TVFparam,'LenShift')  == 0
        LenShift    = TVFparam.LenShift;% 17 Sep 21 Backward compativility
    else
        LenShift    = TVFparam.LenShift;
    end
    if isfield(TVFparam,'LenFrame')  == 0
        LenFrame = TVFparam.NumFrame; % 17 Sep 21 Backward compativility
    else
        LenFrame = TVFparam.LenFrame;
    end
    LenSnd   = TVFparam.LenSnd;
    LenSndZp = TVFparam.LenSndZp;

    [mm, nn] = size(WinFrame);
    if mm ~= LenWin || nn ~= LenFrame
       error('Check WinFrame:  LenWin * LenFrame ');
    end

    SndSyn = zeros(1,LenSndZp);
    for nf = 1:LenFrame
        nRange = (nf-1)*(LenShift+1) + (1:LenWin);
        SndSyn(nRange) = SndSyn(nRange) + WinFrame(1:LenWin,nf)'.*TVFparam.WinSyn(:)';
    end
    SndMod = SndSyn(LenShift + (1:LenSnd));
else
    error('Specify TVFparam.Cntl = ''ana'' or ''syn'''); 
end

return
  
