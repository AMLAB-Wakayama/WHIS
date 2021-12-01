%
%   Batch execution function for WHISv300
%   Irino, T.
%   Created:   14 Feb 21
%   Modified:   14 Feb 21
%   Modified:   25 Jul  21  (HISparam --> WHISparam)
%   Modified:   2 Sep  21   using GCFBv231
%   Modified:  10 Sep  21   using GCFBv231
%   Modified:  20 Oct  21   dtvf��FBAnaSyn�̕����WHISv300�̒��ɁB
%
%   function [SndWHIS,SrcSnd,RecordedCalibTone,WHISparam] = WHISv300_Batch(SndLoad, WHISparam)
%   INPUT:  SndLoad : input sound
%           WHISparam : parameters
%                        HLoss.Type: audiogram select (HL1~HL*)   (e.g. 'HL2' 80yr-male)
%                        HLoss.CompressionHealth (0 ~ 1,  1: Healty,  0: complete loss)
%                        CalibTone.SPLdB : calibtone level    % no default
%                        SrcSnd.SPLdB : source_sound sound pressure level dB  % no default
%
%   OUTPUT: SndWHIS : WHIS processed sound
%                  SrcSnd : source sound for WHIS  normalized to CalibTone       RMS level
%                  RecordedCalibTone:  Recoreded calibtone  == CalibTone  in this Batch program
%                  WHISparam
%
%   Note: ���p�@  17 Oct 18, 10 Sep 21
%       Calbration tone ��digital level�ŁARMS = -26 dB �Ƃ��Čv�Z���Ă��܂��B
%       ���ׂĂ̎����ŁA����Calbration tone���g���čĐ����A�����ɂ��킹�����x���ōZ�����Ă��������B
%       1) WHISparam_GUI�̏ꍇ�́A80dB�ōZ�����܂��B����́A�傫�Ȑ��������Ă��N���b�s���O���Ȃ��悤�ɁB
%               ���̏ꍇ�AWHISparam.CalibTone.SPLdB = 80; (default�l)�ł��B
%       2) ��������ŁACalbration tone��65dB�ɍ��킹���ꍇ�A
%               WHISparam.CalibTone.SPLdB = 65; �ƂȂ�悤�Ɉ�����ݒ肵�Ă��������B
%
%        �w�i�F�v�Z�@�͐��l������m���Ă��܂��B���̐��l���O�E�ŉ�dB�ɂȂ邩��m��܂���B
%                  �����������̂��ACalbration tone�ɂ��Z���ł��B
%                  �Ή��Â��������Ƃł��Ă��Ȃ��ꍇ�A�v�Z�@�̓��������͊ԈႦ�܂��B
%
%
function [SndWHIS,SrcSnd,CalibTone,WHISparam] = WHISv300_Batch(SndLoad, WHISparam)

[mm, nn] = size(SndLoad);
if min(mm, nn)  > 1
    error('���͉��́A���m����(�s�x�N�g���j�Ƃ��邱�ƁB�����̍ہA�ԈႦ�Ȃ��悤�ɂ��邽�߁B');
    return;
end
SndLoad = SndLoad(:)'; % �s�x�N�g��

%%  %%%%%%%%%%%
% �����ݒ�  'batch'�𖾎��B�@GUI�ł�����InitParamHI���g�����A�����'GUI'�ŗ��p�B
%%%%%%%%%%%%%%%%%
WHISparam.SwGUIbatch = 'Batch';
WHISparam.AllowDownSampling = 0; % Batch�ł�DownSampling�͍s��Ȃ��B

if isfield(WHISparam,'SynthMethod') == 0
    WHISparam.SynthMethod = 'DTVF';  % default DTVF
end

%% %%%%%%%%%%%%%%%%%
% �������x�����킹
%%%%%%%%%%%%%%%%%%%%
disp(['CalibTone SPLdB = '  num2str(WHISparam.CalibTone.SPLdB) ' (dB)']);
disp(['SrcSnd  SPLdB    = '  num2str(WHISparam.SrcSnd.SPLdB) ' (dB)']);

[CalibTone, WHISparam]  = WHISv300_MkCalibTone(WHISparam);
RecordedCalibTone =  CalibTone;
% Batch�ł́ACalibTone���O������^���ł��Ȃ��̂ŁA�����Ƃ݂Ȃ��B(GUI�ł͈�v����悤�ɘ^�����邪�j
% �����̊m�F�ł́A������save���ꂽRecordedCalibTone��ǂݍ��ށB

[SrcSnd, WHISparam] = WHISv300_GetSrcSndNrmlz2CalibTone(SndLoad,RecordedCalibTone,WHISparam);

% WHISparam.RecordedCalibTone =  CalibTone;
% WHISparam.SndLoad = SndLoad;
% SrcSnd = WHISparam.SrcSnd; % calbration tone ��normalize���ꂽSrcSnd

%% %%%%%%%%%%%%%%%%
% ��̃p�����[�^�ݒ�
% default�l�͂Ȃ��ɂ���B--- WHISv300�ŁA�ݒ�Ȃ��̏ꍇerror���o��悤�ɂ����B
%%%%%%%%%%%%%%%%%%
[SndWHIS, WHISparam] = WHISv300(SrcSnd, WHISparam); 

return


%% %%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%


% if isfield(HISparam, 'AudiogramNum') == 0    % See GCFBv230_HearingLoss
%�@����  �p�����[�^�̖��O���܂ߗv�����@�@2021/2/14
%  HISparam.AudiogramNum = 3;  % �f�t�H���g ISO7029 70yr �j
% end
%if isfield(HISparam, 'getComp') == 0   %  ----- ���̃p�����[�^���A���܂�悭�Ȃ��BWHIS�Ŏd�؂蒼���\��B
%    HISparam.getComp = 0;  % �f�t�H���g ���k���� 0%
%end
% NumComp = find(HISparam.getComp == HISparam.Table_getComp);  %Comp��Table����


%%%   14 Feb 2021 ���݂Ŗ������̂܂܁B
%  ---  ���ԕ����򉻂��������邽�߁A������ɍs����


%%%%%%%%%%%%%%%%%%%%%%%%
% % default set
% if isfield(WHISparam, 'HLoss') == 0,
%     if isfield(HLoss,'Type') == 0,   % default
%         HLoss.Type = 'HL3';  %% --> line 81
%     end;
% end;
%
% if exist('EMparam') == 0;
%     if isfield(EMparam,'ReducedB') == 0,
%         EMparam.ReducedB = 0;
%     end
%     if isfield(EMparam,'Fcutoff') == 0,
%         EMparam.Fcutoff = 128;
%     end
% end
%
% HISparam.HLoss = HLoss;
% HISparam.EMparam = EMparam;
%
% %%  %%%%%%%%%%%%%%%%%%%%%%%
% % �������s�I
% % �ȉ��̓��e�F�@function Exec_HIsimFastGC(hObject, eventdata, handles)
% %  line 966
% %  �����́AHIsimFastGC�̃p�����[�^�ɓ���邾���Ȃ̂ŁA���̂܂�
% %%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HISparam.fs                                 = ParamHIbatch.fs;
% HISparam.SrcSndSPLdB             = ParamHIbatch.SrcSndSPLdB;  % normalize�Ɏg���Ă���
% HISparam.FaudgramList             = ParamHIbatch.FaudgramList;
% HISparam.DegreeCompression  = ParamHIbatch.DegreeCompression_Faudgram;
% HISparam.HLdB_LossLinear       = ParamHIbatch.HLdB_LossLinear;
% HISparam.HearingLevelVal         = ParamHIbatch.HearingLevelVal;             % 13 Dec 18 HIsimFastGC�Ŏg�p�@Gain�␳�̂���
% %  HISparam.HLdB_LossCompression = ParamHIbatch.HLdB_LossCompression; % 13 Dec18 ����͐ݒ�s�v�B HIsimFastGC�Ŏg��Ȃ��B
% HISparam.SwAmpCmpnst           = ParamHIbatch.SwAmpCmpnst;
% HISparam.AllowDownSampling = 1;
% [HIsimSnd, ~] = HIsimFastGC(ParamHIbatch.SrcSnd, HISparam); % calbration tone ��normalize���ꂽSrcSnd���g��
%
% HIsimSnd = HIsimSnd(:)'; %�s�x�N�g��

%% %%%%%%%%%%%%%%%%
% ��̃p�����[�^�ݒ�
%%%%%%%%%%%%%%%%%%
% default�l�͂Ȃ��ɂ���B--- WHISv300�ŁA�ݒ�Ȃ��̏ꍇerror���o��悤�ɂ����B
% if isfield(WHISparam.HLoss,'Type') == 0
%     WHISparam.HLoss.Type = 'HL3'; % �f�t�H���g ISO7029 70yr �j      --  HISparam.AudiogramNum
% end
%
% if isfield(WHISparam.HLoss,'CompressionHealth') == 0
%     WHISparam.HLoss.CompressionHealth = 0.5; % Initial value of compression  --  HISparam.getComp
% end


