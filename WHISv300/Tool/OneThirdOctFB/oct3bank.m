function [p,f] = oct3bank(x); 
% OCT3BANK Simple one-third-octave filter bank. 
%    OCT3BANK(X) plots one-third-octave power spectra of signal vector X. 
%    Implementation based on ANSI S1.11-1986 Order-3 filters. 
%    Sampling frequency Fs = 44100 Hz. Restricted one-third-octave-band 
%    range (from 100 Hz to 5000 Hz). RMS power is computed in each band 
%    and expressed in dB with 1 as reference level. 
%
%    [P,F] = OCT3BANK(X) returns two length-18 row-vectors with 
%    the RMS power (in dB) in P and the corresponding preferred labeling 
%    frequencies (ANSI S1.6-1984) in F. 
%
%    [B,A] = OCT3BANK returns coefficients of above third octave filters
%      First row-100 Hz; Last row-5000 Hz.  First 12 filters require a multirate 
%      implementation (See Reference [2]).
%      This modification by Scott Hirsch, 10/00
%
%    See also OCT3DSGN, OCT3SPEC, OCTDSGN, OCTSPEC.

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

narg=nargin;

pi = 3.14159265358979; 
Fs = 44100; 				% Sampling Frequency
N = 3; 					% Order of analysis filters. 
F = [ 100 125 160, 200 250 315, 400 500 630, 800 1000 1250, ... 
		1600 2000 2500, 3150 4000 5000 ]; % Preferred labeling freq. 
ff = (1000).*((2^(1/3)).^[-10:7]); 	% Exact center freq. 	
P = zeros(1,18);
if narg
m = length(x); 
end;
% Design filters and compute RMS powers in 1/3-oct. bands
% 5000 Hz band to 1600 Hz band, direct implementation of filters. 
BB=[];
AA=[];
for i = 18:-1:13
	[B,A] = oct3dsgn(ff(i),Fs,N);
	if narg
		y = filter(B,A,x); 
		P(i) = sum(y.^2)/m; 
	else
		BB(i,:)=B;
		AA(i,:)=A;
	end;
end

if narg
	% 1250 Hz to 100 Hz, multirate filter implementation (see [2]). 
	[Bu,Au] = oct3dsgn(ff(15),Fs,N); 	% Upper 1/3-oct. band in last octave. 
	[Bc,Ac] = oct3dsgn(ff(14),Fs,N); 	% Center 1/3-oct. band in last octave. 
	[Bl,Al] = oct3dsgn(ff(13),Fs,N); 	% Lower 1/3-oct. band in last octave. 
	for j = 3:-1:0
		x = decimate(x,2); 
		m = length(x); 
		y = filter(Bu,Au,x); 
		P(j*3+3) = sum(y.^2)/m;    
		y = filter(Bc,Ac,x); 
		P(j*3+2) = sum(y.^2)/m;    
		y = filter(Bl,Al,x); 
		P(j*3+1) = sum(y.^2)/m; 
	end
	
	% Convert to decibels. 
	Pref = 1; 				% Reference level for dB scale.  
	idx = (P>0);
	P(idx) = 10*log10(P(idx)/Pref);
	P(~idx) = NaN*ones(sum(~idx),1);
	
	% Generate the plot
	if (nargout == 0) 			
		bar(P);
		ax = axis;  
		axis([0 19 ax(3) ax(4)]) 
		set(gca,'XTick',[2:3:18]); 		% Label frequency axis on octaves. 
		set(gca,'XTickLabels',F(2:3:length(F)));  % MATLAB 4.1c
		%  set(gca,'XTickLabel',F(2:3:length(F)));  % MATLAB 5.1
		xlabel('Frequency band [Hz]'); ylabel('Power [dB]');
		title('One-third-octave spectrum')
		% Set up output parameters
	elseif (nargout == 1) 			
		p = P; 
	elseif (nargout == 2) 			
		p = P; 
		f = F;
	end
	
else
	BBx=BB(13:15,:);	%Section to repeat
	AAx=AA(13:15,:);
	for ii=1:4
		ind=(ii-1)*3+1:ii*3;
		BB(ind,:)=BBx;
		AA(ind,:)=AAx;
	end;
	p=BB;
	f=AA;
end;

