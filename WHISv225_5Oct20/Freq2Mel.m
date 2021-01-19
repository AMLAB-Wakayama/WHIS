%
%	Frequency -> Mel
%	IRINO Toshio
%	23 Aug. 2001
%
%	function [mel] = Freq2Mel(freq),
%	INPUT	freq: frequency
%	OUTPUT  mel: Mel value
%
%	mel = 2595*log10(1+ freq/700);
%
function [mel] = Freq2Mel(freq)

if nargin < 1, help Freq2Mel; return; end;

mel = 2595*log10(1+ freq/700);


%%%%%%%%%%% not so accurate value in the vector %%%

%freq   =[40 160 200 400 650 850 1000 2000 3000 3500 4000 5200 6500 7500 12000];
%MelVal =[40 250 300 500 770 900 1000 1550 1950 2130 2270 2580 2750 2870 3200];
% plot(freq,MelVal,'o',freq,Mel)


