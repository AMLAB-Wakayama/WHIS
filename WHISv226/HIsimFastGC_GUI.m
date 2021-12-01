function varargout = HIsimFastGC_GUI(varargin)
%
% HI simulator with GUI.   HL_total = HL_OHC + HL_IHC
% Misaki Nagae, Irino T.
%
% Created: Dec 2013
% Modified: 23 Apr 2014 (NM, Play sound if pressed Loadbutton)
% Modified: 16 Apr 2014 (NM, Radio button)
% Modified: 22 Jan 2014 (NM)
% Modified: 27 Jan 2014 (IT)
% Modified: 28 Jan 2014b (IT)
% Modified:  1 Feb 2014b (IT, _Callback   paramHI--> ParamHIGUI)
% Modified:  2 Feb 2014b (IT, SPL)
% Modified:  3 Feb 2014a (IT, DegreeCompression)
% Modified:  4 Feb 2014  (IT, Almost done)
% Modified:  5 Feb 2014  (IT, small mod)
% Modified:  7 Feb 2014  (IT, Play previous sounds)
% Modified: 15 May 2014  (MN, checked but no need to use EqlzDigitalLevel)
% Modified: 21 Jun 2014  (IT, load sound -> playback equalized sound)
% Modified: 11 Nov 2014  (IT, edit few lines)
% Modified: 15 Nov 2014  (IT, keep sound file name, Nbits)
% Modified: 18 Nov 2014  (IT, adding note on level this program vs. Meddis HC)
% Modified: 21 Nov 2014  (IT, spelling Cmps->Cmprs)
% Modified:  8 May 2015  (IT, AllowDownSampling = 1 when fs > 44000)
% Modified: 14 May 2015  (IT, SwKeepSnd==0)
% Modified:  9 Jun 2015  (NM, Added RecButton & RecReplay)
% Modified: 15 Jun 2015  (NM, function moveWhileMouseUp)
% Modified: 17 Jun 2015  (NM, added axes1's setting when Manual is chosen : function DrawAudiogram)
% Modified:  9 Jul 2015  (NM, mouse dragging : added function myBDCallback, myBMCallback, myBUCallback in function MouseDraggedAdgm_Callback)
% Modified: 23 Jul 2015  (NM, myBMCallback, Cp(1,2) range: -20 < Cp < 80)
% Modified: 23 Jul 2015  (NM, deleted 'slider')
% Modified: 28 Jul 2015  (NM, improved Record Button, added handles.RecBtnCnt)
%                        (NM, text size (audiogram labels))
% Modified: 24 Aug 2015  (NM, handles.RecObj (1ch))
% Modified: 28 Aug 2015  (NM, added 'Enable': Can't manipilate while recording)
%                        (NM, imread RecButton)
% Modified: 31 Aug 2015  (NM, add handles.HIsimCnt, changed NameSuffix)
%                        (NM, ParamHIGUI.SwKeepSnd == 1 on)
% Modified: 13 Sep 2015  (IT, modify DegreeCompression .Table_HLdB_AbsThresh_simHI-> .Table_HLdB_DegreeCompression)
% Modified:  9 Oct 2015  (NM, deleted function Updateplot)
% Modified:  5 Nov 2015  (NM, mouse dragging comp's Audiogram during pressing the Shift key : ParamHIGUI.GUI.KeyPress(function myBMCallback))
% Modified: 12 Nov 2015  (NM, radiobutton -> popup menu(Audiogram, Compression, SPLdB))
%                        (NM, Deleted GetDegreeCompression)
% Modified: 19 Nov 2015  (NM, Deleted Radiobutton)
% Modified:  5 Dec 2015, (NM, Enable to use editCmp1~7)
% Modified:  9 Jul 2016, (IT, Major revison. Introducing calibration tone )
% Modified: 11 Jul 2016, (IT, Sound Name  )
% Modified:  1 Sep 2016, (IT, ParamHIGUI.SwNoLoadSound4Exp = 1 )
% Modified:  9 Sep 2016, (IT, ParamHIGUI.RecordedCalibTone �L�����u���[�V�����Ř^����������������Ƃ��� )
% Modified: 10 Sep 2016, (IT, GUI�܂��̃{�^��Enable on/off���� )
% Modified: 18 Mar 2017, (IT, Audiogram�A80�΂�ISO7029�ł͂Ȃ������B�����K�i�ɂ��킹��ύX�B )
% Modified: 11 Apr 2017, (IT, �X�y���~�X�C�� )
% Modified: 12 Jun 2017, (IT, ����AudiologyJapan45, pp.241-250,2002, 80�΃f�[�^�̓���  ParamHIGUI.HL_Tsuiki2002_80yr)
%                        (IT, Calibration tone: -26 dB RMS ��sin�g��80 dB SPL�Ƃ����B70dB���ƁAMic���͂ŐU��؂�\������B)
% Modified: 15 Jun 2017, (IT,  debug. AudiogramNameList = {'Ex1', '80yr_Ave', ...,  GUIDE�ł̃|�b�v�A�b�v���ύX)
% Modified: 17 Jun 2017, (IT,  debug.���؂�Tsuiki�B���̕ύX)
% Modified: 26 Oct 2017, (IT,  Working Directory ~/tmp�̐ݒ�Ɋւ���error���� + CalibTone �Q�x�����֎~�����B)
% Modified:  7  Jul  2018  (IT,  �O���֐����Q�Ƃ���悤�ɉ��ǁBBatch�ł��g����悤�ɁB)
% Modified:  13  Jul 2018  (IT,  UI control�̃o�O�C���B)
% Modified:   5  Aug 2018  (IT, line1056�s�ځAhandles.popupSPLdB�̃o�O�C���B)
% Modified:  20 Oct 2018  % IT, ParamHI.SwGUIbatch = 'GUI' �̖����K�{�� (�o�b�`�ł� 'Batch')
% Modified:   8  Dec 2018  % IT, GUI�̉��P�@�iPlay���̐F�\���ύX�BManual����cmprs��\��, �������s���𓱓��j
% Modified:   9  Dec 2018  % IT, GUI�Ɋ֘A������̂����A"ParamHIGUI.GUI." �ɂ܂Ƃ߂�B�����Ȃ��悤
% Modified:  11 Dec 2018  % IT, 
% Modified:  13 Dec 2018  % IT, 
% Modified:  12 Jan 2019  % IT,  SetWorkingDirectory�Ō��ߑł���Dir�����BWindows�Ή��B
% Modified:  12 Apr 2019  % IT,  guide��figure��resize�ł���悤�ɕύX
% Modified:  18 Apr 2019  % IT,  debug ispc �̂Ƃ���A�X�y�[�X���]�v�������B
% Modified:  19 Apr 2019  % IT,  ParamHI.SrcSndSPLdB_default���� in  HIsimFastGC_InitParamHI
% Modified:  22 Apr 2019  % KF,  GUI��windows�p�ɒ����Bfigure�̃T�C�Y�ύX�ɔ����ĕ����T�C�Y���ύX�B
% Modified:  2  May 2019  % KF,  taskkill�R�}���h��p���āA�o�b�O�O�����h�œ��삵��������ɑΏ�
% Modified:  9  May 2019  % IT, pc�����ŁAtaskkill�����s�����悤�ɕύX�B�֐���process_closereq�ɁB
% Modified:  23  Jul 2019  % IT, debug in HIsimFastGC_GetSrcSndNrmlz2CalibTone
% Modified:   7 Feb  2020  % function process_closereq(src,callbackdata)����Process�����R���p�C�����̖��O����v������
%
%
% HIsimFastGC_GUI MATLAB code for HIsimFastGC_GUI.fig
%      HIsimFastGC_GUI, by itself, creates a new HIsimFastGC_GUI or raises the existing
%      singleton*.
%
%      H = HIsimFastGC_GUI returns the handle to a new HIsimFastGC_GUI or the handle to
%      the existing singleton*.
%
%      HIsimFastGC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HIsimFastGC_GUI.M with the given input arguments.
%
%      HIsimFastGC_GUI('Property','Value',...) creates a new HIsimFastGC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HIsimFastGC_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HIsimFastGC_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HIsimFastGC_GUI

% Last Modified by GUIDE v2.5 10-Sep-2016 16:57:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @HIsimFastGC_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @HIsimFastGC_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end



%% Start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before HIsimFastGC_GUI is made visible.

function HIsimFastGC_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
global ParamHIGUI
ParamHIGUI = []; % initialize
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HIsimFastGC_GUI (see VARARGIN)

%�摜�ǂݍ���
%load�{�^���ɉ摜���ߍ���
%imdata = imread('btn_orange.png');
%imsize = size(imdata);


% Choose default command line output for HIsimFastGC_GUI
handles.output = hObject;

%GUI�̃N���[�Y�{�^�����������ۂ̏���
%Windows10�ł́A�ʏ�I������o�b�O�O���E���h��œ��삵�����邽��taskkill�őΏ�
set(handles.output,'CloseRequestFcn',@process_closereq);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% �����ݒ�
ParamHIGUI.SwGUIbatch = 'GUI';
ParamHIGUI.fs = 48000; % GUI�ł�48000 Hz�Ŏ��s
ParamHIGUI = HIsimFastGC_InitParamHI(ParamHIGUI);
ParamHIGUI.GUI.ColorTextMessage = [0.8471, 0.1608, 0] ;  % Orange:  Message
ParamHIGUI.GUI.ColorTextPlay      = [0 0 1];  % Blue : Playback
ParamHIGUI.GUI.ColorTextButton = [0 0 0];  % black



%% �O���t�̐ݒ�i�I�[�W�I�O�����j
% FreqList = [125 250 500 1000 2000 4000 8000];
plot(handles.axes1,[-1 8], [0 0], 'k', 'linewidth', 1.5);
axis square;%�����`��
set(handles.axes1, 'Xlim', [0.5 length(ParamHIGUI.FaudgramList)+0.5])
set(handles.axes1, 'XGrid', 'On')
set(handles.axes1, 'XTick', 1:length(ParamHIGUI.FaudgramList));
set(handles.axes1, 'XTickLabel',ParamHIGUI.FaudgramList');
set(handles.axes1, 'XAxisLocation','top');
set(handles.axes1, 'Box','on');
set(handles.axes1, 'FontUnits', 'normalized'); %�t�H���g���E�B���h�E�ɍ��킹�ăT�C�Y�ύX 16 Apr 2019, KF
set(handles.axes1, 'FontName', '���C���I'); %�t�H���g���E�B���h�E�ɍ��킹�ăT�C�Y�ύX 16 Apr 2019, KF
set(handles.axes1, 'FontSize', 0.035); %'16'->'0.035' 16 Apr 2019, KF
%xlabel('Frequency (Hz)', 'FontSize', 12)
xlabel('Frequency (Hz)', 'FontUnits', 'normalized','FontName', '���C���I', 'FontSize', 0.035) %normalized�w��ɕύX 16 Apr 2019, KF
%ylabel('Hearing Level (dB)', 'FontSize', 12)
ylabel('Hearing Level (dB)','FontUnits', 'normalized','FontName', '���C���I', 'FontSize', 0.035) %normalized�w��ɕύX 16 Apr 2019, KF
set(handles.axes1, 'Ylim', [-20 120])% 80 -> 120 23 Jul 15, NM
set(gca,'YDir','reverse')
set(handles.axes1, 'YGrid', 'On')
set(gca, 'YTick', [-20:10:120]);
set(gca, 'GridLineStyle', '-');
hold on % essential

set(handles.TextStatus,  'String', 'Initialized'); % set status
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);
set(handles.PlaySource,   'Visible','off'); % Play Source
set(handles.PlayHIsim,    'Visible','off'); % set source sound 70dB SPL
set(handles.PlayHIsimPrev,'Visible','off');  % PlayHIsim
set(handles.PlayHIsimPrev2,'Visible','off');  % PlayHIsim


if isfield(ParamHIGUI.GUI,'NameSndLoad') == 0
    set(handles.LoadText, 'String', 'No sound data');
else
    set(handles.LoadText, 'String', ParamHIGUI.GUI.NameSndLoad);
end;

if isfield(ParamHIGUI,'HearingLevelVal') == 1,
    DrawAudiogram(hObject, eventdata, handles);
end;


%�I�[�W�I�O�����h���b�O����p�̃p�����[�^ 5Nov15, NM
ParamHIGUI.GUI.KeyPress = 0;
%�^���{�^���p�̃J�E���^ 28Jul15, NM
handles.RecBtnCnt = 0;
ADInfo = audiodevinfo;
% if isfield(ADInfo, 'input') == 0
% end
%disp(ParamHIGUI.ADInfo.input)
%Processing�̉񐔃J�E���^ 31Aug15, NM
handles.HIsimCnt = 1;
%�{�^���摜�ǂݍ��� 28Aug15, NM
[STOP, map1] = imread('STOP.png');
[REC, map2]  = imread('REC.png');
[Play, map3] = imread('Play.png');
[Save, map4] = imread('Save.png');
handles.STOPrgb = ind2rgb(STOP, map1);
handles.RECrgb = ind2rgb(REC, map2);
handles.Playrgb = ind2rgb(Play, map3);
handles.Savergb = ind2rgb(Save, map4);
set(handles.RecordButton,'CData', handles.RECrgb);
set(handles.RecReplay,   'CData', handles.Playrgb);
set(handles.SaveRecSnd,  'CData', handles.Savergb);
set(handles.PlayCalibTone,'CData', handles.Playrgb);



%%
%�\�����x���^����̐ݒ�   7Dec15, NM
%
% ParamHIGUI.SetAdgmList�́AHIsimFastGC_InitParamHI.m�ɋL�q�B

[LenSetAdgm,dummy] = size(ParamHIGUI.SetAdgmList);
if LenSetAdgm-1 ~= ParamHIGUI.LenHLlist
    error('Inconsistency in LenSetAdgm');
end;
ParamHIGUI.GUI.SetCmprsList = cellstr([{'Set Compression'}, {'-- �I�� --'}; ...
    {'100'}, {'100'}; {'67'}, {'67'};...
    {'50'},   {'50'}; {'33'}, {'33'}; {'0'}, {'0'}]);
ParamHIGUI.GUI.Axes = cellstr([{'Hearing Level(dB)'}, {'Frequency(Hz)'}; {'���̓��x��(dB)'}, {'���g��(Hz)'}]);
ParamHIGUI.GUI.Settings         = cellstr([{'Settings'}, {'�ݒ�'}]);
ParamHIGUI.GUI.AdgmPanel        = cellstr([{'��Audiogram'}, {'���I�[�W�I�O����'}]);
ParamHIGUI.GUI.CompPanel        = cellstr([{'��Compression(%)'}, {'�����k����(%)'}]);
ParamHIGUI.GUI.RecPanelLabel    = cellstr([{'Record CalibTone'}, {'�Z�����^��'}; ...
    {'Record Source & Replay'}, {'�����^��+�Đ�'};]);
ParamHIGUI.GUI.LoadPanelLabel   = cellstr([{'Load Source'}, {'�������[�h'}]);
ParamHIGUI.GUI.SetSPLdBText     = cellstr([{'��Sound Level (dB SPL)'}, {'���������x�� (dB SPL)'}]);
ParamHIGUI.GUI.LoadSoundLabel   = cellstr([{'Load Sound(*.wav)'}, {'�t�@�C���I��(*.wav)'}]);
ParamHIGUI.GUI.ProcessingLabel  = cellstr([{'Processing'}, {'�����J�n'}]);
ParamHIGUI.GUI.ProcessingAutoLabel  = cellstr([{'Processing now'}, {'�������s��'}]);
ParamHIGUI.GUI.ReplayLabel      = cellstr([{'Replay'}, {'�Đ�'}]);
ParamHIGUI.GUI.PlaySrcLabel     = cellstr([{'Source'}, {'����'}]);
ParamHIGUI.GUI.PlayHIsimLabel   = cellstr([{'HI Simulated'}, {'�͋[�������'}]);
ParamHIGUI.GUI.CalibPanelLabel  = cellstr([{'Play CalibTone'}, {'�Z�����Đ�'}]);
ParamHIGUI.GUI.SwCalibTone      = 1; % Calibration tone first
ParamHIGUI.GUI.SwEngJpn         = 1;   % Default: English

%
set(handles.TextStatus, 'String', 'Record calibration tone to start.')
set(handles.CalibText,  'String',ParamHIGUI.CalibTextLabel(1,ParamHIGUI.GUI.SwEngJpn));
set(handles.popupSPLdB, 'String', ...
    cellstr([{[int2str(ParamHIGUI.SrcSndSPLdB_default)]}, ...   % �ŏ�default�l������
    {'100'},{'95'},{'90'},{'85'},{'80'},{'75'},{'70'},{'65'}, ...
    {'60'},{'55'},{'50'},{'45'},{'40'},{'35'},{'30'}]));

% cellstr([{[int2str(ParamHIGUI.SrcSndSPLdB_default) ' dB (default)']}, ...   % �ŏ�default�l������
% cellstr([{[int2str(ParamHIGUI.SPLdB_CalibTone) ' dB (default)']}, ������CalibTone�̃��x���͊ԈႢ

% handles.SetLanguage = 2;
% Language_Callback(hObject, eventdata, handles);
%set(handles.popupAudiogram, 'String', ParamHIGUI.SetAdgmList(:,2));

%Enable off (����ł��Ȃ��悤�ɂ���) 12Nov15, NM, 8 Jun 16 mod IT
set(handles.SetAudiogram, 'Enable', 'off');
set(handles.popupAudiogram, 'Enable', 'off');
set(handles.SetCmprs,   'Enable', 'off');
set(handles.popupCmprs, 'Enable', 'off');
set(handles.RecordButton, 'Enable', 'off');        % Calbration tone��record panel�ő��삵�Ȃ��̂ŁB
%set(handles.RecReplay, 'visible', 'off');
%set(handles.SaveRecSnd, 'visible', 'off');
%set(handles.RecCalibToneText, 'visible', 'off');
set(handles.RecCalibToneText, 'visible', 'on');
set(handles.TextStatus, 'String', 'Play calibration tone & set level first --> '); % set status
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);
set(handles.RecReplay, 'Enable', 'off');
set(handles.SaveRecSnd, 'Enable', 'off');
set(handles.SetSPLdB,  'Enable', 'off');
set(handles.popupSPLdB,'Enable', 'off');
set(handles.LoadSound, 'Enable', 'off');
set(handles.LoadText,  'Enable', 'off');
set(handles.Processing,'Enable', 'off');
set(handles.edit1,     'Enable', 'off');
set(handles.edit2,     'Enable', 'off');
set(handles.edit3,     'Enable', 'off');
set(handles.edit4,     'Enable', 'off');
set(handles.edit5,     'Enable', 'off');
set(handles.edit6,     'Enable', 'off');
set(handles.edit7,     'Enable', 'off');
set(handles.editCmp1,  'Enable', 'off');
set(handles.editCmp2,  'Enable', 'off');
set(handles.editCmp3,  'Enable', 'off');
set(handles.editCmp4,  'Enable', 'off');
set(handles.editCmp5,  'Enable', 'off');
set(handles.editCmp6,  'Enable', 'off');
set(handles.editCmp7,  'Enable', 'off');

% CalibTone����enable��
set(handles.PlayCalibTone, 'Enable', 'on'); %�@Play���삪�\�Ȃ̂悤��

%set(handles.HIsimFig, 'KeyPressFcn', @myKPFcn);%6 Aug 2015, NM %coment out

% Working directory�̐ݒ�@Exec_HIsimFastGC�̑O�Ɏ��s����K�v����
SetWorkingDirectory(hObject, handles);

%Exec_HIsimFastGC�̍������̂��߁A�֐������O�ɌĂяo���Acash�ɓ����B
% ���̎�ނ�p�����[�^�͂Ȃ�ł��ǂ��A�����ł͒Z���Ԃ̉��B
ParamHIGUI.SrcSnd = sin(2*pi*1000*(0:0.01*ParamHIGUI.fs)/ParamHIGUI.fs); % 10ms sin wave
Exec_HIsimFastGC(hObject, eventdata, handles);

%
%�^���p�̃I�u�W�F�N�g�ݒ�
handles.recObj = [];
handles.recObj = audiorecorder(ParamHIGUI.fs,ParamHIGUI.Nbits,1);%1 channel

guidata(hObject, handles);
end

%%
function  SetWorkingDirectory(hObject, handles)
global ParamHIGUI

%%%%%%%%%%%%%%
% working directory�̐ݒ�
% Windows�Ή��B���łɁAdefault��working directory��ύX�Bfunction���B
% 12 Jan 18
%%%%%%%%%%%%%%
ParamHIGUI.GUI.DirHome = [getenv('HOME') ];   % mac / unix
if ispc  % Win PC
    % ParamHIGUI.GUI.DirHome = [getenv('USERPROFILE') ];
    ParamHIGUI.GUI.DirHome = [getenv('HOMEDRIVE')  getenv('HOMEPATH')];
end;
ParamHIGUI.GUI.DirSound = [ParamHIGUI.GUI.DirHome  filesep 'Data' filesep 'HIsim' filesep];
set(handles.TextStatus,'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);
if exist(ParamHIGUI.GUI.DirSound) ~= 7  
    % �����ꍇ�́A���[�U�[�ɍ�点�邩�I�΂�����B
    % --> �����v�������A����A�����グ���ƂɎw�肷��K�v����B
    % �ނ���A�����I�ɍ���������A�ʓ|���Ȃ��B
    % �����ĈႤ�Ƃ���ɂ������l�́Afile�����o���̏��őI�ׂ�B
    Str = ['Making working directory:  '  ParamHIGUI.GUI.DirSound ];
    set(handles.TextStatus, 'String', Str);
    disp(Str);
    mkdir(ParamHIGUI.GUI.DirSound);
    % DirGet = uigetdir(ParamHIGUI.GUI.DirHome);
    % ParamHIGUI.GUI.DirSound = [DirGet filesep];
end;

Str = ['Setting working directory: ' ParamHIGUI.GUI.DirSound];
disp(Str);
set(handles.TextStatus, 'String', Str);

ParamHIGUI.GUI.NameKeepSrcSndHdr  = 'HIsim_';
ParamHIGUI.GUI.NameKeepPrcSndHdr  = 'HIsim_';

end


% UIWAIT makes HIsimFastGC_GUI wait for user response (see UIRESUME)
% uiwait(handles.HIsimFig);


% --- Outputs from this function are returned to the command line.
function varargout = HIsimFastGC_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END of main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Audiogram settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% popup Audiogram menu (11 Nov 15, NM)

% --- Executes on selection change in popupAudiogram.
function popupAudiogram_Callback(hObject, eventdata, handles)
global ParamHIGUI;
% hObject    handle to popupAudiogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.RecCalibToneText, 'visible', 'off');
set(handles.PlayCalibTone, 'Enable', 'off');
ParamHIGUI.GUI.SwCalibTone = 0;

AdgmPopupList = cellstr(get(hObject,'String'));
GetAudiogramName = AdgmPopupList{get(hObject,'Value')};
AdgmPopupListNum = strmatch(GetAudiogramName, AdgmPopupList);
ParamHIGUI.AudiogramNum = AdgmPopupListNum - 1;
guidata(hObject, handles);
if ParamHIGUI.AudiogramNum < ParamHIGUI.LenHLlist; % manual input �ȊO
    DrawAudiogram(hObject, eventdata, handles);
else
    set(handles.edit1, 'Enable', 'on');
    set(handles.edit2, 'Enable', 'on');
    set(handles.edit3, 'Enable', 'on');
    set(handles.edit4, 'Enable', 'on');
    set(handles.edit5, 'Enable', 'on');
    set(handles.edit6, 'Enable', 'on');
    set(handles.edit7, 'Enable', 'on');
    set(handles.editCmp1, 'Enable', 'on');
    set(handles.editCmp2, 'Enable', 'on');
    set(handles.editCmp3, 'Enable', 'on');
    set(handles.editCmp4, 'Enable', 'on');
    set(handles.editCmp5, 'Enable', 'on');
    set(handles.editCmp6, 'Enable', 'on');
    set(handles.editCmp7, 'Enable', 'on');
    MouseDraggedAdgm_Callback(hObject, eventdata, handles);%Audiogram4 -> MouseDraggedAdgm
end
set(handles.SetCmprs,  'Enable', 'on');
set(handles.popupCmprs,'Enable', 'on');
set(handles.LoadSound, 'Enable', 'on'); %[[[]]]
set(handles.LoadText,  'Enable', 'on');
if ParamHIGUI.SwNoLoadSound4Exp == 1,
    set(handles.LoadSound, 'Enable', 'off');
    set(handles.LoadText,  'Enable', 'off');
end;
set(handles.PlayCalibTone, 'Enable', 'off');
set(handles.CalibText, 'Enable', 'off');
% Hints: contents = cellstr(get(hObject,'String')) returns popupAudiogram contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupAudiogram
end

% --- Executes during object creation, after setting all properties.
function popupAudiogram_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCmprs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%% popup Compression Degree menu
% --- Executes on selection change in popupCmprs.
function popupCmprs_Callback(hObject, eventdata, handles)
% hObject    handle to popupCmprs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ParamHIGUI
CompPopupList = cellstr(get(hObject,'String'));
ParamHIGUI.getComp = str2double(CompPopupList{get(hObject,'Value')});

% DrawAudiogram�̒��Ɉȉ��͓����Ă���B
% NumComp = find(ParamHIGUI.getComp == ParamHIGUI.Table_getComp);
%ParamHIGUI.DegreeCompressionPreSet = ...
%    ParamHIGUI.Table_DegreeCompressionPreSet(NumComp);  %Table�̒l�ŕϊ��Bsee HIsimFastGC_InitParamHI.m
% �ȉ��Ɠ����B
% if     ParamHIGUI.getComp == 100, ParamHIGUI.DegreeCompressionPreSet = 1;
% elseif ParamHIGUI.getComp == 67,  ParamHIGUI.DegreeCompressionPreSet = 2/3;
% elseif ParamHIGUI.getComp == 50,  ParamHIGUI.DegreeCompressionPreSet = 1/2;
% elseif ParamHIGUI.getComp == 33,  ParamHIGUI.DegreeCompressionPreSet = 1/3;
% elseif ParamHIGUI.getComp == 0,   ParamHIGUI.DegreeCompressionPreSet = 0;
% end;
DrawAudiogram(hObject, eventdata, handles);
set(handles.LoadSound,   'Enable', 'on');
set(handles.LoadText,    'Enable', 'on');
if ParamHIGUI.SwNoLoadSound4Exp == 1,
    set(handles.LoadSound,   'Enable', 'off');
    set(handles.LoadText,    'Enable', 'off');
end;
set(handles.PlayCalibTone, 'Enable', 'off');
set(handles.CalibText,     'Enable', 'off');
set(handles.RecordButton,  'Enable', 'on'); %[[[]]]
set(handles.LoadSound,     'Enable', 'on');

%ParamHIGUI.GUI.SwCalibTone = 0;
%if   ParamHIGUI.GUI.SwCalibTone == 1, SwRecPanel = 1;  else SwRecPanel = 2; end;
SwRecPanel = 2;
set(handles.RecPanel,'Title',ParamHIGUI.GUI.RecPanelLabel(SwRecPanel,ParamHIGUI.GUI.SwEngJpn));

end

% --- Executes during object creation, after setting all properties.
function popupCmprs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCmprs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Recording %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in RecordButton.
function RecordButton_Callback(hObject, eventdata, handles)
global ParamHIGUI;

%if isfield(ADInfo, 'input') == 1
handles.RecBtnCnt = handles.RecBtnCnt + 1;
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.TextStatus, 'String', 'Recording...'); % set status
if rem(handles.RecBtnCnt,2) == 1;%Start Rec
    disp('recording')
    set(handles.RecordButton,'CData', handles.STOPrgb);
    record(handles.recObj);
    %Enable off
    for Enum = 1:7
        EnumEvaltxt = ['set(handles.edit' num2str(Enum) ', ''Enable'', ''off'');'];
        eval(EnumEvaltxt);
    end;
    %set(handles.popupAudiogram, 'Enable', 'off');
    %set(handles.popupCmprs, 'Enable', 'off');
    %set(handles.SetSPLdB,   'Enable', 'off');
    %set(handles.popupSPLdB, 'Enable', 'off');
    %set(handles.LoadSound,  'Enable', 'off');
    %set(handles.LoadText,   'Enable', 'off');
    set(handles.Processing, 'Enable', 'off');
    set(handles.PlaySource, 'Enable', 'off');
    set(handles.PlayHIsim,  'Enable', 'off');
    set(handles.PlayHIsimPrev, 'Enable', 'off');
    set(handles.PlayHIsimPrev2, 'Enable', 'off');
    set(handles.RecReplay,  'Enable', 'off');
    set(handles.SaveRecSnd, 'Enable', 'off');
elseif rem(handles.RecBtnCnt,2) == 0;%Stop Rec
    disp('Recording -- done');
    set(handles.RecordButton,'CData', handles.RECrgb);
    set(handles.TextStatus, 'String', 'Recording -- done');
    set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);
    stop(handles.recObj);
    RecTime = clock;
    ParamHIGUI.GUI.NameRecTime = ['Rec' strcat(num2str(RecTime(1), '%04d'), ...
        num2str(RecTime(2), '%02d'), num2str(RecTime(3), '%02d'), ...
        'T' , num2str(RecTime(4), '%02d'),  num2str(RecTime(5), '%02d'), ...
        num2str(round(RecTime(6)), '%02d'));];
    set(handles.RecReplay, 'visible', 'on');
    set(handles.SaveRecSnd, 'visible', 'on');
    %Enable on
    for Enum = 1:7
        EnumEvaltxt = ['set(handles.edit' num2str(Enum) ', ''Enable'', ''on'');'];
        eval(EnumEvaltxt);
    end;
    
    set(handles.RecCalibToneText, 'Enable', 'off');
    set(handles.RecCalibToneText, 'String', '');
    set(handles.RecCalibToneText, 'Position',[0 0 1 1]);
    set(handles.RecReplay,  'Enable', 'on');
    %set(handles.SaveRecSnd, 'Enable', 'on');
end

guidata(hObject, handles);
end



% --- Executes on button press in RecReplay.
function RecReplay_Callback(hObject, eventdata, handles)
% hObject    handle to RecReplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ParamHIGUI

set(handles.PlayCalibTone, 'Enable', 'off');
set(handles.SaveRecSnd, 'Enable', 'off');

% for calculation of RMS level dB
ValRecSnd = getaudiodata(handles.recObj);
ValRecSnd = ValRecSnd(:)';
% raised-cos tapering initial 30ms to remove pop noise
Ttaper    = 0.03;
Ntaper    = Ttaper*ParamHIGUI.fs;
CosTaper  = 1-cos((0:Ntaper)/Ntaper*pi/2).^2;
WinTaper  = [CosTaper ones(1,length(ValRecSnd)-2*length(CosTaper)) ...
    fliplr(CosTaper)];
ValRecSnd = WinTaper.*ValRecSnd;
ParamHIGUI.RMSDigitalLeveldB_RecordedSnd = 20*log10(sqrt(mean(ValRecSnd.^2)));

if ParamHIGUI.GUI.SwCalibTone == 1,
    ParamHIGUI.RecordedCalibTone = ValRecSnd;
    ParamHIGUI.RMSDigitalLeveldB_RecordedCalibTone ...
        = ParamHIGUI.RMSDigitalLeveldB_RecordedSnd;
    Str = ['RMS digital level: Play = ' ...
        num2str(ParamHIGUI.RMSDigitalLeveldB_CalibTone,'%5.1f') ...
        ' (dB),  Record = ' ...
        num2str(ParamHIGUI.RMSDigitalLeveldB_RecordedCalibTone,'%5.1f') ...
        ' (dB)'];
    disp(Str);
    set(handles.TextStatus, 'String', Str);
    set(handles.PlayCalibTone, 'Enable', 'on'); % ���x�ł��^���ł���悤��
else
    ParamHIGUI.RMSDigitalLeveldB_SrcSnd = ParamHIGUI.RMSDigitalLeveldB_RecordedSnd;
    [SPLdB StrSPLdB] = CnvtRMSDigitalLevel2SPLdB_String(ParamHIGUI.RMSDigitalLeveldB_SrcSnd);
    Str = ['Source sound [' StrSPLdB ']'];
    disp(Str);
    set(handles.TextStatus, 'String', Str);
    set(handles.PlayCalibTone, 'Enable', 'off'); % ������^������Ƃ���off
end;

%Playback
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.TextStatus,  'String',['Playing Sound : '  Str  ]);   %
handles.player = audioplayer(ValRecSnd,ParamHIGUI.fs,ParamHIGUI.Nbits);   %added 24 Jul 15
playblocking(handles.player);
set(handles.TextStatus,  'String', 'Playing Sound  -- done');  % �s�v
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);
guidata(hObject, handles);

set(handles.SaveRecSnd, 'Enable', 'on');

end

%
% RMSDigitalLevel2SPLdB string & val
%
function [SPLdB, StrSPLdB] = CnvtRMSDigitalLevel2SPLdB_String(RMSDigitalLeveldB);
global ParamHIGUI
SPLdB = RMSDigitalLeveldB + ParamHIGUI.CnvtRMSDigitalLevel2SPLdB;
StrSPLdB = [num2str(SPLdB,'%4.1f')  ' (SPL dB)'];
end

% --- Executes on button press in SaveRecSnd.
function SaveRecSnd_Callback(hObject, eventdata, handles)
%%set(handles.TextStatus, 'String', 'Saved Rec Data (.wav)');
% hObject    handle to SaveRecSnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ParamHIGUI

ValRecSnd = getaudiodata(handles.recObj);
ValRecSnd = ValRecSnd(:)';
% raised-cos tapering initial 30ms to remove pop noise
Ttaper    = 0.03;
Ntaper    = Ttaper*ParamHIGUI.fs;
CosTaper  = 1-cos((0:Ntaper)/Ntaper*pi/2).^2;
WinTaper  = [CosTaper ones(1,length(ValRecSnd)-2*length(CosTaper)) ...
    fliplr(CosTaper)];
ValRecSnd = WinTaper.*ValRecSnd;

% setting save sounds

if ParamHIGUI.GUI.SwCalibTone == 1,
    NameSaveSoundDflt = [ParamHIGUI.GUI.NameKeepSrcSndHdr  ParamHIGUI.GUI.NameRecTime ...
        '_CalibTone_1kHz_' int2str(ParamHIGUI.SPLdB_CalibTone) 'dB.wav'];
    % Calbration�́A�^������������ɍs�Ȃ��B
    % �ȉ��̌v�Z�́ARecReplay_Callback�ōs�Ȃ��Ă���B�����ł͕s�v�B
    %ParamHIGUI.RecordedCalibTone = ValRecSnd;
    %ParamHIGUI.RMSDigitalLeveldB_RecordedCalibTone ...
    %    = 20*log10(sqrt(mean(ParamHIGUI.RecordedCalibTone.^2)));
    
    %Str = ['RMS digital level: Playbacked = ' ...
    %    num2str(ParamHIGUI.RMSDigitalLeveldB_PlaybackCalibTone,'%5.1f') ...
    %    ' (dB),  Recorded = ' ...
    %    num2str(ParamHIGUI.RMSDigitalLeveldB_RecordedCalibTone,'%5.1f') ...
    %    ' (dB)'];
    Str = ['Are you sure SPL of CalibTone at ' ...
        num2str(ParamHIGUI.SPLdB_CalibTone,'%5.1f') ' (dB)?'];
    disp(Str);
    set(handles.TextStatus, 'String', Str);
    
    set(handles.SetAudiogram,   'Enable', 'on');
    set(handles.popupAudiogram, 'Enable', 'on');
    set(handles.SetCmprs,       'Enable', 'on');
    set(handles.popupCmprs,     'Enable', 'on');
    
    set(handles.PlayCalibTone, 'Enable', 'off'); % [[[]]]]
    set(handles.RecordButton,  'Enable', 'off'); % [[[]]]]
    set(handles.RecReplay,     'Enable', 'off');
    set(handles.SaveRecSnd,    'Enable', 'off');
    set(handles.RecCalibToneText, 'String', 'Set audiogram & compression');
    set(handles.TextStatus, 'String', 'Set audiogram & compression');
    
    %    set(handles.LoadSound,      'Enable', 'on');
    %    set(handles.LoadText,       'Enable', 'on'); Not yet
    ParamHIGUI.RMSDigitalLeveldB_RecordedCalibTone = 20*log10(sqrt(mean(ValRecSnd.^2)));
    ParamHIGUI.CnvtRMSDigitalLevel2SPLdB = ...
        ParamHIGUI.SPLdB_CalibTone - ParamHIGUI.RMSDigitalLeveldB_RecordedCalibTone; %�����ł͂��߂Ďg����
    
else
    NameSaveSoundDflt = [ParamHIGUI.GUI.NameKeepSrcSndHdr  ParamHIGUI.GUI.NameRecTime '.wav'];
    ParamHIGUI.SrcSnd = ValRecSnd;
    ParamHIGUI.RMSDigitalLeveldB_RecSnd = 20*log10(sqrt(mean(ValRecSnd.^2)));
    [SPLdB StrSPLdB] =  CnvtRMSDigitalLevel2SPLdB_String(ParamHIGUI.RMSDigitalLeveldB_RecSnd);
    ParamHIGUI.SrcSndSPLdB = SPLdB;  % HI simulator�M�������̂����Ƃ��d�v�ȃp�����[�^
    
    Str = ['Recorded Source:  ' StrSPLdB ];
    disp(Str);
    set(handles.TextStatus, 'String', Str);
    pause(0.2);
    % set(handles.Processing, 'Enable', 'on'); % �������s�̂��߁AEnable�ɂ��Ȃ��B
end;

%pause(0.2); % show the level shortly

%% %%%%%%%%%%%
%  Save files
%%%%%%%%%%%%%
[NameFile,NamePath] = uiputfile('.wav', 'Save Sound',[ParamHIGUI.GUI.DirSound NameSaveSoundDflt]);
NameSaveSound = [NamePath NameFile];
audiowrite(NameSaveSound, ValRecSnd, ParamHIGUI.fs, 'BitsPerSample', ParamHIGUI.Nbits);
% set(handles.TextStatus, 'String', ['Saved: ' NameFile]);
%%%% [[[[[    ]]]]] %%

% Setting name / directory
disp(['DirSound = ' NamePath]);
ParamHIGUI.GUI.DirSound = NamePath;                  % renewal of path
[dir1, Name1, ext1] = fileparts(NameSaveSound);  % for removing extension
ParamHIGUI.GUI.NameKeepSrcSnd  = Name1;
% header������āA������x�t�������Ă���B�Ȃ����s���������̂܂܁B10 Sep16
Name1body = Name1(length(ParamHIGUI.GUI.NameKeepSrcSndHdr)+1:end);
ParamHIGUI.GUI.NameKeepPrcSnd  = [ParamHIGUI.GUI.NameKeepPrcSndHdr Name1body];

Str = ['Saved: ' Name1];
set(handles.TextStatus, 'String', Str);

%% %%%%%%%%%%%
%  �������s
%%%%%%%%%%%%%
if ParamHIGUI.GUI.SwCalibTone ~= 1, % �������^�����ꂽ�ꍇ�AProcessing���������s�B
    set(handles.Processing, 'Enable', 'on'); % �������s�̂��߁AEnable�ɂ��Ȃ��B
    set(handles.Processing, 'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay); % �������s�̂���
    set(handles.Processing, 'String', ParamHIGUI.GUI.ProcessingAutoLabel(ParamHIGUI.GUI.SwEngJpn)); % �������s
    HIsimulationProcessing(hObject, eventdata, handles);  %  HIsim���s
    set(handles.Processing, 'String', ParamHIGUI.GUI.ProcessingLabel(ParamHIGUI.GUI.SwEngJpn)); % �蓮���s�̂��߂̃��x���ɂ��ǂ��B
    set(handles.Processing, 'ForegroundColor',ParamHIGUI.GUI.ColorTextButton); %
end;

end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calibration tone player %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in PlayCalibTone.
function PlayCalibTone_Callback(hObject, eventdata, handles)
% hObject    handle to PlayCalibTone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% �Đ��Ɠ����^���ł���悤�ɁA�ύX�@--> ����̊ȕ։��̂��߁B
%
global ParamHIGUI;


ParamHIGUI.GUI.SwCalibTone = 1;
[CalibTone, ParamHIGUI] = HIsimFastGC_MkCalibTone(ParamHIGUI);
apCalib  = audioplayer(CalibTone,ParamHIGUI.fs,ParamHIGUI.Nbits);

Str = ['Playing calibration tone for ' int2str(ParamHIGUI.CalibTone.Tdur) ...
    ' (sec) -- Set this to SPL of ' int2str(ParamHIGUI.SPLdB_CalibTone) ' (dB)'];
set(handles.TextStatus, 'String',Str);

record(handles.recObj); % record�J�n
disp('Playing & Recording calibration tone')
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.TextStatus, 'String', 'Playing & Recording calibration tone');

set(handles.PlayCalibTone, 'Enable', 'off'); % �Q�x�������ł��Ȃ��悤�ɂ���B26 Oct 17
set(handles.RecReplay, 'Enable','off');
set(handles.SaveRecSnd, 'Enable','off');

playblocking(apCalib);
set(handles.PlayCalibTone, 'Enable', 'on'); %�@�ēxPlay���\�Ȃ̂悤�ɂ��ǂ��B

stop(handles.recObj); % record�I��
set(handles.TextStatus, 'String', 'Playing & Recording calibration tone  -- done');
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);

RecTime = clock;
ParamHIGUI.GUI.NameRecTime = ['Rec' strcat(num2str(RecTime(1), '%04d'), ...
    num2str(RecTime(2), '%02d'), num2str(RecTime(3), '%02d'), ...
    'T' , num2str(RecTime(4), '%02d'),  num2str(RecTime(5), '%02d'), ...
    num2str(round(RecTime(6)), '%02d'));];

%set(handles.RecCalibToneText, 'Enable', 'off');
%set(handles.RecCalibToneText, 'String', '');
%set(handles.RecCalibToneText, 'Position',[0 0 1 1]);
set(handles.RecReplay, 'Enable', 'on');


end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Load Sound Source %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in LoadSound.
function LoadSound_Callback(hObject, eventdata, handles)
global ParamHIGUI

if isfield(ParamHIGUI,'HearingLevelVal') == 0,
    set(handles.TextStatus, 'String', 'Set Audiogram')
    return;
end;

[NameSndLoad, DirSndLoad] ...
    = uigetfile('*.wav;*.WAV;*.aif;*.AIF;*.aiff;*.AIFF',  'Select WAVE Sound file',ParamHIGUI.GUI.DirSound); %File Select ".wav"

if NameSndLoad == 0;
    if isfield(ParamHIGUI.GUI,'NameFullSndLoad') == 0,
        set(handles.TextStatus, 'String', 'Specify file')
        return;
    end;
else
    ParamHIGUI.GUI.NameSndLoad     = NameSndLoad;
    ParamHIGUI.GUI.NameFullSndLoad = [DirSndLoad, NameSndLoad];
end;

StrText = ['Load sound: ' ParamHIGUI.GUI.NameSndLoad];
disp(StrText);
set(handles.TextStatus, 'String', StrText)
[SndLoad fs] = audioread(ParamHIGUI.GUI.NameFullSndLoad);


if ParamHIGUI.fs  ~= fs;
    %�@Only fs=48000 Hz in this version
    StrText= ['fs of loaded sound = ' int2str(fs) ' ~= fs of the system ' int2str(ParamHIGUI.fs)];
    set(handles.TextStatus, 'String', StrText)
    return;
end;

[LenSnd LenCh] = size(SndLoad);
if LenCh > 1,
    ParamHIGUI.SndLoad = SndLoad(:)';
else
    ParamHIGUI.SndLoad = SndLoad(:,1)';  % Select Left channel
end;
set(handles.LoadText, 'String', ParamHIGUI.GUI.NameSndLoad);

% setting name keep
[dir1, Name1, ext1] = fileparts(NameSndLoad);
ParamHIGUI.GUI.NameKeepSrcSnd  = [ParamHIGUI.GUI.NameKeepSrcSndHdr  Name1 ];
ParamHIGUI.GUI.NameKeepPrcSnd  = [ParamHIGUI.GUI.NameKeepPrcSndHdr  Name1 ];

% ������Calibration�����m�ł���΁A
% load�������́A���Ȃ炸Calibration tone�Ɠ������x���ɕ␳�����.
% �^������CalibTone�̎����l�ɑ΂���␳������B
% �r���͐��m�ɁB����Ă���Ƃ�₱�����Ȃ�B
%% ParamHIGUI.SrcSndSPLdB = ParamHIGUI.SPLdB_CalibTone; % default�l
% GetSrcSndNrmlz2CalibTone(ParamHIGUI.SndLoad);

%--> ���̈Ӗ����s���ɂȂ����B19 Apr 19
%     Load��������Calibration tone�Ɠ����ɂ���͕̂ρB
%     GUI�Ŏw�肵�������ɉ����Ēl��ݒ�B
%      �ŏ��́AParamHIGUI.SrcSndSPLdB_default���g���B
%
ParamHIGUI.SrcSndSPLdB = ParamHIGUI.SrcSndSPLdB_default;

[ParamHIGUI] = HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHIGUI);

% playback here when loading & normalized  % local variable
SrcSndPlayer = ...
    audioplayer(ParamHIGUI.SrcSnd,ParamHIGUI.fs,ParamHIGUI.Nbits);
playblocking(SrcSndPlayer);

set(handles.SetSPLdB,  'Enable', 'on');
set(handles.popupSPLdB,'Enable', 'on');
set(handles.Processing,'Enable', 'on');

end



%% Normalize re. CalibTone
% �O���֐��AHIsimFastGC_GetSrcSndNrmlz2CalibTone.m�ɁB
%
% function GetSrcSndNrmlz2CalibTone(SndIn)
% HIsimFastGC�̌v�Z��SndLoad��Normaize�͕K�v�Ȃ��B���������`����Ηǂ��B
% �����AGUI���ŁACalibTone�ɑ΂��郌�x���̍Z���͕K�v�@�@9 Jul 2016
% global ParamHIGUI
%
%    RMSlevel_SndIn = sqrt(mean(SndIn.^2));
%    RMSlevel_CalibTone = sqrt(mean(ParamHIGUI.RecordedCalibTone.^2));
%    AmpdB1 = (ParamHIGUI.SrcSndSPLdB - ParamHIGUI.SPLdB_CalibTone); %
%    Amp1   = 10^(AmpdB1/20)*RMSlevel_CalibTone/RMSlevel_SndIn;
%    ParamHIGUI.SrcSnd = Amp1*SndIn;
%end


% --- Executes on selection change in popupSPLdB.
function popupSPLdB_Callback(hObject, eventdata, handles) % 9 Jul 2016
% hObject    handle to popupSPLdB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popupSPLdB contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSPLdB
% % �e�L�X�g�{�b�N�X�g���ꍇ�͉B��MN
global ParamHIGUI

handles = guidata(hObject);
contents = cellstr(get(hObject,'String'));
ValSelect = str2double(contents{get(hObject,'Value')});

%%% [[[  �v�`�F�b�N�B�@7 Jul 18]]]
if isnan(ValSelect) == 1  |  length(ValSelect) == 0,
    %    ParamHIGUI.SrcSndSPLdB = ParamHIGUI.SPLdB_CalibTone;
    error('Something wrong with ParamHIGUI.SrcSndSPLdB');
else
    ParamHIGUI.SrcSndSPLdB = ValSelect;
end;

%disp(['ParamHIGUI.SrcSndSPLdB = ' num2str(ParamHIGUI.SrcSndSPLdB) ' dB']);
% GetSrcSndNrmlz2CalibTone(ParamHIGUI.SndLoad); �O���֐��ɏ�������

[ParamHIGUI] = HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHIGUI);
% playback here when loading & normalized  % local variable
SrcSndPlayer = ...
    audioplayer(ParamHIGUI.SrcSnd,ParamHIGUI.fs,ParamHIGUI.Nbits);

Str = ['Set SPL of the source sound as ' num2str(ParamHIGUI.SrcSndSPLdB,'%5.1f') ' dB.'];
disp(Str);
set(handles.TextStatus, 'String', Str);

playblocking(SrcSndPlayer);

set(handles.Processing, 'Enable', 'on');
end



% --- Executes during object creation, after setting all properties.
function popupSPLdB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSPLdB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Signal processing for HI simulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in Processing.
function Processing_Callback(hObject, eventdata, handles)
% hObject    handle to Processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ParamHIGUI

set(handles.Processing,  'ForegroundColor', ParamHIGUI.GUI.ColorTextPlay);
HIsimulationProcessing(hObject, eventdata, handles);
handles.HIsimCnt = handles.HIsimCnt + 1;
set(handles.Processing,  'ForegroundColor', ParamHIGUI.GUI.ColorTextButton);

guidata(hObject, handles);
end


function HIsimulationProcessing(hObject, eventdata, handles)
global ParamHIGUI

if isfield(ParamHIGUI,'RecordedCalibTone') == 0,
    set(handles.TextStatus, 'String', 'Calibrate SPL of tone first.')
    return;
end;
if isfield(ParamHIGUI,'SrcSnd') == 0,
    set(handles.TextStatus, 'String', 'Record or Load Sound.')
    return;
end;
if ParamHIGUI.SwKeepSnd == 1,
    NameKeepSnd = [ParamHIGUI.GUI.DirSound  ParamHIGUI.GUI.NameKeepSrcSnd '.wav'];
    audiowrite(NameKeepSnd, ParamHIGUI.SrcSnd, ParamHIGUI.fs, ...
        'BitsPerSample',ParamHIGUI.Nbits);
end;
% prepare SrcSndPlayer
ParamHIGUI.SrcSndPlayer = ...
    audioplayer(ParamHIGUI.SrcSnd,ParamHIGUI.fs,ParamHIGUI.Nbits);

set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.TextStatus, 'String', 'Processing ...');
pause(0.01); % for display text
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);

Exec_HIsimFastGC(hObject, eventdata, handles);  % Execute HIsimFastGC

if isfield(ParamHIGUI,'HIsimPrevSndPlayer') == 1
    ParamHIGUI.HIsimPrev2SndPlayer = ParamHIGUI.HIsimPrevSndPlayer;
    ParamHIGUI.RMSDigitalLeveldB_HIsimPrev2Snd = ParamHIGUI.RMSDigitalLeveldB_HIsimPrevSnd;
end;
if isfield(ParamHIGUI,'HIsimSndPlayer') == 1
    ParamHIGUI.HIsimPrevSndPlayer = ParamHIGUI.HIsimSndPlayer;
    ParamHIGUI.RMSDigitalLeveldB_HIsimPrevSnd = ParamHIGUI.RMSDigitalLeveldB_HIsimSnd;
end;
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.TextStatus, 'String', 'Playing HI simulated sound');

ParamHIGUI.HIsimSndPlayer = ...
    audioplayer(ParamHIGUI.HIsimSnd,ParamHIGUI.fs,ParamHIGUI.Nbits);
playblocking(ParamHIGUI.HIsimSndPlayer);
ParamHIGUI.RMSDigitalLeveldB_HIsimSnd = 20*log10(sqrt(mean(ParamHIGUI.HIsimSnd.^2)));

set(handles.TextStatus, 'String', 'Press "Source" or "HI Simulated" for Replay');
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);

set(handles.PlaySource, 'Visible','on') % Play Source
set(handles.PlayHIsim,  'Visible','on')  % PlayHIsim
if isfield(ParamHIGUI,  'HIsimPrevSndPlayer') == 1
    set(handles.PlayHIsimPrev,'Visible','on')  % PlayHIsimPrev
end;
if isfield(ParamHIGUI,'HIsimPrev2SndPlayer') == 1
    set(handles.PlayHIsimPrev2,'Visible','on')  % PlayHIsimPrev2
end;

if ParamHIGUI.SwKeepSnd == 1
    NameSuffix = ['_Agrm' ParamHIGUI.AudiogramName  ...
        '_Cmprs' int2str(ParamHIGUI.DegreeCompressionPreSet*100)  ...%added'PreSet' 8Oct15,NM
        '_Src' int2str(ParamHIGUI.SrcSndSPLdB) 'dB'];
    %��NameSuffix�ɖ͋[����������t�@�C�����ɔ��f������ꍇ
    %    NameSuffix = ['_Proc' num2str(handles.HIsimCnt)];
    NameKeepSnd = [ParamHIGUI.GUI.DirSound ParamHIGUI.GUI.NameKeepPrcSnd NameSuffix '.wav'];
    audiowrite(NameKeepSnd, ParamHIGUI.HIsimSnd, ParamHIGUI.fs, ...
        'BitsPerSample',ParamHIGUI.Nbits);
end;

set(handles.PlaySource,     'Enable', 'on');
set(handles.PlayHIsim,      'Enable', 'on');
set(handles.PlayHIsimPrev,  'Enable', 'on');
set(handles.PlayHIsimPrev2, 'Enable', 'on');

end


function Exec_HIsimFastGC(hObject, eventdata, handles)
global ParamHIGUI

disp('*** HIsimFastGC Processing ***')

%ParamHIGUI.DegreeCompression_FreqAudGram
%ParamHIGUI.HLdB_LossCompression
%   HISparam.RatioInvCompression_NchFB = interp1(HISparam.NumERBaudgramList, ...
%       HISparam.RatioInvCompression,HISparam.NumERBFr1,'linear','extrap');
% ParamHIGUI.DCcmpnst_PV

HISparam.fs                         = ParamHIGUI.fs;
HISparam.SrcSndSPLdB      = ParamHIGUI.SrcSndSPLdB;  % normalize�Ɏg���Ă���
HISparam.FaudgramList      = ParamHIGUI.FaudgramList;
HISparam.DegreeCompression = ParamHIGUI.DegreeCompression_Faudgram;
HISparam.HLdB_LossLinear   = ParamHIGUI.HLdB_LossLinear;  %  HIsimFastGC�Ŏg�p�B
%HISparam.HLdB_LossCompression  % 13 Dec18 ����͐ݒ�s�v�B HIsimFastGC�Ŏg��Ȃ��B
if isfield(ParamHIGUI,'HearingLevelVal') == 0,  % 13 Dec 18  �����ݒ莞�́A�l�����ł��܂�Ȃ��B
    ParamHIGUI.HearingLevelVal = NaN*ones(size(ParamHIGUI.HLdB_LossLinear));
end;
HISparam.HearingLevelVal         = ParamHIGUI.HearingLevelVal;    % 13 Dec 18 HIsimFastGC�Ŏg�p�@Gain�␳�̂���
HISparam.SwAmpCmpnst           = ParamHIGUI.SwAmpCmpnst;
HISparam.AllowDownSampling = 1;
HISparam.GUI = ParamHIGUI.GUI;

[SndOut, HISparam] = HIsimFastGC(ParamHIGUI.SrcSnd, HISparam);

ParamHIGUI.HISparam = HISparam;
ParamHIGUI.HIsimSnd = SndOut;
disp('----------------');
disp(' ');

% %%�ǉ��ꎞ�I��
% ElpsText = [num2str(HISparam.ElapsedTime(4)) '=' num2str(HISparam.ElapsedTimePerRealTime(4)) 'times'];
% set(handles.ElpsTimeText, 'String', ElpsText);
return;
end




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Playback                             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in PlaySource.
function PlaySource_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ParamHIGUI

if isfield(ParamHIGUI,'SrcSndPlayer') == 0,
    set(handles.TextStatus, 'String', 'Not Ready')
    return;
end;

set(handles.PlaySource, 'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.PlayHIsim,      'Enable', 'off');
set(handles.PlayHIsimPrev,  'Enable', 'off');
set(handles.PlayHIsimPrev2, 'Enable', 'off');
[SPLdB StrSPLdB] = CnvtRMSDigitalLevel2SPLdB_String(ParamHIGUI.RMSDigitalLeveldB_SrcSnd);
Str = 'Playing source sound';
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.TextStatus, 'String', [ Str  ' [' StrSPLdB ']']);
playblocking(ParamHIGUI.SrcSndPlayer);
set(handles.TextStatus, 'String', [ Str  ' -- done']);
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);

set(handles.PlaySource, 'ForegroundColor',ParamHIGUI.GUI.ColorTextButton);
set(handles.PlayHIsim,      'Enable', 'on');
set(handles.PlayHIsimPrev,  'Enable', 'on');
set(handles.PlayHIsimPrev2, 'Enable', 'on');

end

% --- Executes on button press in PlayHIsim.
function PlayHIsim_Callback(hObject, eventdata, handles)
% hObject    handle to PlayHIsim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ParamHIGUI
if isfield(ParamHIGUI,'HIsimSndPlayer') == 0,
    set(handles.TextStatus, 'String', 'Not Ready')
    return;
end;

set(handles.PlaySource,     'Enable', 'off');
set(handles.PlayHIsim,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.PlayHIsimPrev,  'Enable', 'off');
set(handles.PlayHIsimPrev2, 'Enable', 'off');

[SPLdB StrSPLdB] = CnvtRMSDigitalLevel2SPLdB_String(ParamHIGUI.RMSDigitalLeveldB_HIsimSnd);
Str = ['Playing HI simulated sound'];
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.TextStatus, 'String', [ Str  ' [' StrSPLdB ']']);
playblocking(ParamHIGUI.HIsimSndPlayer);
set(handles.TextStatus, 'String', [ Str  ' -- done']);
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);

set(handles.PlaySource,     'Enable', 'on');
set(handles.PlayHIsim, 'ForegroundColor',ParamHIGUI.GUI.ColorTextButton);
set(handles.PlayHIsimPrev,  'Enable', 'on');
set(handles.PlayHIsimPrev2, 'Enable', 'on');

end


% --- Executes on button press in PlayHIsimPrev.
function PlayHIsimPrev_Callback(hObject, eventdata, handles)
% hObject    handle to PlayHIsimPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ParamHIGUI

set(handles.PlaySource,     'Enable', 'off');
set(handles.PlayHIsim,      'Enable', 'off');
set(handles.PlayHIsimPrev, 'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.PlayHIsimPrev2, 'Enable', 'off');


[SPLdB StrSPLdB] = CnvtRMSDigitalLevel2SPLdB_String(ParamHIGUI.RMSDigitalLeveldB_HIsimPrevSnd);
Str = ['Playing HI simulated sound (prev1)'];
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.TextStatus, 'String', [ Str  ' [' StrSPLdB ']']);
playblocking(ParamHIGUI.HIsimPrevSndPlayer);
set(handles.TextStatus, 'String', [ Str  ' -- done']);
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);

set(handles.PlaySource,     'Enable', 'on');
set(handles.PlayHIsim,      'Enable', 'on');
set(handles.PlayHIsimPrev, 'ForegroundColor',ParamHIGUI.GUI.ColorTextButton);
set(handles.PlayHIsimPrev2, 'Enable', 'on');


end


% --- Executes on button press in PlayHIsimPrev2.
function PlayHIsimPrev2_Callback(hObject, eventdata, handles)
% hObject    handle to PlayHIsimPrev2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ParamHIGUI

set(handles.PlaySource,     'Enable', 'off');
set(handles.PlayHIsim,      'Enable', 'off');
set(handles.PlayHIsimPrev,  'Enable', 'off');
set(handles.PlayHIsimPrev2, 'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);


[SPLdB StrSPLdB] = CnvtRMSDigitalLevel2SPLdB_String(ParamHIGUI.RMSDigitalLeveldB_HIsimPrev2Snd);
Str = ['Playing HI simulated sound (prev2)'];
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextPlay);
set(handles.TextStatus, 'String', [ Str  ' [' StrSPLdB ']']);
playblocking(ParamHIGUI.HIsimPrev2SndPlayer);
set(handles.TextStatus, 'String', [ Str  ' -- done']);
set(handles.TextStatus,  'ForegroundColor',ParamHIGUI.GUI.ColorTextMessage);

set(handles.PlaySource,     'Enable', 'on');
set(handles.PlayHIsim,      'Enable', 'on');
set(handles.PlayHIsimPrev,  'Enable', 'on');
set(handles.PlayHIsimPrev2, 'ForegroundColor',ParamHIGUI.GUI.ColorTextButton);

end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Language                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in Language.
function Language_Callback(hObject, eventdata, handles)
global ParamHIGUI;
SetLanguage = get(hObject,'Value');
ParamHIGUI.SwJpnEng = 2;

% set language
if SetLanguage == 2;%Jananese
    disp('����I��: ���{��');
    ParamHIGUI.GUI.SwEngJpn = 2; %Jananese
elseif SetLanguage == 3;%English
    disp('Language selection: English');
    ParamHIGUI.GUI.SwEngJpn = 1;
end;

set(handles.SettingPanel,  'Title',  ParamHIGUI.GUI.Settings(1,ParamHIGUI.GUI.SwEngJpn));
set(handles.SetAudiogram,  'String', ParamHIGUI.GUI.AdgmPanel(:,ParamHIGUI.GUI.SwEngJpn));
set(handles.popupAudiogram,'String', ParamHIGUI.SetAdgmList(:,ParamHIGUI.GUI.SwEngJpn));
set(handles.SetCmprs,   'String', ParamHIGUI.GUI.CompPanel(:,ParamHIGUI.GUI.SwEngJpn));
set(handles.popupCmprs, 'String', ParamHIGUI.GUI.SetCmprsList(:,ParamHIGUI.GUI.SwEngJpn));
set(handles.LoadPanel,  'Title',  ParamHIGUI.GUI.LoadPanelLabel(1,ParamHIGUI.GUI.SwEngJpn));
set(handles.SetSPLdB,   'String', ParamHIGUI.GUI.SetSPLdBText(1,ParamHIGUI.GUI.SwEngJpn));
%    set(handles.popupSPLdB, 'String', ParamHIGUI.GUI.SetSPLdBText(1,ParamHIGUI.GUI.SwEngJpn)); %% ****
%  ���̍s�o�O�B�p��^���{��؂�ւ��ł��܂��Ή��ł��Ă��Ȃ��B�@by T.Matsui 4 Aug 18
%   ���������������x���͌���ɖ��֌W�Ȃ̂ł͂����B
set(handles.LoadSound,  'String', ParamHIGUI.GUI.LoadSoundLabel(1,ParamHIGUI.GUI.SwEngJpn));
set(handles.Processing, 'String', ParamHIGUI.GUI.ProcessingLabel(1,ParamHIGUI.GUI.SwEngJpn));
set(handles.ReplayPanel,'Title',  ParamHIGUI.GUI.ReplayLabel(1,ParamHIGUI.GUI.SwEngJpn));
set(handles.PlaySource, 'String', ParamHIGUI.GUI.PlaySrcLabel(1,ParamHIGUI.GUI.SwEngJpn));
set(handles.PlayHIsim,  'String', ParamHIGUI.GUI.PlayHIsimLabel(1,ParamHIGUI.GUI.SwEngJpn));
set(handles.CalibPanel, 'Title',  ParamHIGUI.GUI.CalibPanelLabel(1,ParamHIGUI.GUI.SwEngJpn));

% if   ParamHIGUI.GUI.SwCalibTone == 1, SwRecPanel = 1;  else SwRecPanel = 2; end;
SwRecPanel = 2;
set(handles.RecPanel,   'Title',  ParamHIGUI.GUI.RecPanelLabel(SwRecPanel,ParamHIGUI.GUI.SwEngJpn));

set(handles.CalibText, 'String',  ParamHIGUI.CalibTextLabel(1,ParamHIGUI.GUI.SwEngJpn));


% hObject    handle to Language (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Language contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Language
end

% --- Executes during object creation, after setting all properties.
function Language_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Language (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Draw Audiogram     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DrawAudiogram(hObject, eventdata, handles)
global ParamHIGUI
%cla(handles.axes1)
cla(gca)
%cla(handles.HIsimFig)
plot(handles.axes1,[-1 8], [0 0], 'k', 'linewidth', 1.5);
hold on;

ParamHIGUI.AudiogramName = char(ParamHIGUI.Table_AudiogramName(ParamHIGUI.AudiogramNum));

if isfield(ParamHIGUI, 'getComp') == 0
    ParamHIGUI.getComp = 100;
end
NumComp = find(ParamHIGUI.getComp == ParamHIGUI.Table_getComp);
ParamHIGUI.DegreeCompressionPreSet = ...
    ParamHIGUI.Table_DegreeCompressionPreSet(NumComp); %Table�̒l�ŕϊ��Bsee HIsimFastGC_InitParamHI.m

[LenHLlist, LenFadgm] = size(ParamHIGUI.HearingLevelList);
if ParamHIGUI.AudiogramNum < ParamHIGUI.LenHLlist;  %Audiogram �蓮���͈ȊO��I�񂾂Ƃ�
    ParamHIGUI.HearingLevelVal = ParamHIGUI.HearingLevelList(ParamHIGUI.AudiogramNum,:);
    set(handles.SetCmprs,       'Enable', 'on');
    set(handles.popupCmprs,   'Enable', 'on');
    set(handles.popupCmprs, 'String', ParamHIGUI.GUI.SetCmprsList(:,ParamHIGUI.GUI.SwEngJpn)); % popupCmprs�ݒ�(�I����)
    
else % Manual -- Audiogram��I�񂾂Ƃ�  �蓮����
    getAdgm = str2double(get(handles.edit1,'String'));
    strHndl = 'handles.edit';
    evalstring = 'String';
    set(handles.SetCmprs,       'Enable', 'off');  %  compression�̑I�����͏�����悤�ɁB
    set(handles.popupCmprs,   'Enable', 'off');
    NumComp = find(ParamHIGUI.Table_getComp == 0) %  �ŉ����\���̂���Comp 0�ɋ����I�ɂ���B8 Dec 2018
    set(handles.popupCmprs, 'String', ParamHIGUI.GUI.SetCmprsList(1,ParamHIGUI.GUI.SwEngJpn)); % popupCmprs�����i��\��)
    
    
    if isnan(getAdgm) == 1;%isfield(ParamHIGUI, 'ParamHIGUI.HearingLevelVal') == 0;%isnan(getAdgm) == 1;%�����l���Ȃ��Ƃ��i=�����Ȃ�Manual�I�񂾂Ƃ��j�Ƃ肠����0�ɐݒ肵�Ă���
        ParamHIGUI.HearingLevelVal = [10 10 10 10 10 10 10];
        for cntAdgm = 1:ParamHIGUI.LenFagrm;%Edit�ɒl������ %���g��125, ... 8000
            strsetEdit = ['set(' strHndl num2str(cntAdgm) ',''' evalstring ''', ParamHIGUI.HearingLevelVal(' num2str(cntAdgm) '));'];
            eval(strsetEdit);
        end;
    else %�e�L�X�g�{�b�N�X�ɒl�������
        for cntAdgm = 1:ParamHIGUI.LenFagrm;
            strgetEdit = ['(get(' strHndl num2str(cntAdgm) ',''' evalstring '''));'];
            ParamHIGUI.HearingLevelVal = ParamHIGUI.HearingLevelVal; %9Jul15
            %ParamHIGUI.HearingLevelVal(cntAdgm) = str2double(eval(strgetEdit));
        end;
        %disp(ParamHIGUI.HearingLevelVal)
    end;
    
    
end;

nTxt = 6;
xii=1:length(ParamHIGUI.HearingLevelVal);
%%% HI
plot(handles.axes1, [0 max(xii)+1], [0 0],'k');
%MarkerSize��ύX 15->9  16 Apr 2019, KF
handles.HIplot = plot(handles.axes1, xii, ParamHIGUI.HearingLevelVal(xii), 'ko-', 'MarkerSize', 9,'LineWidth',1.5);
guidata(hObject, handles);


% text(nTxt,ParamHIGUI.HearingLevelVal(nTxt)-5,'Hearing Impaired', 'FontSize', 12);
%text(nTxt+0.1,ParamHIGUI.HearingLevelVal(nTxt)-2,'HL_{Total}');
%�����T�C�Y��normalized�w��ɕύX 16 Apr 2019, KF
text(nTxt+0.1,ParamHIGUI.HearingLevelVal(nTxt)-2,'HL_{Total}','FontUnits', 'normalized',...
    'FontName', '���C���I','FontSize', 0.025);
%%% compression degree NH�̏ꍇ�B
plot(handles.axes1, xii, ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(1,:),'gx-','LineWidth',1.5);
%text(nTxt,ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(1,nTxt)-5,'Normal Hearing', 'FontSize', 12);
%�����T�C�Y��normalized�w��ɕύX 16 Apr 2019, KF
text(nTxt,ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(1,nTxt)-5,'Normal Hearing',...
    'FontUnits', 'normalized','FontName', '���C���I', 'FontSize', 0.025);
%GetDegreeCompression(hObject, eventdata, handles)

%% Preset�̏ꍇ�B�Ή�����ԍ�������Ă���B���łɏ�iline 1253) �ŁANumComp�Ƃ��ċ��߂Ă���B
% nDC = find(abs(ParamHIGUI.DegreeCompressionPreSet - ParamHIGUI.Table_DegreeCompressionPreSet) < 0.01 );

handles.CompAdgm = plot(handles.axes1, xii, ...
    ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(NumComp,:),'cs:');%set'handles.CompAdgm' 6Aug15, NM

if ParamHIGUI.AudiogramNum < ParamHIGUI.LenHLlist;% manual input �ȊO�@�ŏ��l���Ƃ�
    % Calculation of LossCompression & DegreeCompression
    ParamHIGUI.HLdB_LossCompression = min(ParamHIGUI.HearingLevelVal, ...
        ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(NumComp,:));
    
else   %�@manual input
    % HLdB_LossCompression���ꎞ�ۊǂ��ŏ��l���Ƃ�
    HLdB_LossCompression_Dummy = min(ParamHIGUI.HearingLevelVal ,ParamHIGUI.HLdB_LossCompression);
    ParamHIGUI.HLdB_LossCompression = HLdB_LossCompression_Dummy;
end

if isfield(ParamHIGUI, 'CompAdgmVal') == 0;%ParamHIGUI.CompAdgmVal�����݂��Ȃ����
    ParamHIGUI.CompAdgmVal = ParamHIGUI.HLdB_LossCompression;
end;
FndAbs = find(abs(ParamHIGUI.CompAdgmVal - ParamHIGUI.HLdB_LossCompression));

if ParamHIGUI.GUI.KeyPress == 1;%shift�������Ă���Ԃ�
    ParamHIGUI.HLdB_LossCompression(1,FndAbs) = ParamHIGUI.CompAdgmVal(1,FndAbs);
end

[ParamHIGUI] = HIsimFastGC_CalDegreeCmprsLin(ParamHIGUI);

%ParamHIGUI.HLdB_LossCompression;
%LenFag = length(ParamHIGUI.FaudgramList);
%for nfag = 1:LenFag   % mod
%    % linear interpolation seems better
%    ParamHIGUI.DCcmpnst(nfag) = interp1(ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(:,nfag), ...
%    ParamHIGUI.Table_DegreeCompressionPreSet,ParamHIGUI.HLdB_LossCompression(nfag),'linear','extrap');
%    ParamHIGUI.DCcmpnst(nfag) = max(min(ParamHIGUI.DCcmpnst(nfag),1),0); % limit between 0 and 1
%%text(nfag,140,[int2str(ParamHIGUI.DCcmpnst(nfag)*100) '%'],'FontSize', 12,'HorizontalAlignment','center');%%%Compression�̒l�@������e�L�X�g�{�b�N�X��%%%
%��comment out by NM, 8 Oct 2015
%    CmpEvalTxt = ['set(handles.editCmp' num2str(nfag) ', ''String'',' num2str(round(ParamHIGUI.DCcmpnst(nfag)*100)) ')'];%added 8Oct15, NM
%    eval(CmpEvalTxt);
%    % Loss Compression
%    ParamHIGUI.HLdB_LossCompression(nfag) = interp1(ParamHIGUI.Table_DegreeCompressionPreSet, ...
%             ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(:,nfag),ParamHIGUI.DCcmpnst(nfag));
% end;
%ParamHIGUI.DegreeCompression_Faudgram = ParamHIGUI.DCcmpnst;
%ParamHIGUI.HLdB_LossLinear  = ParamHIGUI.HearingLevelVal - ParamHIGUI.HLdB_LossCompression;

% �}�����`��
LenFag = length(ParamHIGUI.FaudgramList);
for nfag = 1:LenFag   % mod
    CmpEvalTxt = ['set(handles.editCmp' num2str(nfag) ', ''String'',' num2str(round(ParamHIGUI.DCcmpnst(nfag)*100)) ')'];%added 8Oct15, NM
    eval(CmpEvalTxt);
end;
%text(0.3,132,'HL');
%text(-0.5,140,'Compression');

plot(handles.axes1, xii, ParamHIGUI.HLdB_LossCompression,'mx-','MarkerSize', 12,'LineWidth',1.2);
%text(nTxt-1,ParamHIGUI.HLdB_LossCompression(nTxt-1)+2, ...
%   ['Preset Compression (' int2str(ParamHIGUI.DegreeCompressionPreSet*100) '%)'], 'FontSize', 12);
%�����T�C�Y��normalized�w��ɕύX 16 Apr 2019, KF
% text(nTxt+0.1,ParamHIGUI.HLdB_LossCompression(nTxt)+4, ...
%     ['HL_{OHC}'], 'FontSize', 12);
text(nTxt+0.1,ParamHIGUI.HLdB_LossCompression(nTxt)+4, ...
    ['HL_{OHC}'], 'FontUnits', 'normalized','FontName','���C���I', 'FontSize', 0.025);


drawnow

set(handles.edit1,'String',num2str(ParamHIGUI.HearingLevelVal(1)));
set(handles.edit2,'String',num2str(ParamHIGUI.HearingLevelVal(2)));
set(handles.edit3,'String',num2str(ParamHIGUI.HearingLevelVal(3)));
set(handles.edit4,'String',num2str(ParamHIGUI.HearingLevelVal(4)));
set(handles.edit5,'String',num2str(ParamHIGUI.HearingLevelVal(5)));
set(handles.edit6,'String',num2str(ParamHIGUI.HearingLevelVal(6)));
set(handles.edit7,'String',num2str(ParamHIGUI.HearingLevelVal(7)));


if isfield(ParamHIGUI.GUI,'NameSndLoad') == 1
    set(handles.LoadText, 'String', ParamHIGUI.GUI.NameSndLoad)
end;

%     %Comp�̃e�L�X�g�{�b�N�X�ɒl����� %12 Nov15
%     CmpEvalTxt = ['set(handles.editCmp' num2str(nfag) ', ''String'',' num2str(round(ParamHIGUI.DCcmpnst(nfag)*100)) ')'];%added 8Oct15, NM
%     eval(CmpEvalTxt);

%handles.HIplot
guidata(hObject, handles);
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Audiogram UI       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MouseDraggedAdgm_Callback(hObject, eventdata, handles)
global ParamHIGUI

disp(hObject)
set(handles.HIsimFig,'WindowButtonDownFcn',@myBDCallback);
set(handles.HIsimFig,'WindowButtonUpFcn', @myBUCallback);
set(handles.HIsimFig, 'KeyPressFcn', @myKPFcn);%6 Aug 2015, NM
set(handles.HIsimFig, 'KeyReleaseFcn', @myKRFcn);%5 Nov 15, NM



%%%%%%%%%%%%%%%%%%�ǉ��@9Jul15
    function myBDCallback(src, eventdata)
        handles = guidata(src);
        set(src,'WindowButtonMotionFcn',@myBMCallback);
        guidata(hObject, handles);%%���邩��? 6Aug15, NM
    end

    function myBMCallback(src, eventdata)
        Cp = get(gca,'CurrentPoint');
        if (7.5 > Cp(1,1))&&(Cp(1,1) > 0.5)
            if Cp(1,2) > 120
                Cp(1,2) = 120;
            elseif Cp(1,2) < -20
                Cp(1,2) = -20;
            end
            if ParamHIGUI.GUI.KeyPress == 1;%�}�[���^�̃I�[�W�I�O�����𑀍삷��Ƃ�
                disp(ParamHIGUI.HLdB_LossCompression)
                ParamHIGUI.CompAdgmVal = ParamHIGUI.HLdB_LossCompression;
                %limitter 11Nov15, NM
                % %             (1)
                % %             if Cp(1,2) > ParamHIGUI.HearingLevelVal(1,round(Cp(1,1)))
                % %                 ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = ParamHIGUI.HearingLevelVal(1,round(Cp(1,1)));
                % %             elseif ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(1,round(Cp(1,1)))> Cp(1,2)%100per��菬�����ꍇ
                % %                 ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(1,round(Cp(1,1)));
                % %             elseif Cp(1,2) > ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(5,round(Cp(1,1)))%0per���傫���ꍇ
                % %                 ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(5,round(Cp(1,1)));
                % %             else
                % %                 ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = round(Cp(1,2));
                % %             end
                
                % %             (2)
                if Cp(1,2) > ParamHIGUI.HearingLevelVal(1, round(Cp(1,1)))
                    ParamHIGUI.CompAdgmVal(1, round(Cp(1,1))) = ParamHIGUI.HearingLevelVal(1, round(Cp(1,1)));
                elseif Cp(1,2) > ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(5,round(Cp(1,1)));
                    ParamHIGUI.CompAdgmVal(1, round(Cp(1,1))) = ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(5,round(Cp(1,1)));
                else
                    ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = round(Cp(1,2));
                end
                
                % %         (3)
                % %             if  ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(1,round(Cp(1,1))) > Cp(1,2)%100per��菬�����ꍇ
                % %                 ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(1,round(Cp(1,1)));
                % %             elseif Cp(1,2) > ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(5,round(Cp(1,1)))%0per���傫���ꍇ
                % %                 if ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(1,round(Cp(1,1))) > ParamHIGUI.HearingLevelVal(1,round(Cp(1,1)));%�����0per���傫��������
                % %                     %���ɍ��킷
                % %                     ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = ParamHIGUI.HearingLevelVal(5,round(Cp(1,1)));
                % %                 elseif ParamHIGUI.HearingLevelVal(1,round(Cp(1,1))) > ParamHIGUI.HearingLevelVal(5,round(Cp(1,1)));%0per��荕���傫��������
                % %                     %0per�ɍ��킷
                % %                     ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = ParamHIGUI.HearingLevelVal(5,round(Cp(1,1)));
                % %                 else
                % %                     ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(5,round(Cp(1,1)));
                % %                 end
                % %             else
                % %                 ParamHIGUI.CompAdgmVal(1,round(Cp(1,1))) = round(Cp(1,2));
                % %             end
                
                disp(ParamHIGUI.CompAdgmVal)
                DrawAudiogram(hObject, eventdata, handles);
                
            else %���̃I�[�W�I�O�����𑀍삷��Ƃ�%%
                if abs(round(Cp(1,2)) - ParamHIGUI.HearingLevelVal(1,round(Cp(1,1)))) < 10;%10dB�ȓ��Ȃ�
                    ParamHIGUI.HearingLevelVal(1,round(Cp(1,1))) = round(Cp(1,2));
                    DrawAudiogram(hObject, eventdata, handles);
                    SetEdit = ['set(handles.edit' num2str(round(Cp(1,1))) ', ''String'', num2str(ParamHIGUI.HearingLevelVal(' num2str(round(Cp(1,1))) ')));'];
                    eval(SetEdit);
                end
            end%%
        else
            
        end
    end

    function myBUCallback(hObject, eventdata, handles)
        set(hObject,'WindowButtonMotionFcn','');
    end


    function myKPFcn(src, eventdata)%added 6 Aug 2015, NM
        handles = guidata(src);
        GetCrntKey = get(src, 'CurrentKey');
        if strcmp(GetCrntKey, 'shift') == 1;
            ParamHIGUI.GUI.KeyPress = 1;
        end
    end

    function myKRFcn(src, eventdata);
        ParamHIGUI.GUI.KeyPress = 2;
    end


guidata(hObject, handles);
% hObject    handle to Audiogram4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Audiogram Edit box in the bottom     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% edit box %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%125Hz-----------------------------------------------------
function edit1_Callback(hObject, eventdata, handles)
global ParamHIGUI
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.edit1,'String');
ParamHIGUI.HearingLevelVal(1) = str2double(ValWinEdit);%added 23 Jul 15
if ParamHIGUI.HearingLevelVal(1) > 120;
    ParamHIGUI.HearingLevelVal(1) = 120;
elseif ParamHIGUI.HearingLevelVal(1) < -20;
    ParamHIGUI.HearingLevelVal(1) = -20;
end
DrawAudiogram(hObject, eventdata, handles);
%set(handles.slider1,'Value', -str2double(ValWinEdit)); %str2double�ŕ�����𐔒l��
guidata(hObject,handles);
%set(handles.TextStatus,'String',ValWinEdit);
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


%250Hz-----------------------------------------------------
function edit2_Callback(hObject, eventdata, handles)
global ParamHIGUI
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.edit2,'String');
ParamHIGUI.HearingLevelVal(2) = str2double(ValWinEdit);%added 23 Jul 15
if ParamHIGUI.HearingLevelVal(2) > 120;
    ParamHIGUI.HearingLevelVal(2) = 120;
elseif ParamHIGUI.HearingLevelVal(2) < -20;
    ParamHIGUI.HearingLevelVal(2) = -20;
end
DrawAudiogram(hObject, eventdata, handles);
%set(handles.slider2,'Value', -str2double(ValWinEdit)); %str2double�ŕ�����𐔒l��
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


%500Hz------------------------------------------------------
function edit3_Callback(hObject, eventdata, handles)
global ParamHIGUI
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.edit3,'String');
ParamHIGUI.HearingLevelVal(3) = str2double(ValWinEdit);%added 23 Jul 15
if ParamHIGUI.HearingLevelVal(3) > 120;
    ParamHIGUI.HearingLevelVal(3) = 120;
elseif ParamHIGUI.HearingLevelVal(3) < -20;
    ParamHIGUI.HearingLevelVal(3) = -20;
end
DrawAudiogram(hObject, eventdata, handles);
%set(handles.slider3,'Value', -str2double(ValWinEdit));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%1000Hz------------------------------------------------------------------
function edit4_Callback(hObject, eventdata, handles)
global ParamHIGUI
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.edit4,'String');
ParamHIGUI.HearingLevelVal(4) = str2double(ValWinEdit);%added 23 Jul 15
if ParamHIGUI.HearingLevelVal(4) > 120;
    ParamHIGUI.HearingLevelVal(4) = 120;
elseif ParamHIGUI.HearingLevelVal(4) < -20;
    ParamHIGUI.HearingLevelVal(4) = -20;
end
DrawAudiogram(hObject, eventdata, handles);
%set(handles.slider4,'Value', -str2double(ValWinEdit));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
end

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%1000Hz----------------------------------------------------------
function edit5_Callback(hObject, eventdata, handles)
global ParamHIGUI
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.edit5,'String');
ParamHIGUI.HearingLevelVal(5) = str2double(ValWinEdit);%added 23 Jul 15
if ParamHIGUI.HearingLevelVal(5) > 120;
    ParamHIGUI.HearingLevelVal(5) = 120;
elseif ParamHIGUI.HearingLevelVal(5) < -20;
    ParamHIGUI.HearingLevelVal(5) = -20;
end
DrawAudiogram(hObject, eventdata, handles);
%set(handles.slider6,'Value', -str2double(ValWinEdit));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
end

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%2000Hz----------------------------------------------------------
function edit6_Callback(hObject, eventdata, handles)
global ParamHIGUI
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.edit6,'String');
ParamHIGUI.HearingLevelVal(6) = str2double(ValWinEdit);%added 23 Jul 15
if ParamHIGUI.HearingLevelVal(6) > 120;
    ParamHIGUI.HearingLevelVal(6) = 120;
elseif ParamHIGUI.HearingLevelVal(6) < -20;
    ParamHIGUI.HearingLevelVal(6) = -20;
end
DrawAudiogram(hObject, eventdata, handles);
%set(handles.slider6,'Value', -str2double(ValWinEdit));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
end

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



%8000Hz----------------------------------------------------------------
function edit7_Callback(hObject, eventdata, handles)
global ParamHIGUI
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.edit7,'String');
ParamHIGUI.HearingLevelVal(7) = str2double(ValWinEdit);%added 23 Jul 15
if ParamHIGUI.HearingLevelVal(7) > 120;
    ParamHIGUI.HearingLevelVal(7) = 120;
elseif ParamHIGUI.HearingLevelVal(7) < -20;
    ParamHIGUI.HearingLevelVal(7) = -20;
end
DrawAudiogram(hObject, eventdata, handles);
% guidata(hObject,handles);
%set(handles.slider7,'Value', -str2double(ValWinEdit));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
end

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


%%%%edit compression%%%%%% %NM, 8 Oct 2015
function editCmp1_Callback(hObject, eventdata, handles)
global ParamHIGUI;
% hObject    handle to editCmp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.editCmp1,'String');
EC1 = str2double(ValWinEdit)/100;
ParamHIGUI.HLdB_LossCompression(1) = interp1(ParamHIGUI.Table_DegreeCompressionPreSet, ...
    ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(:,1),EC1,'linear','extrap');
DrawAudiogram(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of editCmp1 as text
%        str2double(get(hObject,'String')) returns contents of editCmp1 as a double
end

% --- Executes during object creation, after setting all properties.
function editCmp1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCmp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function editCmp2_Callback(hObject, eventdata, handles)
global ParamHIGUI;
% hObject    handle to editCmp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.editCmp2,'String');
EC2 = str2double(ValWinEdit)/100;
ParamHIGUI.HLdB_LossCompression(2) = interp1(ParamHIGUI.Table_DegreeCompressionPreSet, ...
    ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(:,2),EC2,'linear','extrap');
DrawAudiogram(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of editCmp2 as text
%        str2double(get(hObject,'String')) returns contents of editCmp2 as a double
end

% --- Executes during object creation, after setting all properties.
function editCmp2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCmp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function editCmp3_Callback(hObject, eventdata, handles)
global ParamHIGUI;
% hObject    handle to editCmp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.editCmp3,'String');
EC3 = str2double(ValWinEdit)/100;
ParamHIGUI.HLdB_LossCompression(3) = interp1(ParamHIGUI.Table_DegreeCompressionPreSet, ...
    ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(:,3),EC3,'linear','extrap');
DrawAudiogram(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of editCmp3 as text
%        str2double(get(hObject,'String')) returns contents of editCmp3 as a double
end

% --- Executes during object creation, after setting all properties.
function editCmp3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCmp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function editCmp4_Callback(hObject, eventdata, handles)
global ParamHIGUI;
% hObject    handle to editCmp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.editCmp4,'String');
EC4 = str2double(ValWinEdit)/100;
ParamHIGUI.HLdB_LossCompression(4) = interp1(ParamHIGUI.Table_DegreeCompressionPreSet, ...
    ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(:,4),EC4,'linear','extrap');
DrawAudiogram(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of editCmp4 as text
%        str2double(get(hObject,'String')) returns contents of editCmp4 as a double
end

% --- Executes during object creation, after setting all properties.
function editCmp4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCmp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function editCmp5_Callback(hObject, eventdata, handles)
global ParamHIGUI;
% hObject    handle to editCmp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.editCmp5,'String');
EC5 = str2double(ValWinEdit)/100;
ParamHIGUI.HLdB_LossCompression(5) = interp1(ParamHIGUI.Table_DegreeCompressionPreSet, ...
    ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(:,5),EC5,'linear','extrap');
DrawAudiogram(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of editCmp5 as text
%        str2double(get(hObject,'String')) returns contents of editCmp5 as a double
end

% --- Executes during object creation, after setting all properties.
function editCmp5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCmp5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function editCmp6_Callback(hObject, eventdata, handles)
global ParamHIGUI;
% hObject    handle to editCmp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.editCmp6,'String');
EC6 = str2double(ValWinEdit)/100;
ParamHIGUI.HLdB_LossCompression(6) = interp1(ParamHIGUI.Table_DegreeCompressionPreSet, ...
    ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(:,6),EC6,'linear','extrap');
DrawAudiogram(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of editCmp6 as text
%        str2double(get(hObject,'String')) returns contents of editCmp6 as a double
end

% --- Executes during object creation, after setting all properties.
function editCmp6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCmp6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function editCmp7_Callback(hObject, eventdata, handles)
global ParamHIGUI;
% hObject    handle to editCmp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ValWinEdit = get(handles.editCmp7,'String');
EC7 = str2double(ValWinEdit)/100;
ParamHIGUI.HLdB_LossCompression(7) = interp1(ParamHIGUI.Table_DegreeCompressionPreSet, ...
    ParamHIGUI.Table_HLdB_DegreeCompressionPreSet(:,7),EC7,'linear','extrap');
DrawAudiogram(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of editCmp7 as text
%        str2double(get(hObject,'String')) returns contents of editCmp7 as a double
end

% --- Executes during object creation, after setting all properties.
function editCmp7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCmp7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end





%%added 15Jun15 NM
function moveWhileMouseUp(hObject, handles)
%function moveWhileMouseUp(hObject)
%function moveWhileMouseUp(hObject, eventdata, handles)
handles = guidata(hObject);
guidata(hObject, handles);
%handles = guidata(src);
getCurrentPoint = get(handles.axes1,'currentPoint');
disp(getCurrentPoint);
% xLimit = get(handles.axes1,'xlim');
% yLimit = get(handles.axes1,'ylim');
% %disp('xlimit =' xLimit);

% xData = get(handles.HIsimFig, 'xdata');
% yData = get(handles.HIsimFig, 'ydata');
% distanceInSlider = sqrt((currentPoint(1,1)-xData)^2+(currentPoint(1,2)-yData)^2);
% if distanceInSlider < 0.2
%     isCloseInd = true;
% end;

%if isCloseToSliderMarker(handles)
if isCloseToSliderMarker(hObject)
    %handles = guidata(hObject);
    set(hObject,'Pointer','hand');
    %set(hObject,'Pointer','hand');
elseif isCloseToModifierMarker(hObject)
    %set(src,'Pointer','hand');
    set(hObject,'Pointer','hand');
else
    %set(src,'Pointer','crosshair');
    set(hObject,'Pointer','arrow');
end;
%guidata(hObject, handles);       %����Ȃ��H
end

%%added 17 Jun 15, NM. (from vtShapeTosoundTestV10.m)
%function isCloseInd = isCloseToSliderMarker(handles)
%function isCloseInd = isCloseToSliderMarker(hObject, handles)
function isCloseInd = isCloseToSliderMarker(hObject)%���͂�handles�̕����ǂ��H
%18 Jun 2015, NM
% - plot�̒l��global�ϐ��ɂ��Ă݂�
% �����n�����͂ł������AHIplot�̒l���s�񂶂�Ȃ��Ă����̐��l�������c
% HIplot�̐ݒ�̎d���ς��Ȃ���΁@�e�_�̍��W�̒l���Ƃ��悤��
% �ꉞ���̂ō��W��\�����Ă���
global ParamHIGUI;
% -

handles = guidata(hObject);
disp('at isCloseToSliderMarker');
%disp(handles)
%disp(handles.HIplot)
isCloseInd = false;
SliderCurrentPoint = get(handles.HIsimFig, 'CurrentPoint');
disp(SliderCurrentPoint);
%CurrentPoint = get(handles.axes1, 'CurrentPoint');
%currentPoint = get(handles.HIsimFig,'currentPoint');
%xLimit = get(handles.sliderAxis,'xlim');
%yLimit = get(handles.sliderAxis,'ylim');

%commented 18 Jun 2015, NM
%for ii = 1:7;

%     disp('xData')
%     disp(xData)
%xData = get(handles.HIplot(ii),'xdata');
%yData = get(handles.HIplot(ii),'ydata');
%xData = 5;
%yData = 0;
% % % %     distanceInSlider = sqrt((SliderCurrentPoint(1,1)-xData)^2+(SliderCurrentPoint(1,2)-yData)^2);
%end;
% % % % if distanceInSlider < 0.2
% % % %     isCloseInd = true;
% % % % end;
guidata(hObject, handles);
end

% added 18 Jun 2015, NM
function isCloseInd = isCloseToModifierMarker(hObject)%���͂�handles�̕����ǂ��H
%disp('at isCloseToModifierMarker');
handles = guidata(hObject);
isCloseInd = false;
%currentPoint = get(handles.HIsimFig,'currentPoint'); %�ϐ����ς��������ǂ��Ǝv��
%disp(currentPoint);
guidata(hObject, handles);
end

% added 02 May 2019, KF
%Windows10��ŁA�ʏ�I�������ɂ��ւ�炸�o�b�O�O���E���h�œ��삵������Ƃ������̑΍�
%�N���[�Y�{�^�����������Ƃ��ɁAtaskkill�R�}���h��p���ăo�b�O�O���E���h�������Ƌ����I��
%����̍�Btaskkill�����ɍςޕ��@������Έ�Ԃ�����ł���...
%
% 9 May 19 IT.  ����ŗǂ��Ǝv���܂��B�Ώ����肪�Ƃ��B
% Mac���ƁAtaskkill�����s����Ȃ��悤�ɂ��܂����B
%   �i�ǂ���mac�ł̓R�}���h���Ȃ��̂ŃG���[�œ����Ȃ��ł��傤���B�j
%
% Modified: 7 Feb 2020, KF
%   ���s�t�@�C���̖��̕ύX�ɔ����āA�^�X�N�L���p�̃R�}���h��ύX
% Modified: 7 Feb 2020, IT
%   �R�����g�ǉ�
function process_closereq(src,callbackdata)

delete(gcf);
if ispc  % PC ����������s�Bmac�ł̓p�X�@IT, 9 May 19
    %"HIsimulator.exe"�Ƃ������O�̎��s�t�@�C�����^�X�N�L��
    % NameExecFile = 'HIsimulator.exe';
    % ��ɃR���p�C�����ꂽ���s�t�@�C�����ƈ�v������悤�ɁBIT, 7 Feb 2020
    NameExecFile = 'WHISv225.exe';
    [~,cmdout] = system(['taskkill /F /IM ' NameExecFile ' /T']);
    %[~,cmdout] = system('taskkill /F /IM MATLAB.exe /T');
    disp('Finished: Process on Win PC  ');
else
    disp('Finished:  Process on Mac ');
end;

clear   % clear��ǉ�  23 Jul 19
end





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Trush %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%GetDegreeCompression(hObject, eventdata, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupCmprs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCmprs


% function GetDegreeCompression(hObject, eventdata, handles)
% global ParamHIGUI
% if isfield(ParamHIGUI, 'getComp') == 1
% % disp(ParamHIGUI.getComp);
%     if     ParamHIGUI.getComp == 100,  ParamHIGUI.DegreeCompressionPreSet = 1;
%     elseif ParamHIGUI.getComp == 67,  ParamHIGUI.DegreeCompressionPreSet = 2/3;
%     elseif ParamHIGUI.getComp == 33,  ParamHIGUI.DegreeCompressionPreSet = 1/3;
%     elseif ParamHIGUI.getComp == 0,  ParamHIGUI.DegreeCompressionPreSet = 0;
%     end;
% else
%     ParamHIGUI.getComp = 100;
%     ParamHIGUI.DegreeCompressionPreSet = 1;
% % disp(['Degree Compression: ' int2str(ParamHIGUI.DegreeCompressionPreSet*100) '%']);
% end
% end

%%
% --- Executes on button press in pushbutton_dB.
%function pushbutton_dB_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_dB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%end

% Equalize and playback here, first (IT, 21 Jun 2014)
% Obsolete version:  EqualizeSourceSoundSPLdB(hObject, eventdata, handles)
% Load�����M�����ACalibTone�̊��mdB���x����normalize
% popupSPLdB_Callback���Ă΂Ȃ��ꍇ�@==�@default�l�̏ꍇ (9 Jul 2016)
% ParamHIGUI.SrcSndSPLdB = ParamHIGUI.SPLdB_CalibTone;
% RMSlevel_SndLoad = sqrt(mean(ParamHIGUI.SndLoad.^2));
% RMSlevel_CalibTone = sqrt(mean(ParamHIGUI.RecordedCalibTone.^2));
% Amp1 = RMSlevel_CalibTone/RMSlevel_SndLoad;
% ParamHIGUI.OrigSnd = Amp1*ParamHIGUI.SndLoad;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Equalization of Sound  �͕s�v�Bmain��MdsHCL��normalize  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% New Equalization using Calib Tone @ 70 dB
%function CnvrtLevel_CalibTone2MdsHCL(hObject, eventdata, handles)
%global ParamHIGUI

%RMSlevel_CalibTone = sqrt(mean(ParamHIGUI.RecordedCalibTone.^2));
% It is ParamHIGUI.SPLdB_CalibTone (= 70 dB).
% MdsHCL_CalibTone = 1 * 10^((ParamHIGUI.SPLdB_CalibTone - 110)/20);
%MdsHCL_CalibTone = 0.01 * 10^((ParamHIGUI.SPLdB_CalibTone - 70)/20);
%
%ParamHIGUI.SrcSnd = MdsHCL_CalibTone/RMSlevel_CalibTone*ParamHIGUI.OrigSnd;

% not using Eqlz2MeddisHCLevel for HTML version
%

% [SrcSnd_MdsHCL, AmpdB] = Eqlz2MeddisHCLevel(ParamHIGUI.OrigSnd, ParamHIGUI.SrcSndSPLdB);

% Note:
% Setting SrcSnd Level in this program
% rms(s(t)) == sqrt(mean(s.^2)) == 0.001 (-60dB FS)  --> 50 dB SPL
% rms(s(t)) == sqrt(mean(s.^2)) == 0.01  (-40dB FS)  --> 70 dB SPL
% rms(s(t)) == sqrt(mean(s.^2)) == 0.1   (-20dB FS)  --> 90 dB SPL
%
% cf. MeddisHCLevel(30dBSPL)
%  rms(s(t)) == sqrt(mean(s.^2)) == 1   --> 30 dB SPL
%  rms(s(t)) == sqrt(mean(s.^2)) == 10  --> 50 dB SPL
%  rms(s(t)) == sqrt(mean(s.^2)) == 100 --> 70 dB SPL
%
%  Difference between two levels is 80 dB.
%
%  It is different from sound setting using
%  [SndOut] = EqlzDigitalLevel(SndIn,fs,-26,'LAeq');
%  No 'LAeq'. It corresponds 'rms'.
%
%

% end




%{
%%%%%%%%%%% Equalize RMS SPL dB %%%%%%%%%%%
function EqualizeSourceSoundSPLdB(hObject, eventdata, handles)
global ParamHIGUI

if isfield(ParamHIGUI,'OrigSnd') == 0,
   set(handles.TextStatus, 'String', 'Load Sound')
   return;
end;

[SrcSnd_MdsHCL, AmpdB] = Eqlz2MeddisHCLevel(ParamHIGUI.OrigSnd, ParamHIGUI.SrcSndSPLdB);

 % Note:
 % Setting SrcSnd Level in this program
 % rms(s(t)) == sqrt(mean(s.^2)) == 0.001 (-60dB FS)  --> 50 dB SPL
 % rms(s(t)) == sqrt(mean(s.^2)) == 0.01  (-40dB FS)  --> 70 dB SPL
 % rms(s(t)) == sqrt(mean(s.^2)) == 0.1   (-20dB FS)  --> 90 dB SPL
 %
 % cf. MeddisHCLevel(30dBSPL)
 %  rms(s(t)) == sqrt(mean(s.^2)) == 1   --> 30 dB SPL
 %  rms(s(t)) == sqrt(mean(s.^2)) == 10  --> 50 dB SPL
 %  rms(s(t)) == sqrt(mean(s.^2)) == 100 --> 70 dB SPL
 %
 %  Difference between two levels is 80 dB.
 %
 %  It is different from sound setting using
 %  [SndOut] = EqlzDigitalLevel(SndIn,fs,-26,'LAeq');
 %  No 'LAeq'. It corresponds 'rms'.
 %
 %

ParamHIGUI.MeddisHCLevel2WavLeveldB  = -80; % -80dB
ParamHIGUI.MeddisHCLevel2WavLevelMag = 10^(ParamHIGUI.MeddisHCLevel2WavLeveldB/20);
ParamHIGUI.SrcSnd = ParamHIGUI.MeddisHCLevel2WavLevelMag*SrcSnd_MdsHCL;
if max(abs(ParamHIGUI.SrcSnd)) >= 1;
    warning('max(abs(ParamHIGUI.SrcSnd)) >= 1 -- It should be distorted.');
    % see doc audioplayer    double x:  -1< x < 1
end;
ParamHIGUI.SrcSndPlayer = ...
    audioplayer(ParamHIGUI.SrcSnd,ParamHIGUI.fs,ParamHIGUI.Nbits);

set(handles.TextStatus, 'String', 'Playing Source');
pause(0.01); % for display text
playblocking(ParamHIGUI.SrcSndPlayer);
set(handles.TextStatus, 'String', 'Playing Source  -- done');

if ParamHIGUI.SwKeepSnd == 1,
    NameKeepSnd = [ParamHIGUI.GUI.NameKeepSrcSnd '.wav'];
    audiowrite(NameKeepSnd, ParamHIGUI.SrcSnd, ParamHIGUI.fs, ...
               'BitsPerSample',ParamHIGUI.Nbits);
end;

disp(['Equalize RMS SPL: ' num2str(ParamHIGUI.SrcSndSPLdB) '  (dB)']);
disp(['RMS value = ' num2str(sqrt(mean(ParamHIGUI.SrcSnd.^2))) ...
    ', [Max Min] = [' num2str(max(ParamHIGUI.SrcSnd),3) ',' ...
                      num2str(min(ParamHIGUI.SrcSnd),3) ']']);
end


        % �O�o�[�W�����A�i�D���ǂ��Ȃ��B
        %    else
        %        if     ParamHIGUI.getComp == 100, ParamHIGUI.DegreeCompressionPreSet = 1;
        %        elseif ParamHIGUI.getComp == 67,  ParamHIGUI.DegreeCompressionPreSet = 2/3;
        %        elseif ParamHIGUI.getComp == 50,  ParamHIGUI.DegreeCompressionPreSet = 0.5;
        %        elseif ParamHIGUI.getComp == 33,  ParamHIGUI.DegreeCompressionPreSet = 1/3;
        %        elseif ParamHIGUI.getComp == 0,   ParamHIGUI.DegreeCompressionPreSet = 0;
        %        end;
        %    end


%}
