%
%     HIsimFastGC_GUI ��ParamHI�������ݒ肷��
%     Irino, T.
%     Created:   7 Jul  2018
%     Modified:  7 Jul  2018
%     Modified: 11 Jul 2018 (ParamHI_Input���󂯎��p���ł���悤�Ɂj
%     Modified:  5 Aug 2018 (ParamHI_Input���󂯎��p���B�㏑���̃o�O�C���j
%     Modified: 16 Oct 2018 �i�d�v�Ȃ̂ŉ����ݒ���v���O�����̏�Ɏ����Ă��āA���₷���j
%     Modified: 18 Oct 2018 (default�̃Z�b�e�B���O���֎~�F�K���w�肳����悤�ɁB�ԈႢ�h�~�B�j
%     Modified:  20 Oct 2018  (IT, ParamHI.SwGUIbatch = 'GUI' or 'Batch'�̖����K�{��)
%     Modified:  27 Dec 2018  (IT, �o�Ofix)
%     Modified:  19 Dec 2019  (IT, ParamHI.SrcSndSPLdB_default����)
%     Modified:   6  Mar 2022   WHISv300_func --> WHISv30_func 
%  
%     ParamHI.AudiogramNum : audiogram select
%                 1.example 1
%                 2.����2002 80yr
%                 3.ISO7029 70yr �j
%                 4.ISO7029 70yr ��
%                 5.ISO7029 60yr �j
%                 6.ISO7029 60yr ��
%                 7.���d����(�悭�킩��I�[�W�I�O����p.47)
%                 8.�������(�悭�킩��I�[�W�I�O����p.63)
%                 9.�蓮���́@manual input%
%
%
function ParamHI = WHISv30_InitParamHI(ParamHI_Input)

if nargin < 1
    error('paramHI_Input�͕K�{�p�����[�^.');
end
ParamHI = ParamHI_Input;

ParamHI.SwKeepSnd = 1;  % keep sound for debugging
% ParamHI.SwKeepSnd = 0;  % no keeping sound 

%%  %%%%%%%%%%%%%%%%%%%%%%%%
% Calibration tone�̉����ݒ�  18Oct18
%  �f�B�W�^��RMS���x��-26dB��1 kHz��sin�g[Sin1kHz-26dB]���Đ��������̉����������Őݒ�
%  CalibTone��[Sin1kHz-26dB]�ł͂Ȃ��ꍇ�́A[Sin1kHz-26dB]�ɑΉ����鉹�����v�Z���Đݒ�.
%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(ParamHI.SwGUIbatch,'GUI') == 1   % GUI�ł̏ꍇ 
    % �ύX�������ꍇ�͗v���k
    % ���̒l�́A�傫�Ȑ���GUI�łɘb���������ꍇ�ł�clipping���Ȃ��悤�Ȑݒ��ڎw�����B
    % ParamHI.SPLdB_CalibTone�̒l��70�ior����ȉ��j�Ƃ����clipping�̋��ꂪ�傫���B
    ParamHI.SPLdB_CalibTone = 80; % �o������̐ݒ�l�@-- GUI����ύX�ł��Ȃ�
    ParamHI.SrcSndSPLdB_default = 65;        % ����LoadSound���鎞��default�l�@19Apr19
    ParamHI.SrcSndSPLdB = ParamHI.SrcSndSPLdB_default;  
        %   �ォ��GUI�ŕύX�\�@19 Apr 19
        %   �Z����Calibration tone��^�Đ�����ƁAParamHI.SrcSndSPLdB��
        %   ParamHI.SPLdB_CalibTone�Ɠ����ɂȂ��Ă��܂��B�@�[�[��   �l�͕ʂɐ��䂵�����B
    
elseif   strcmp(ParamHI.SwGUIbatch,'Batch') == 1 % Batch�ł̏ꍇ  
    %  default�l�͖����B�K���w�肷�邱�ƁB
    if isfield(ParamHI,'SPLdB_CalibTone') == 0
        % �f�B�W�^�����x���ƊO�E�̉����Ƃ̑Ή��t��������B
        %        �����F ParamHI.SPLdB_CalibTone = 80; default�l���֎~
        % disp('      - HIsimFastGC_MkCalibTone(ParamHI); �� ParamHI.CalibTone_RMSDigitalLeveldB==-26');
        %  Modified:  18 Oct 18 (default�̃Z�b�e�B���O���֎~�F�K���w�肳����悤�ɁB�ԈႢ�h�~�B�j
        warning('*********  Error **************');
        disp('ParamHI.SPLdB_CalibTone  ���w�肷��悤��. (default�͖���)');
        disp('�f�B�W�^��RMS���x��-26dB��1 kHz��sin�g[Sin1kHz-26dB]���Đ��������̉����������Őݒ�');
        disp('      - ��������ł́AParamHI.SrcSndSPLdB�Ɠ����ɂ��邱�Ƃ������ƍl������.');
        disp('      - ParamHI.SPLdB_CalibTone = 65  ���炢�Ǝv����. �����̒񎦉����̐ݒ肩��.');
        disp('      - CalibTone��[Sin1kHz-26dB]�ł͂Ȃ��ꍇ�́A[Sin1kHz-26dB]�ɑΉ����鉹�����v�Z���Đݒ�.');
        error('�ݒ�G���[.   ��L�̋L�q���Q�l�ɐݒ肷�邱��.');
    end;
    if isfield(ParamHI,'SrcSndSPLdB') == 0
        % SrcSnd��RMS���x����ݒ�
        %    �����F ParamHI.SrcSndSPLdB = 65; default�l�͋֎~
        warning('*********  Error **************');
        disp('ParamHI.SrcSndSPLdB  ���w�肷��悤��. (default�͖���)');
        disp('     - ParamHISrcSndSPLdB = 65  ���炢�Ǝv����. �����̒񎦉����̐ݒ肩��.');
        error('�ݒ�G���[.   SrcSnd��RMS�������x����ݒ肷�邱��.');
    end;

else
    error('Specify ParamHI.SwGUIbatch :  "GUI" or  "Batch".');
end   %if strcmp(ParamHI.SwGUIbatch,'GUI') == 1

StrSPL =  int2str(ParamHI.SPLdB_CalibTone);
ParamHI.CalibTextLabel   = cellstr([{['Set to ' StrSPL ' dB']}, {[ StrSPL ' dB�ɐݒ�']}]);  


%% %%%%%%%%%%%%%%%%%%%%%%%%
% HIsimFastGC�̏o�͒����p�p�����[�^�B12 Dec 2018 
%  HISparam.SwAmpCmpnst = 1;  % orginal method (4 Feb 2014)
%  orginal method�ɂ���ꍇ�A�O������HISparam.SwAmpCmpnst = 1�Ǝw�肷�邱�ƁB
%  HIsimFastGC.m �iHISparam <-- ParamHI �j -- Line 178�ȍ~���Q�ƁB
%  ParamHI.SwAmpCmpnst = 1;  % orginal method, 4 Feb 2014
%  ParamHI.SwAmpCmpnst = 2;  % Table lookup   12 Dec 2018 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(ParamHI,'SwAmpCmpnst')  == 0,
    % default�́A�V�K�ݒ�ŁB12 Dec 2018  
    ParamHI.SwAmpCmpnst = 2;  % default  �[�[�@Table lookup   12 Dec 2018  
end


%%  %%%%%%%%%%%%%%%%%%%%%%%%
% audiogram�̏��ݒ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
ParamHI.fs = ParamHI_Input.fs;   % bug fix 27 Dec 18
ParamHI.Nbits = 24; % set bits here

ParamHI.FaudgramList = 125*2.^(0:6);              %[125 250 500, 1000, 2000, 4000, 8000]
ParamHI.DegreeCompression_Faudgram = [0 0 0 0 0 0 0];
ParamHI.HLdB_LossLinear = [0 0 0 0 0 0 0];

%��̃p�����[�^
ParamHI.HL_ISO7029_Ex = [ 8  8  9 10 19 43 59; ... % ISO7029 70yr �j
                             8  8  9 10 16 24 41; ... % ISO7029 70yr ��
                             5  5  6  7 12 28 39; ... % ISO7029 60yr �j
                             5  5  6  7 11 16 26; ... % ISO7029 60yr ��
                           ];
ParamHI.HL_Tsuiki2002_80yr = [ 23.5, 24.3, 26.8, 27.9, 32.9, 48.3, 68.5]; % ����2002�@80yr ����
                       
ParamHI.HearingLevelList = [10  4 10 13 48 58 79; ...  %example 1
                               ParamHI.HL_Tsuiki2002_80yr; ...  % ����2002�@80yr
                               ParamHI.HL_ISO7029_Ex; ... % ISO7029  4���
                               50 55 50 50 40 25 20; ...%���d����(�悭�킩��I�[�W�I�O����p.47)
                               15 10 15 10 10 40 20; ...%�������(�悭�킩��I�[�W�I�O����p.63)
                               NaN*ones(1,7)];  % �蓮���́@manual input -- ����͕K��List�̍ŏI�i�ɒu�����ƁB

ParamHI.Table_AudiogramName = {'Ex1', ...
                                '80yr_Male','70yr_Male', '70yr_Female', ...
                                '60yr_Male', '60yr_Female', ...
                                'Otosclerosis', 'C5Dip', 'Manual'};  % �Ή����ԈႢ�Ȃ��悤�ɁB

% ������������悤�ɏ������Ɓ@{�p��}{���{��}
%�\�����x���^����̐ݒ�@�̂Ƃ���Ŏg�p�B
ParamHI.SetAdgmList = cellstr([...
                                {'Set Audiogram'},   {'-- �I�� --'}; ...
                                {'Example HI#1'},    {'��� ��1'};...
                                {'80yr Ave (Tsuiki2002)'},  {'80�� ���� (����2002)'};...
                                {'70yr Male (ISO7029)'},  {'70�� �j (ISO7029)'};...
                                {'70yr Female (ISO7029)'}, {'70�� �� (ISO7029)'};...
                                {'60yr Male (ISO7029)'},  {'60�� �j (ISO7029)'};...
                                {'60yr Female (ISO7029)'}, {'60�� �� (ISO7029)'};...
                                {'Otosclerosis'},    {'���d����'}; ...
                                {'Noise-induced'},   {'������� (C5dip)'}; ...
                                {'Manual'},          {'�蓮�ݒ�'}]);

[ParamHI.LenHLlist, ParamHI.LenFagrm] = size(ParamHI.HearingLevelList);                    

ParamHI.Table_getComp  = [100; 67; 50; 33; 0]; % GUI���̕\���l
ParamHI.Table_DegreeCompressionPreSet     = [1; 2/3; 0.5; 1/3; 0]; % �\���l�ɑΉ�����{���̒l�B

% AsymFunc���狁�߂��l�BHL_OHC�͂���ŋ��߂Ă���̂ŁA������g�����ƁB2021/10/12
ParamHI.Table_HLdB_DegreeCompressionPreSet =  [ ...
   34.0000   19.6000    9.7000    4.9000    0.5000    5.4000    3.3000
   38.8566   30.6594   25.6976   22.1259   18.0419   23.8148   21.4690
   40.9698   34.9736   32.1693   29.7996   26.3673   32.4441   30.0962
   42.9096   38.6140   37.4731   36.3657   33.5918   39.5464   37.7582
   46.3609   44.4196   45.0619   45.1542   43.6208   48.4398   47.2515];
%[125,            250,         500,       1000,        2000,       4000,        8000]

% �Q�l�F�@Excitation Pattern���狁�߂��l--- �����̂Ŏg��Ȃ��@2021/10/12
% % ParamHI.Table_HLdB_DegreeCompressionPreSet =  [ ...
% %    31.8363   20.8795   13.8731    8.8031    5.0338    8.9894    6.7375
% %    37.9442   31.4894   27.2266   24.3747   21.4198   25.7097   23.6013
% %    40.9350   36.2026   33.4542   31.5527   28.8478   33.3300   31.5149
% %    43.7049   40.6990   39.0911   37.8499   35.8477   40.5115   38.6931
% %    49.7644   48.1142   47.9531   47.8415   46.4644   50.6869   49.4502];
% % %[125,            250,         500,       1000,        2000,       4000,        8000]
  

if ParamHI.SwAmpCmpnst == 2
    % 
    % ParamHI.Table_HLdB_DegreeCompressionPreSet�́A0dB HL����̒l�ɂ���B
    % �v�Z���킩��ɂ����A������HL 0dB����̕��������I�B   
    ParamHI.Table_HLdB_DegreeCompressionPreSet = ...
        ParamHI.Table_HLdB_DegreeCompressionPreSet - ...
        ones(5,1)*ParamHI.Table_HLdB_DegreeCompressionPreSet(1,:);  
end


%% %%%%%%%%%%%%
% ���̂ق��̐ݒ�
%%%%%%%%%%%%%%%
%���ĉ������b�����p�̐ݒ�BLoadSound���g��Ȃ��悤�ɂ���B
ParamHI.SwNoLoadSound4Exp = 0; % �ʏ탂�[�h
%ParamHI.SwNoLoadSound4Exp = 1; % ���ĉ������b�����p

return

end





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% HIsimGCFBv225�ł͈ȉ��̒l�������B
%
% aaa =  [ ...
%    -6.7406    2.4563      4.7537      5.7118    1.0655    -3.4335   -7.2814; ...
%    -0.3463   10.0101   17.8573   19.9751   16.8954   14.5161    5.1201; ...
%     2.5999   14.3605   23.7777   26.8029   24.7069   23.5780   10.6923; ...
%     5.4801   18.5666   28.9101   32.6974   31.2244   30.0204   16.0619; ...
%    10.5790   24.9903   36.0186   40.5679   38.9283   36.5154   25.2229];
% % % %[125,            250,         500,       1000,        2000,       4000,        8000]
% 
% 1��ڂ���̍���
% aaa-ones(5,1)*aaa(1,:) = [...
%          0         0         0         0         0         0         0
%     6.3943    7.5538   13.1036   14.2633   15.8299   17.9496   12.4015 ...
%     9.3405   11.9042   19.0240   21.0911   23.6414   27.0115   17.9737 ...
%    12.2207   16.1103   24.1564   26.9856   30.1589   33.4539   23.3433 ...
%    17.3196   22.5340   31.2649   34.8561   37.8628   39.9489   32.5043 ]; 
% 

% WHISv300�̏ꍇ
%
% % ParamHI.Table_HLdB_DegreeCompressionPreSet =  [ ...
% %    31.8363   20.8795   13.8731    8.8031    5.0338    8.9894    6.7375
% %    37.9442   31.4894   27.2266   24.3747   21.4198   25.7097   23.6013
% %    40.9350   36.2026   33.4542   31.5527   28.8478   33.3300   31.5149
% %    43.7049   40.6990   39.0911   37.8499   35.8477   40.5115   38.6931
% %    49.7644   48.1142   47.9531   47.8415   46.4644   50.6869   49.4502];
% % %[125,            250,         500,       1000,        2000,       4000,        8000]
%
% 1��ڂ���̍���
%          0         0         0         0         0         0         0
%     6.1079   10.6099   13.3535   15.5716   16.3860   16.7203   16.8638
%     9.0987   15.3231   19.5810   22.7497   23.8140   24.3406   24.7773
%    11.8686   19.8195   25.2180   29.0468   30.8139   31.5221   31.9556
%    17.9281   27.2347   34.0800   39.0384   41.4306   41.6975   42.7127


%%  %%%%%%%%%%%%%%%%%%%%%%%%
% Calibration tone�̉����ݒ�
%
% 2016�i�K�F
% default 70dB  NH�Ȃ炱�̒��x���ǂ��͂��B
% ParamHIGUI.SPLdB_CalibTone = 70; % This should be 70 dB for NH listeners.
%
% �ύX,  12 Jun 2017
% HI simulator GUI�ł�Calibration tone�̉����ݒ�: default 80dB�ɁB
% Mic���͎��́Adigital level�̃_�C�i�~�b�N�����W�̖�肩�炱����ɕύX�B
% -26dB RMS��1 kHz sin�g(FS���Z����-23dB)���@80 dB�ɁB
%   in function PlayCalibTone_Callback(hObject, eventdata, handles)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% �������F�����ISO7029�ł͂Ȃ�    10 15 15 15 25 35 43; ...  % 60yrs
% �������F�����ISO7029�ł͂Ȃ�    25 30 32 28 38 50 60; ...  % 80yrs
% ParamHIGUI.SwCalibTone = 1;
% OutLeveldB = -26;
% AmpCalib   = 10^(OutLeveldB/20)*sqrt(2); % set about the same as recording level
%
