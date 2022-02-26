%
%     HIsimFastGC_GUIでCalbration toneの設定
%     Irino, T.
%     Created:  7 Jul 18
%     Modified: 7 Jul 18
%     Modified: 9 Dec 18 % introduction of ParamHI.CalibTone.xxx
%     Modified: 10 May 21
%
%
%
function [CalibTone, ParamHI] = HIsimFastGC_MkCalibTone(ParamHI)

Tdur = 5; % sec
fCalib = 1000; % 1 kHz tone
OutLeveldB = -26;
AmpCalib    = 10^(OutLeveldB/20)*sqrt(2); % set about the same as recording level
CalibTone   = AmpCalib*sin(2*pi*fCalib*(0:Tdur*ParamHI.fs-1)/ParamHI.fs);

ParamHI.CalibTone.Tdur = Tdur;
ParamHI.CalibTone.Freq = fCalib;
ParamHI.CalibTone.RMSDigitalLeveldB  = OutLeveldB;
ParamHI.RMSDigitalLeveldB_CalibTone = 20*log10(sqrt(mean(CalibTone.^2)));
%  両者は同じはず。確認 (9 Dec 18)：
%  ParamHI.CalibTone.RMSDigitalLeveldB-ParamHI.RMSDigitalLeveldB_CalibTone =
%  1.2221e-12
%

% Add Name 10 May 21
ParamHI.CalibTone.Name =  ['Snd_CalibTone_' int2str(ParamHI.CalibTone.Freq/1000) 'kHz'  ...
        int2str(ParamHI.CalibTone.RMSDigitalLeveldB) 'dB']; % 10 May 21

return;


