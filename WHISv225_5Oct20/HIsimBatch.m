%
%   Batch execution function for HIsimFastGC    
%   Yomura, N.,  Okuya,Y.,  Yamauti,Y.,   Irino, T.
%   Created:     x Jun 18   % YO, YY from makeHIsimfile.m (by Yomura, N.,)
%   Modified:    7 Jul 18   % IT, function���ĂԂ悤�ɉ���
%   Modified:    7 Jul 18   % IT, ���O�ύX�@MkHIsimfile -> HIsimBatch
%   Modified:    8 Jul 18   % IT, debug
%   Modified:  11 Jul 18  % IT, debug
%   Modified:   6 Aug 18  % IT, ParamHIbatch���o��
%    Modified:  16 Oct 18 % IT,  HIsimFastGC_InitParamHI.m�̋L�q���኱�ύX�B
%    Modified:  17 Oct 18 % IT, ���p�@���L���BHIsimFastGC(ParamHIbatch.SrcSnd, HISparam);���m�F�B
%    Modified:  18 Oct 18 % IT, default�̃Z�b�e�B���O���֎~�F�K���w�肳����悤�ɁB�ԈႢ�h�~�B
%    Modified:  20 Oct 18  % IT, ParamHI.SwGUIbatch = 'GUI' or 'Batch'�̖����K�{��
%    Modified:  11 Dec 18 % IT, ParamHIbatch.AudiogramNum���ANaN�Ȃ�AParamHIbatch.HearingLevelVal�𒼐ڐݒ肷��
%    Modified:  12 Dec  18 % �ڍ׌����p
% 
%   function [HIsimSnd, SrcSnd] = HIsimBatch(SndIn, ParamHIbatch);
%   INPUT:  SndIn : input sound 
%           ParamHIbatch : parameters
%                        AudiogramNum : audiogram select (1~8�̐��l)
%                               help HIsimFastGC_InitParamHI�ŏo�Ă���ݒ�Q�Ƃ̂��ƁB
%                        getComp : compression percent value 
%                                           (0%, 33%, 50%, 67%, 100%�̐���)
%                        SPLdB_CalibTone : calibtone level    % �f�t�H���g 80dB
%                        SrcSndSPLdB : source_sound sound pressure level dB  % �f�t�H���g 65dB
%
%   OUTPUT: HIsimSnd : processed sound
%           SrcSnd : source sound  HIsim�ɓ��͂����M���Ȃ̂ŁASrcSnd�Ƃ������O
%           ParamHIbatch: �����̏ڍׂ��킩��悤�ɏo��
%
%   Note: ���p�@  17 Oct 18
%       Calbration tone ��digital level�ŁARMS = -26 dB �Ƃ��Čv�Z���Ă��܂��B
%       ���ׂĂ̎����ŁA����Calbration tone���g���čĐ����A�����ɂ��킹�����x���ōZ�����Ă��������B
%       1) HIsimFastGC_GUI�̏ꍇ�́A80dB�ōZ�����܂��B����́A�傫�Ȑ��������Ă��N���b�s���O���Ȃ��悤�ɁB
%               ���̏ꍇ�AParamHIbatchIn.SPLdB_CalibTone = 80; (default�l)�ł��B
%       2) ��������ŁACalbration tone��65dB�ɍ��킹���ꍇ�A
%               ParamHIbatchIn.SPLdB_CalibTone = 65; �ƂȂ�悤�Ɉ�����ݒ肵�Ă��������B
%
%        �w�i�F�v�Z�@�͐��l������m���Ă��܂��B���̐��l���O�E�ŉ�dB�ɂȂ邩��m��܂���B
%                  �����������̂��ACalbration tone�ɂ��Z���ł��B
%                  �Ή��Â��������Ƃł��Ă��Ȃ��ꍇ�A�v�Z�@�̓��������͊ԈႦ�܂��B
%
%
function [HIsimSnd,SrcSnd,ParamHIbatch] = HIsimBatch(SndIn, ParamHIbatchIn) 

[mm, nn] = size(SndIn);
if min(mm, nn)  > 1,
    error('���m�������͂����邱�ƁB�����̍ہA�ԈႦ�Ȃ��悤�ɂ��邽�߁B');
    return;
end;
SndIn = SndIn(:)'; % �s�x�N�g��

%%  %%%%%%%%%%%
% �����ݒ�  'batch'�𖾎��B�@GUI�ł�����InitParamHI���g�����A�����'GUI'�ŗ��p�B
%%%%%%%%%%%%%%%%%
ParamHIbatchIn.SwGUIbatch = 'Batch';
ParamHIbatch = HIsimFastGC_InitParamHI(ParamHIbatchIn);

%% %%%%%%%%%%%%%%%%%
% �������x�����킹
%%%%%%%%%%%%%%%%%%%%
disp(['SPLdB_CalibTone = '  num2str(ParamHIbatch.SPLdB_CalibTone) ' (dB)']);
disp(['SrcSndSPLdB = '  num2str(ParamHIbatch.SrcSndSPLdB) ' (dB)']);

[CalibTone, ParamHIbatch]  = HIsimFastGC_MkCalibTone(ParamHIbatch);
ParamHIbatch.RecordedCalibTone =  CalibTone; 
    % Batch�ł́A�^���ł��Ȃ��̂ŁA�����Ƃ݂Ȃ��B
    % �����̊m�F�ł́A������save���ꂽRecordedCalibTone��ǂݍ��ށB
ParamHIbatch.SndLoad = SndIn;
 [ParamHIbatch] = HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHIbatch);
 SrcSnd = ParamHIbatch.SrcSnd; % calbration tone ��normalize���ꂽSrcSnd

%% %%%%%%%%%%%%%%%%
% ��̃p�����[�^�ݒ�
%%%%%%%%%%%%%%%%%%
if isfield(ParamHIbatchIn, 'AudiogramNum') == 0
    ParamHIbatch.AudiogramNum = 3;  % �f�t�H���g ISO7029 70yr �j
end
if isfield(ParamHIbatchIn, 'getComp') == 0
    ParamHIbatch.getComp = 0;  % �f�t�H���g ���k���� 0%
end;
% ParamHIbatch.getComp
NumComp = find(ParamHIbatch.getComp == ParamHIbatch.Table_getComp);  %Comp��Table����


if isnan(ParamHIbatch.AudiogramNum) == 0, %NaN�ȊO�Ȃ�AHearingLevelList����ݒ�B
    ParamHIbatch.HearingLevelVal = ParamHIbatch.HearingLevelList(ParamHIbatch.AudiogramNum,:);
else   % ParamHIbatch.AudiogramNum���ANaN�Ȃ�A���ڐݒ肷��B�@11 Dec 2018
   % ParamHIbatch.HearingLevelVal�̒l�������Ă��邱�Ƃ��O��
    if length(ParamHIbatch.HearingLevelVal) == length(ParamHIbatch.FaudgramList), %���������`�F�b�N
        disp('Set CalDegreeParamHIbatch.HearingLevelVal as ');
        disp(ParamHIbatch.HearingLevelVal);
    else
        error('Something wrong with ParamHIbatch.HearingLevelVal');
    end;
end;

ParamHIbatch.HLdB_LossCompression = ...
    min(ParamHIbatch.HearingLevelVal, ...
           ParamHIbatch.Table_HLdB_DegreeCompressionPreSet(NumComp,:));
ParamHIbatch.HLdB_LossLinear  = ParamHIbatch.HearingLevelVal - ParamHIbatch.HLdB_LossCompression;

HL_LossComp_LossLin = [
    ParamHIbatch.HearingLevelVal;
    ParamHIbatch.HLdB_LossCompression;
    ParamHIbatch.HLdB_LossLinear;
    ];
disp('HL; Loss Compression; Loss Linear');
disp(HL_LossComp_LossLin);
[nn mm] = size(HL_LossComp_LossLin);
if  nn ~= 3,
    error('Something wrong with HL_LossComp_LossLin  --> Check NumComp');
end;

ParamHIbatch = HIsimFastGC_CalDegreeCmprsLin(ParamHIbatch);

%% level�ɂ��Č����B

%ParamHIbatch
%ParamHIbatch.DegreeCompression_Faudgram
%ParamHIbatch.HLdB_LossCompression
%ParamHIbatch.HLdB_LossLinear


%pause
%



%%  %%%%%%%%%%%%%%%%%%%%%%%
% �������s�I
% �ȉ��̓��e�F�@function Exec_HIsimFastGC(hObject, eventdata, handles)
%  line 966
%  �����́AHIsimFastGC�̃p�����[�^�ɓ���邾���Ȃ̂ŁA���̂܂�
%%%%%%%%%%%%%%%%%%%%%%%%%%

HISparam.fs                                 = ParamHIbatch.fs;
HISparam.SrcSndSPLdB             = ParamHIbatch.SrcSndSPLdB;  % normalize�Ɏg���Ă���
HISparam.FaudgramList             = ParamHIbatch.FaudgramList;
HISparam.DegreeCompression  = ParamHIbatch.DegreeCompression_Faudgram;
HISparam.HLdB_LossLinear       = ParamHIbatch.HLdB_LossLinear;
HISparam.HearingLevelVal         = ParamHIbatch.HearingLevelVal;             % 13 Dec 18 HIsimFastGC�Ŏg�p�@Gain�␳�̂���
%  HISparam.HLdB_LossCompression = ParamHIbatch.HLdB_LossCompression; % 13 Dec18 ����͐ݒ�s�v�B HIsimFastGC�Ŏg��Ȃ��B
HISparam.SwAmpCmpnst           = ParamHIbatch.SwAmpCmpnst;
HISparam.AllowDownSampling = 1;
[HIsimSnd, ~] = HIsimFastGC(ParamHIbatch.SrcSnd, HISparam); % calbration tone ��normalize���ꂽSrcSnd���g��

HIsimSnd = HIsimSnd(:)'; %�s�x�N�g��

return;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% �ȉ��̕����F
% function HIsimFastGC_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% �O���֐��Ƃ��Ē�`

%  function LoadSound_Callback

%% %%%%%%%%%%%%%%%%%%%%%%%
% function GetSrcSndNrmlz2CalibTone(SndIn)
%%%%%%%%%%%%%%%%%%%%%%%%%%
% RMSlevel_SndIn = sqrt(mean(SndIn.^2));
% RMSlevel_CalibTone = sqrt(mean(ParamHIbatch.RecordedCalibTone.^2));
% AmpdB1 = (ParamHIbatch.SrcSndSPLdB - ParamHIbatch.SPLdB_CalibTone); 
% Amp1   = 10^(AmpdB1/20)*RMSlevel_CalibTone/RMSlevel_SndIn;
% ParamHIbatch.SrcSnd = Amp1*SndIn;
% SrcSnd = ParamHIbatch.SrcSnd;
% disp(Amp1);


%% %%%%%%%%%%%%%%%%
%  DrawAudiogram�̈ꕔ�B�@line 1135������.
%%%%%%%%%%%%%%%%%%
%ParamHIbatch.HLdB_LossLinear�����߂Ă�
%if isfield(ParamHIbatch, 'getComp') == 0
%    ParamHIbatch.getComp = 0;  % �f�t�H���g ���k���� 0%
%    ParamHIbatch.DegreeCompressionPreSet = 0;
%else
%    if     ParamHIbatch.getComp == 100, ParamHIbatch.DegreeCompressionPreSet = 1;
%    elseif ParamHIbatch.getComp == 67,  ParamHIbatch.DegreeCompressionPreSet = 2/3;
%    elseif ParamHIbatch.getComp == 50,  ParamHIbatch.DegreeCompressionPreSet = 0.5;
%    elseif ParamHIbatch.getComp == 33,  ParamHIbatch.DegreeCompressionPreSet = 1/3;
%    elseif ParamHIbatch.getComp == 0,   ParamHIbatch.DegreeCompressionPreSet = 0;
%    end;
%end
