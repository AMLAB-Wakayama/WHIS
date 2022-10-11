%
%      WHISv300 でCalbration toneの設定
%      Irino, T.
%      Created:  25 Jul 2021　from HIsimFastGC_MkCalibTone 内容は全く同じ　パラメータ名の変更
%      Modified: 25 Jul 2021     
%      Modified: 10 Sep 2021  introducing hanning taper window to reduce click sounds
%      Modified: 17 Sep 2021  tidy up
%      Modified:  6  Mar 2022   WHISv300_func --> WHISv30_func 
%      Modified: 11 Mar 2022   Adding SrcSnd.
%
%
%
function [CalibTone, WHISparam] = WHISv30_MkCalibTone(WHISparam)

fs = WHISparam.fs;
WHISparam.CalibTone.Tsnd       = 5;                  % WHISparam.CalibTone.Duration から　Tsndに
WHISparam.CalibTone.Freq       = 1000;
WHISparam.CalibTone.RMSDigitalLeveldB  = -26;
WHISparam.CalibTone.Ttaper = 0.005;
% Source sound info. Added 
WHISParam.SrcSnd.RMSDigitalLevelStrWeight = 'Leq';   % WHISを使うときはかならずLeq
WHISParam.SrcSnd.RMSDigitalLeveldB = WHISparam.CalibTone.RMSDigitalLeveldB;

% Making sound
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



