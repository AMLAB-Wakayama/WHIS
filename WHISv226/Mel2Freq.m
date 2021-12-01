%
%	Mel -> Frequency 
%	IRINO Toshio
%	23 Aug. 2001
%
%	function [freq] = Mel2Freq(mel)
%	INPUT	freq: frequency
%	OUTPUT  mel: Mel value
%
%	mel = 2595*log10(1+ freq/700);
%	freq = ( 10.^(mel/2595)-1 ) * 700;
%
function [freq] = Mel2Freq(mel)

if nargin < 1, help Freq2Mel; return; end;

freq = ( 10.^(mel/2595)-1 ) * 700;

