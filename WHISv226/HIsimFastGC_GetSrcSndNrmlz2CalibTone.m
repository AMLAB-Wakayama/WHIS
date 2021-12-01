%
%     HIsimFastGC_GUI�� Normalize re. CalibTone
%     Irino, T.
%     Created:  7 Jul 18
%     Modified: 7 Jul 18
%     Modified: 19 Apr 19 % ParamHI.RMSDigitalLeveldB_SrcSnd in HIsimFastGC_GetSrcSndNrmlz2CalibTone
%     Modified: 23 Jul  19 % �o�O�FDigital Level ��dB�ŕԂ����ƁB ParamHI.RMSDigitalLeveldB_SrcSnd
%     Modified:  9 May 21 %  �������킩��ɂ��������BRMS�l�� normalize���Ă��邱�Ƃ�\������悤�ɁB�����̕ύX�͂Ȃ��B
%
%
% HIsimFastGC�̌v�Z��SndLoad��Normaize�͕K�v�Ȃ��B���������`����Ηǂ��B
% �����AGUI���ŁACalibTone�ɑ΂��郌�x���̍Z���͕K�v�@�@9 Jul 2016
% �[�[���@�����ł́A�Z������rms�l�����킹�����̂��o�́B
%
%  Note 10 May 2021
%  Batch�ł������� CalibTone�ɑ΂���Normalize������Snd���g���Ă���B
%  WHIS(HIsim)�̌v�Z�ł́ARMS�l��Normalize���ꂽ�������g���B
%  �����GCFB��MeddisHairCell���x��(RMS Normalize)�ł̗v������B
%
%
function [ParamHI] = HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHI)

    RMSlevel_SndLoad   = sqrt(mean(ParamHI.SndLoad.^2));
    RMSlevel_CalibTone = sqrt(mean(ParamHI.RecordedCalibTone.^2));
    AmpdB1 = (ParamHI.SrcSndSPLdB - ParamHI.SPLdB_CalibTone); % 
    Amp1   = 10^(AmpdB1/20)*RMSlevel_CalibTone/RMSlevel_SndLoad;
    ParamHI.SrcSnd = Amp1*ParamHI.SndLoad;
    
    % ParamHI.RMSDigitalLeveldB_SrcSnd = sqrt(mean(ParamHI.SrcSnd.^2)); % ���̍s�K�v 19 Apr 19 
    % bug����BdB�l�ŏo���悤�ɁB23 Jul 2019
    % ����normalize�͑��v�BdB�l�������Ԉ���Ă����B
    ParamHI.RMSDigitalLeveldB_SrcSnd =20*log10(sqrt(mean(ParamHI.SrcSnd.^2))); 

    % Added code on 9 May 21%%% 
    ParamHI.SrcSnd_RMSDigitalLeveldB = ParamHI.RMSDigitalLeveldB_SrcSnd; % �V���� 10 May 2021
    ParamHI.SrcSnd_StrNormalizeWeight = 'RMS';     %  'Normalized by RMS (L_eq).  Not L_Aeq.';  
    
end
