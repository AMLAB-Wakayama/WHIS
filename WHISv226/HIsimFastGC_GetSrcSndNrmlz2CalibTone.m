%
%     HIsimFastGC_GUIで Normalize re. CalibTone
%     Irino, T.
%     Created:  7 Jul 18
%     Modified: 7 Jul 18
%     Modified: 19 Apr 19 % ParamHI.RMSDigitalLeveldB_SrcSnd in HIsimFastGC_GetSrcSndNrmlz2CalibTone
%     Modified: 23 Jul  19 % バグ：Digital Level はdBで返すこと。 ParamHI.RMSDigitalLeveldB_SrcSnd
%     Modified:  9 May 21 %  処理がわかりにくかった。RMS値で normalizeしていることを表示するように。処理の変更はなし。
%
%
% HIsimFastGCの計算にSndLoadのNormaizeは必要なし。音圧だけ伝えれば良い。
% ただ、GUI中で、CalibToneに対するレベルの校正は必要　　9 Jul 2016
% ーー＞　ここでは、校正してrms値を合わせたものを出力。
%
%  Note 10 May 2021
%  Batchでもここで CalibToneに対するNormalizeをしたSndを使っている。
%  WHIS(HIsim)の計算では、RMS値でNormalizeされた音声を使う。
%  これはGCFBのMeddisHairCellレベル(RMS Normalize)での要請から。
%
%
function [ParamHI] = HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHI)

    RMSlevel_SndLoad   = sqrt(mean(ParamHI.SndLoad.^2));
    RMSlevel_CalibTone = sqrt(mean(ParamHI.RecordedCalibTone.^2));
    AmpdB1 = (ParamHI.SrcSndSPLdB - ParamHI.SPLdB_CalibTone); % 
    Amp1   = 10^(AmpdB1/20)*RMSlevel_CalibTone/RMSlevel_SndLoad;
    ParamHI.SrcSnd = Amp1*ParamHI.SndLoad;
    
    % ParamHI.RMSDigitalLeveldB_SrcSnd = sqrt(mean(ParamHI.SrcSnd.^2)); % この行必要 19 Apr 19 
    % bugあり。dB値で出すように。23 Jul 2019
    % 音のnormalizeは大丈夫。dB値だけが間違っていた。
    ParamHI.RMSDigitalLeveldB_SrcSnd =20*log10(sqrt(mean(ParamHI.SrcSnd.^2))); 

    % Added code on 9 May 21%%% 
    ParamHI.SrcSnd_RMSDigitalLeveldB = ParamHI.RMSDigitalLeveldB_SrcSnd; % 新名称 10 May 2021
    ParamHI.SrcSnd_StrNormalizeWeight = 'RMS';     %  'Normalized by RMS (L_eq).  Not L_Aeq.';  
    
end
