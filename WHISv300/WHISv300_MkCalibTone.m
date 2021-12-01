%
%     WHISv300 でCalbration toneの設定
%     Irino, T.
%     Created:  25 Jul 21　from HIsimFastGC_MkCalibTone 内容は全く同じ　パラメータ名の変更
%     Modified: 25 Jul 21     
%     Modified: 10 Sep 21  introducing hanning taper window to reduce click sounds
%     Modified: 17 Sep 21  tidy up
%
%
%
function [CalibTone, WHISparam] = WHISv300_MkCalibTone(WHISparam)

fs = WHISparam.fs;
WHISparam.CalibTone.Tsnd       = 5;                  % WHISparam.CalibTone.Duration から　Tsndに
WHISparam.CalibTone.Freq       = 1000;
WHISparam.CalibTone.RMSDigitalLeveldB  = -26;
WHISparam.CalibTone.Ttaper = 0.005;

LenCalib  = WHISparam.CalibTone.Tsnd*fs;
LenTaper = WHISparam.CalibTone.Ttaper*fs;
AmpCalib = 10^(WHISparam.CalibTone.RMSDigitalLeveldB/20)*sqrt(2); % set about the same as recording level
TaperWin = TaperWindow(LenCalib,'han',LenTaper);
CalibTone = AmpCalib*TaperWin.*sin(2*pi*WHISparam.CalibTone.Freq *(0:LenCalib-1)/fs);

% check_RMSDigitalLeveldB_CalibTone = 20*log10(sqrt(mean(CalibTone.^2)));
% WHISparam.CalibTone.RMSDigitalLeveldB - check_RMSDigitalLeveldB_CalibTone
%  Taperなしで 両者は同じはず、 1.2221e-12 dB  OK 確認 (9 Dec 18)：
% Taper込みで、0.0054 dB (9 Dec 21)

% Add Name 10 May 21 mod 10 Sep 21
WHISparam.CalibTone.Name =  ['Snd_CalibTone_' int2str(WHISparam.CalibTone.Freq/1000) 'kHz_RMS'  ...
    int2str(WHISparam.CalibTone.RMSDigitalLeveldB) 'dB']; % 10 May 21

end



