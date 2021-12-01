%
%  OneThird Oct Filterbank
%   Irino T.,
%   Created: 16 Feb 2021 % from oct3fit.m
%   Modified: 16 Feb 2021
%   Modified:  19 Feb 2021
%   Modified:  22 Feb 2021 (Simplify the process. No Analysis/Synthesis -->  use OneThirdOctAnaSyn)
%
%
function [FBoct3, FBoct3DlyCmp, PwrdB, ParamOct3] = OneThirdOctFB(Snd,ParamOct3)

disp(['### ' mfilename ' ###'])
%% %%%%%%%%%%%%%%%
% Parameter setting
%%%%%%%%%%%%%%%%%
ParamOct3.OrderFilter = 3; 					% Order of analysis filters.
ParamOct3.FcLabel = [ 16 20 25 31.5 40 50 63 80 100 125 160, 200 250 315, 400 500 630, 800 1000 1250, ...
    1600 2000 2500, 3150 4000 5000 6300 8000 10000 12500 16000 20000 ]; % Preferred labeling freq.
ParamOct3.FcList = (1000).*((2^(1/3)).^[-18:13]); 	% Exact center freq.
ParamOct3.FboundaryList = [ParamOct3.FcList*2^(-1/6);  ParamOct3.FcList*2^(1/6)];
%%%

if isfield(ParamOct3,'fs') == 0
    ParamOct3.fs = 48000;  % better than 44100
end;
if isfield(ParamOct3,'FreqRange') == 0,
    ParamOct3.FreqRange = [100 13000]; % 100-12500Hz
end;
ParamOct3.NumRange = find(ParamOct3.FcLabel >=  min(ParamOct3.FreqRange) & ...
                                                 ParamOct3.FcLabel <=  max(ParamOct3.FreqRange) );
ParamOct3.FcLabel = ParamOct3.FcLabel(ParamOct3.NumRange);
ParamOct3.FcList    = ParamOct3.FcList(ParamOct3.NumRange);
ParamOct3.FboundaryList = ParamOct3.FboundaryList(:, ParamOct3.NumRange);
if isfield(ParamOct3,'FilterDelay1kHz') == 0,
    ParamOct3.FilterDelay1kHz = 0.003;  % 3ms 一番誤差が小さい気がする
end;
NumDelay1kHz = ParamOct3.FilterDelay1kHz*ParamOct3.fs;
if isfield(ParamOct3,'NrmlzPwrdB') == 0,
        ParamOct3.NrmlzPwrdB = 50;  % この値は適当　calibrationして入れること。
end;

%% %%%%%%%%%%%%%%%
% Processing
%%%%%%%%%%%%%%%%%
LenOct3 = length(ParamOct3.FcList);
LenSnd = length(Snd);
FBoct3 = zeros(LenOct3,LenSnd);
FBoct3DlyCmp = zeros(LenOct3,LenSnd);

for nf = 1:LenOct3
    %% Ana
    Fc = ParamOct3.FcList(nf);
    [bz,ap] = oct3dsgn(Fc,ParamOct3.fs,ParamOct3.OrderFilter);
    nDelay = fix(1000/Fc*NumDelay1kHz);
    Snd1 = [Snd zeros(1,nDelay)]; % Delay分長くする。
    SndFilt = filter(bz,ap,Snd1);
    FBoct3(nf,:) = SndFilt(1:LenSnd);
    FBoct3DlyCmp(nf,:) = SndFilt((nDelay +1):end); % Delay compensation
    ParamOct3.NumDelay(nf) = nDelay;
end;
% 単純に平均値で合成して、その大きさがそろうようなGainSynを計算
SndSyn = mean(FBoct3DlyCmp,1);
ParamOct3.GainAnaSyn = sqrt(mean(Snd.^2))/sqrt(mean(SndSyn.^2));
PwrdB =  10*log10(mean(FBoct3.^2,2)) + ParamOct3.NrmlzPwrdB;

% Generate the plot
if (nargout == 0)
    bar(PwrdB);
    ax = axis;
    axis([0 LenOct3+1 ax(3) ax(4)])
    n125 = find(ParamOct3.FcLabel == 125); % find 125 Hz
    set(gca,'XTick',[n125:3:LenOct3]); 		% Label frequency axis on octaves.
    set(gca,'XTickLabel',ParamOct3.FcLabel(n125:3:LenOct3)); 
    xlabel('Frequency band [Hz]'); ylabel('Power [dB]');
    title('One-third-octave spectrum')
end

return



%% %%%%%%%%%%%%%%%

% OCT3FILT Implement a bank of third octave filters
%
%   [p,f]=oct3filt(B,A,x)  implements the array of
%  third-octave filters defined by B and A.  B and A
%  each have 18 rows, corresponding to 3rd octave freqs
%  from 100 to 5000 Hz.
%
%  If no output arguments, generates a plot
%    See also OCT3DSGN, OCT3SPEC, OCTDSGN, OCTSPEC, OCT3BANK

% This is a supplemental function to Octave.  This modification
%  relies primarily on Couvreur's code. SMH 10/00

% Author: Christophe Couvreur, Faculte Polytechnique de Mons (Belgium)
%         couvreur@thor.fpms.ac.be
% Last modification: Aug. 23, 1997, 10:30pm.

% References:
%    [1] ANSI S1.1-1986 (ASA 65-1986): Specifications for
%        Octave-Band and Fractional-Octave-Band Analog and
%        Digital Filters, 1993.
%    [2] S. J. Orfanidis, Introduction to Signal Processing,
%        Prentice Hall, Englewood Cliffs, 1996.

% Copyright (c) 1997, Christophe COUVREUR
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.



