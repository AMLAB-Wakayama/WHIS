% Created 3 Dec 15, Nagae Misaki
% Plot piptone sound data
clf;
clear all;

Freq = '125';
HL = '20';
CmpB = '100';
CmpR = '95';
UpDwn = 'Up';

Dir = [getenv('HOME') '/Documents/MATLAB/Piptone/125Hz/'];

filenameB = [Dir 'HISndPipSq' UpDwn Freq 'Hz-' HL 'dBHL-Cmprs' CmpB '.wav'];
filenameR = [Dir 'HISndPipSq' UpDwn Freq 'Hz-' HL 'dBHL-Cmprs' CmpR '.wav'];
titlename = ['Pip' UpDwn Freq 'Hz, ' HL 'dBHL, Cmprs' CmpB '%(blue), ' CmpR '%(red)'];
figtitle = ['Pip' UpDwn Freq 'Hz_' HL 'dBHL_Cmprs' CmpB 'and' CmpR '.png'];

[yB,fs]=wavread(filenameB);
[yR,fs]=wavread(filenameR);
t=(0:length(yB)-1)/fs;
t2=(0:length([zeros(1,7200)';yB])-1)/fs;
yBdB = 10*log10(abs(yB));
yRdB = 10*log10(abs(yR));


yRdB= [zeros(7200,1)-100;yRdB];
plot(t,yBdB);
hold on;
plot(t2,yRdB,'r');
title(titlename);

% width  = 1024;
% height = 768;
% set(gcf,'PaperPositionMode','auto')
% pos=get(gcf,'Position');
% pos(3)=width-1; % Ç»Ç∫Ç©ïùÇ™1pxëùÇ¶ÇÈÇÃÇ≈ëŒèà
% pos(4)=height;
% set(gcf,'Position',pos);
ylim([-70 0]);
xlabel('Time [s]');
ylabel('dB');
set(gca, 'fontsize', 14);
%ylim([-90 0]);
print('-r0','-dpng',figtitle);

%ylim([-8*10^(-3) 8*10^(-3)]);

