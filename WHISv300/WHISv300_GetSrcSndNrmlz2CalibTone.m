%
%     WHISv300   へ import   HIsimFastGC_GUIで Normalize re. CalibTone
%     Irino, T.
%     Created:  25 Jul 21  ( 名称変更　From  HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHI)  Created:  7 Jul 18)
%     Modified:  25 Jul 21 %   変数名を整理。paramHI --> WHISparam
%     Modified:  10 Sep 21 % 入出力パラメータを変更：  SoundはParameterではないので、WHISparamから分離
%     Modified:  30 Sep 21 % LenTruncateの導入
%
%     function [SrcSnd, WHISparam] = WHISv300_GetSrcSndNrmlz2CalibTone(SndLoad,RecCalibTone,WHISparam)
%     INPUT:  SndLoad:  入力された音
%                  RecCalibTone: Recorded CalibTone
%                  WHISparam
%     OUTPUT: SrcSnd
%                   WHISparam
%
% HIsimFastGCの計算にSndLoadのNormaizeは必要なし。音圧だけ伝えれば良い。
% ただ、GUI中で、CalibToneに対するレベルの校正は必要　　9 Jul 2016
% ーー＞　ここでは、校正してrms値を合わせたものを出力。
% 元の関数function [ParamHI] = HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHI)
%
%  Note 10 May 2021, 10 Sep 2021 
%  Batchでもここで CalibToneに対するNormalizeをしたSndを使っている。
%  WHIS(HIsim)の計算では、RMS値でNormalizeされた音声を使う。
%  WHISparam.SrcSnd.StrNormalizeWeight = 'RMS';
%  これはGCFBのMeddisHairCellレベル(RMS Normalize)での要請から。
%
%
%
function [SrcSnd, WHISparam] = WHISv300_GetSrcSndNrmlz2CalibTone(SndLoad,RecCalibTone,WHISparam)

    RMSlevel_SndLoad   = sqrt(mean(SndLoad.^2));
    % RecCalibToneの中央だけ抽出
    % 1) 録音時のstartの問題を回避
    % 2) 元々のCalibToneにもTaperがはいっている
    % WHISv300_MkCalibToneでは、Ttaper = 0.005; % 5 msec to avoid click
    % 余裕を持って、100msとしておく　（厳密に決められないし、その必要もない）
    LenTruncate = 0.1*WHISparam.fs;
    nCalRMS = (LenTruncate:(length(RecCalibTone)-LenTruncate));
    if length(nCalRMS) < 1, error('RecCalibTone is too short'); end
    RMSlevel_RecCalibTone = sqrt(mean(RecCalibTone(nCalRMS).^2));
    AmpdB1 = (WHISparam.SrcSnd.SPLdB - WHISparam.CalibTone.SPLdB); % 　パラメータ名を変更 10 Sep 21
    Amp1     = 10^(AmpdB1/20)*RMSlevel_RecCalibTone/RMSlevel_SndLoad;
    SrcSnd   = Amp1*SndLoad;
    
    % WHISparam.RMSDigitalLeveldB_SrcSnd = sqrt(mean(WHISparam.SrcSnd.^2)); % この行必要 19 Apr 19 
    % bugあり。dB値で出すように。23 Jul 2019
    % 音のnormalizeは大丈夫。dB値だけが間違っていた。
    % WHISparam.RMSDigitalLeveldB_SrcSnd =20*log10(sqrt(mean(WHISparam.SrcSnd.^2))); 

    WHISparam.SrcSnd.RMSDigitalLeveldB   = 20*log10(sqrt(mean(SrcSnd.^2)));  %  WHISparam.RMSDigitalLeveldB_SrcSnd; % 新名称 10 May 2021
    WHISparam.SrcSnd.StrNormalizeWeight = 'RMS';     %  'Normalized by RMS (L_eq).  Not L_Aeq.';  
    WHISparam.SrcSnd.SndLoad_RMSDigitalLeveldB = 20*log10(RMSlevel_SndLoad);
    WHISparam.SrcSnd.RecordedCalibTone_RMSDigitalLeveldB = 20*log10(RMSlevel_RecCalibTone);
    
end
