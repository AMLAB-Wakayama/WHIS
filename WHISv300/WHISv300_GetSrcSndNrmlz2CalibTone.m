%
%     WHISv300   �� import   HIsimFastGC_GUI�� Normalize re. CalibTone
%     Irino, T.
%     Created:  25 Jul 21  ( ���̕ύX�@From  HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHI)  Created:  7 Jul 18)
%     Modified:  25 Jul 21 %   �ϐ����𐮗��BparamHI --> WHISparam
%     Modified:  10 Sep 21 % ���o�̓p�����[�^��ύX�F  Sound��Parameter�ł͂Ȃ��̂ŁAWHISparam���番��
%     Modified:  30 Sep 21 % LenTruncate�̓���
%
%     function [SrcSnd, WHISparam] = WHISv300_GetSrcSndNrmlz2CalibTone(SndLoad,RecCalibTone,WHISparam)
%     INPUT:  SndLoad:  ���͂��ꂽ��
%                  RecCalibTone: Recorded CalibTone
%                  WHISparam
%     OUTPUT: SrcSnd
%                   WHISparam
%
% HIsimFastGC�̌v�Z��SndLoad��Normaize�͕K�v�Ȃ��B���������`����Ηǂ��B
% �����AGUI���ŁACalibTone�ɑ΂��郌�x���̍Z���͕K�v�@�@9 Jul 2016
% �[�[���@�����ł́A�Z������rms�l�����킹�����̂��o�́B
% ���̊֐�function [ParamHI] = HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHI)
%
%  Note 10 May 2021, 10 Sep 2021 
%  Batch�ł������� CalibTone�ɑ΂���Normalize������Snd���g���Ă���B
%  WHIS(HIsim)�̌v�Z�ł́ARMS�l��Normalize���ꂽ�������g���B
%  WHISparam.SrcSnd.StrNormalizeWeight = 'RMS';
%  �����GCFB��MeddisHairCell���x��(RMS Normalize)�ł̗v������B
%
%
%
function [SrcSnd, WHISparam] = WHISv300_GetSrcSndNrmlz2CalibTone(SndLoad,RecCalibTone,WHISparam)

    RMSlevel_SndLoad   = sqrt(mean(SndLoad.^2));
    % RecCalibTone�̒����������o
    % 1) �^������start�̖������
    % 2) ���X��CalibTone�ɂ�Taper���͂����Ă���
    % WHISv300_MkCalibTone�ł́ATtaper = 0.005; % 5 msec to avoid click
    % �]�T�������āA100ms�Ƃ��Ă����@�i�����Ɍ��߂��Ȃ����A���̕K�v���Ȃ��j
    LenTruncate = 0.1*WHISparam.fs;
    nCalRMS = (LenTruncate:(length(RecCalibTone)-LenTruncate));
    if length(nCalRMS) < 1, error('RecCalibTone is too short'); end
    RMSlevel_RecCalibTone = sqrt(mean(RecCalibTone(nCalRMS).^2));
    AmpdB1 = (WHISparam.SrcSnd.SPLdB - WHISparam.CalibTone.SPLdB); % �@�p�����[�^����ύX 10 Sep 21
    Amp1     = 10^(AmpdB1/20)*RMSlevel_RecCalibTone/RMSlevel_SndLoad;
    SrcSnd   = Amp1*SndLoad;
    
    % WHISparam.RMSDigitalLeveldB_SrcSnd = sqrt(mean(WHISparam.SrcSnd.^2)); % ���̍s�K�v 19 Apr 19 
    % bug����BdB�l�ŏo���悤�ɁB23 Jul 2019
    % ����normalize�͑��v�BdB�l�������Ԉ���Ă����B
    % WHISparam.RMSDigitalLeveldB_SrcSnd =20*log10(sqrt(mean(WHISparam.SrcSnd.^2))); 

    WHISparam.SrcSnd.RMSDigitalLeveldB   = 20*log10(sqrt(mean(SrcSnd.^2)));  %  WHISparam.RMSDigitalLeveldB_SrcSnd; % �V���� 10 May 2021
    WHISparam.SrcSnd.StrNormalizeWeight = 'RMS';     %  'Normalized by RMS (L_eq).  Not L_Aeq.';  
    WHISparam.SrcSnd.SndLoad_RMSDigitalLeveldB = 20*log10(RMSlevel_SndLoad);
    WHISparam.SrcSnd.RecordedCalibTone_RMSDigitalLeveldB = 20*log10(RMSlevel_RecCalibTone);
    
end
