%
%     HIsimFastGC_GUI でParamHIを初期設定する
%     Irino, T.
%     Created:   7 Jul  2018
%     Modified:  7 Jul  2018
%     Modified: 11 Jul 2018 (ParamHI_Inputを受け取り継承できるように）
%     Modified:  5 Aug 2018 (ParamHI_Inputを受け取り継承。上書きのバグ修正）
%     Modified: 16 Oct 2018 （重要なので音圧設定をプログラムの上に持ってきて、見やすく）
%     Modified: 18 Oct 2018 (defaultのセッティングを禁止：必ず指定させるように。間違い防止。）
%     Modified:  20 Oct 2018  (IT, ParamHI.SwGUIbatch = 'GUI' or 'Batch'の明示必須に)
%     Modified:  27 Dec 2018  (IT, バグfix)
%     Modified:  19 Dec 2019  (IT, ParamHI.SrcSndSPLdB_default導入)
%     Modified:   6  Mar 2022   WHISv300_func --> WHISv30_func 
%  
%     ParamHI.AudiogramNum : audiogram select
%                 1.example 1
%                 2.立木2002 80yr
%                 3.ISO7029 70yr 男
%                 4.ISO7029 70yr 女
%                 5.ISO7029 60yr 男
%                 6.ISO7029 60yr 女
%                 7.耳硬化症(よくわかるオージオグラムp.47)
%                 8.騒音性難聴(よくわかるオージオグラムp.63)
%                 9.手動入力　manual input%
%
%
function ParamHI = WHISv30_InitParamHI(ParamHI_Input)

if nargin < 1
    error('paramHI_Inputは必須パラメータ.');
end
ParamHI = ParamHI_Input;

ParamHI.SwKeepSnd = 1;  % keep sound for debugging
% ParamHI.SwKeepSnd = 0;  % no keeping sound 

%%  %%%%%%%%%%%%%%%%%%%%%%%%
% Calibration toneの音圧設定  18Oct18
%  ディジタルRMSレベル-26dBの1 kHzのsin波[Sin1kHz-26dB]を再生した時の音圧をここで設定
%  CalibToneが[Sin1kHz-26dB]ではない場合は、[Sin1kHz-26dB]に対応する音圧を計算して設定.
%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(ParamHI.SwGUIbatch,'GUI') == 1   % GUI版の場合 
    % 変更したい場合は要相談
    % この値は、大きな声でGUI版に話しかけた場合でもclippingしないような設定を目指した。
    % ParamHI.SPLdB_CalibToneの値を70（orそれ以下）とするとclippingの恐れが大きい。
    ParamHI.SPLdB_CalibTone = 80; % 経験からの設定値　-- GUIから変更できない
    ParamHI.SrcSndSPLdB_default = 65;        % 特にLoadSoundする時のdefault値　19Apr19
    ParamHI.SrcSndSPLdB = ParamHI.SrcSndSPLdB_default;  
        %   後からGUIで変更可能　19 Apr 19
        %   校正でCalibration toneを録再生すると、ParamHI.SrcSndSPLdBは
        %   ParamHI.SPLdB_CalibToneと同じになってしまう。　ーー＞   値は別に制御したい。
    
elseif   strcmp(ParamHI.SwGUIbatch,'Batch') == 1 % Batch版の場合  
    %  default値は無し。必ず指定すること。
    if isfield(ParamHI,'SPLdB_CalibTone') == 0
        % ディジタルレベルと外界の音圧との対応付けをする。
        %        消去： ParamHI.SPLdB_CalibTone = 80; default値を禁止
        % disp('      - HIsimFastGC_MkCalibTone(ParamHI); の ParamHI.CalibTone_RMSDigitalLeveldB==-26');
        %  Modified:  18 Oct 18 (defaultのセッティングを禁止：必ず指定させるように。間違い防止。）
        warning('*********  Error **************');
        disp('ParamHI.SPLdB_CalibTone  を指定するように. (defaultは無し)');
        disp('ディジタルRMSレベル-26dBの1 kHzのsin波[Sin1kHz-26dB]を再生した時の音圧をここで設定');
        disp('      - 聴取実験では、ParamHI.SrcSndSPLdBと同じにすることが多いと考えられる.');
        disp('      - ParamHI.SPLdB_CalibTone = 65  くらいと思われる. 実験の提示音圧の設定から.');
        disp('      - CalibToneが[Sin1kHz-26dB]ではない場合は、[Sin1kHz-26dB]に対応する音圧を計算して設定.');
        error('設定エラー.   上記の記述を参考に設定すること.');
    end;
    if isfield(ParamHI,'SrcSndSPLdB') == 0
        % SrcSndのRMSレベルを設定
        %    消去： ParamHI.SrcSndSPLdB = 65; default値は禁止
        warning('*********  Error **************');
        disp('ParamHI.SrcSndSPLdB  を指定するように. (defaultは無し)');
        disp('     - ParamHISrcSndSPLdB = 65  くらいと思われる. 実験の提示音圧の設定から.');
        error('設定エラー.   SrcSndのRMS音圧レベルを設定すること.');
    end;

else
    error('Specify ParamHI.SwGUIbatch :  "GUI" or  "Batch".');
end   %if strcmp(ParamHI.SwGUIbatch,'GUI') == 1

StrSPL =  int2str(ParamHI.SPLdB_CalibTone);
ParamHI.CalibTextLabel   = cellstr([{['Set to ' StrSPL ' dB']}, {[ StrSPL ' dBに設定']}]);  


%% %%%%%%%%%%%%%%%%%%%%%%%%
% HIsimFastGCの出力調整用パラメータ。12 Dec 2018 
%  HISparam.SwAmpCmpnst = 1;  % orginal method (4 Feb 2014)
%  orginal methodにする場合、外部からHISparam.SwAmpCmpnst = 1と指定すること。
%  HIsimFastGC.m （HISparam <-- ParamHI ） -- Line 178以降を参照。
%  ParamHI.SwAmpCmpnst = 1;  % orginal method, 4 Feb 2014
%  ParamHI.SwAmpCmpnst = 2;  % Table lookup   12 Dec 2018 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(ParamHI,'SwAmpCmpnst')  == 0,
    % defaultは、新規設定版。12 Dec 2018  
    ParamHI.SwAmpCmpnst = 2;  % default  ーー　Table lookup   12 Dec 2018  
end


%%  %%%%%%%%%%%%%%%%%%%%%%%%
% audiogramの諸設定
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
ParamHI.fs = ParamHI_Input.fs;   % bug fix 27 Dec 18
ParamHI.Nbits = 24; % set bits here

ParamHI.FaudgramList = 125*2.^(0:6);              %[125 250 500, 1000, 2000, 4000, 8000]
ParamHI.DegreeCompression_Faudgram = [0 0 0 0 0 0 0];
ParamHI.HLdB_LossLinear = [0 0 0 0 0 0 0];

%難聴のパラメータ
ParamHI.HL_ISO7029_Ex = [ 8  8  9 10 19 43 59; ... % ISO7029 70yr 男
                             8  8  9 10 16 24 41; ... % ISO7029 70yr 女
                             5  5  6  7 12 28 39; ... % ISO7029 60yr 男
                             5  5  6  7 11 16 26; ... % ISO7029 60yr 女
                           ];
ParamHI.HL_Tsuiki2002_80yr = [ 23.5, 24.3, 26.8, 27.9, 32.9, 48.3, 68.5]; % 立木2002　80yr 平均
                       
ParamHI.HearingLevelList = [10  4 10 13 48 58 79; ...  %example 1
                               ParamHI.HL_Tsuiki2002_80yr; ...  % 立木2002　80yr
                               ParamHI.HL_ISO7029_Ex; ... % ISO7029  4種類
                               50 55 50 50 40 25 20; ...%耳硬化症(よくわかるオージオグラムp.47)
                               15 10 15 10 10 40 20; ...%騒音性難聴(よくわかるオージオグラムp.63)
                               NaN*ones(1,7)];  % 手動入力　manual input -- これは必ずListの最終段に置くこと。

ParamHI.Table_AudiogramName = {'Ex1', ...
                                '80yr_Male','70yr_Male', '70yr_Female', ...
                                '60yr_Male', '60yr_Female', ...
                                'Otosclerosis', 'C5Dip', 'Manual'};  % 対応が間違いないように。

% 整合性があるように書くこと　{英語}{日本語}
%表示ラベル／言語の設定　のところで使用。
ParamHI.SetAdgmList = cellstr([...
                                {'Set Audiogram'},   {'-- 選択 --'}; ...
                                {'Example HI#1'},    {'難聴者 例1'};...
                                {'80yr Ave (Tsuiki2002)'},  {'80歳 平均 (立木2002)'};...
                                {'70yr Male (ISO7029)'},  {'70歳 男 (ISO7029)'};...
                                {'70yr Female (ISO7029)'}, {'70歳 女 (ISO7029)'};...
                                {'60yr Male (ISO7029)'},  {'60歳 男 (ISO7029)'};...
                                {'60yr Female (ISO7029)'}, {'60歳 女 (ISO7029)'};...
                                {'Otosclerosis'},    {'耳硬化症'}; ...
                                {'Noise-induced'},   {'騒音性難聴 (C5dip)'}; ...
                                {'Manual'},          {'手動設定'}]);

[ParamHI.LenHLlist, ParamHI.LenFagrm] = size(ParamHI.HearingLevelList);                    

ParamHI.Table_getComp  = [100; 67; 50; 33; 0]; % GUI側の表示値
ParamHI.Table_DegreeCompressionPreSet     = [1; 2/3; 0.5; 1/3; 0]; % 表示値に対応する本当の値。

% AsymFuncから求めた値。HL_OHCはこれで求めているので、これを使うこと。2021/10/12
ParamHI.Table_HLdB_DegreeCompressionPreSet =  [ ...
   34.0000   19.6000    9.7000    4.9000    0.5000    5.4000    3.3000
   38.8566   30.6594   25.6976   22.1259   18.0419   23.8148   21.4690
   40.9698   34.9736   32.1693   29.7996   26.3673   32.4441   30.0962
   42.9096   38.6140   37.4731   36.3657   33.5918   39.5464   37.7582
   46.3609   44.4196   45.0619   45.1542   43.6208   48.4398   47.2515];
%[125,            250,         500,       1000,        2000,       4000,        8000]

% 参考：　Excitation Patternから求めた値--- ずれるので使わない　2021/10/12
% % ParamHI.Table_HLdB_DegreeCompressionPreSet =  [ ...
% %    31.8363   20.8795   13.8731    8.8031    5.0338    8.9894    6.7375
% %    37.9442   31.4894   27.2266   24.3747   21.4198   25.7097   23.6013
% %    40.9350   36.2026   33.4542   31.5527   28.8478   33.3300   31.5149
% %    43.7049   40.6990   39.0911   37.8499   35.8477   40.5115   38.6931
% %    49.7644   48.1142   47.9531   47.8415   46.4644   50.6869   49.4502];
% % %[125,            250,         500,       1000,        2000,       4000,        8000]
  

if ParamHI.SwAmpCmpnst == 2
    % 
    % ParamHI.Table_HLdB_DegreeCompressionPreSetは、0dB HLからの値にする。
    % 計算がわかりにくく、操作上もHL 0dBからの方が直感的。   
    ParamHI.Table_HLdB_DegreeCompressionPreSet = ...
        ParamHI.Table_HLdB_DegreeCompressionPreSet - ...
        ones(5,1)*ParamHI.Table_HLdB_DegreeCompressionPreSet(1,:);  
end


%% %%%%%%%%%%%%
% そのほかの設定
%%%%%%%%%%%%%%%
%明瞭音声発話実験用の設定。LoadSoundを使わないようにする。
ParamHI.SwNoLoadSound4Exp = 0; % 通常モード
%ParamHI.SwNoLoadSound4Exp = 1; % 明瞭音声発話実験用

return

end





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% HIsimGCFBv225では以下の値だった。
%
% aaa =  [ ...
%    -6.7406    2.4563      4.7537      5.7118    1.0655    -3.4335   -7.2814; ...
%    -0.3463   10.0101   17.8573   19.9751   16.8954   14.5161    5.1201; ...
%     2.5999   14.3605   23.7777   26.8029   24.7069   23.5780   10.6923; ...
%     5.4801   18.5666   28.9101   32.6974   31.2244   30.0204   16.0619; ...
%    10.5790   24.9903   36.0186   40.5679   38.9283   36.5154   25.2229];
% % % %[125,            250,         500,       1000,        2000,       4000,        8000]
% 
% 1列目からの差分
% aaa-ones(5,1)*aaa(1,:) = [...
%          0         0         0         0         0         0         0
%     6.3943    7.5538   13.1036   14.2633   15.8299   17.9496   12.4015 ...
%     9.3405   11.9042   19.0240   21.0911   23.6414   27.0115   17.9737 ...
%    12.2207   16.1103   24.1564   26.9856   30.1589   33.4539   23.3433 ...
%    17.3196   22.5340   31.2649   34.8561   37.8628   39.9489   32.5043 ]; 
% 

% WHISv300の場合
%
% % ParamHI.Table_HLdB_DegreeCompressionPreSet =  [ ...
% %    31.8363   20.8795   13.8731    8.8031    5.0338    8.9894    6.7375
% %    37.9442   31.4894   27.2266   24.3747   21.4198   25.7097   23.6013
% %    40.9350   36.2026   33.4542   31.5527   28.8478   33.3300   31.5149
% %    43.7049   40.6990   39.0911   37.8499   35.8477   40.5115   38.6931
% %    49.7644   48.1142   47.9531   47.8415   46.4644   50.6869   49.4502];
% % %[125,            250,         500,       1000,        2000,       4000,        8000]
%
% 1列目からの差分
%          0         0         0         0         0         0         0
%     6.1079   10.6099   13.3535   15.5716   16.3860   16.7203   16.8638
%     9.0987   15.3231   19.5810   22.7497   23.8140   24.3406   24.7773
%    11.8686   19.8195   25.2180   29.0468   30.8139   31.5221   31.9556
%    17.9281   27.2347   34.0800   39.0384   41.4306   41.6975   42.7127


%%  %%%%%%%%%%%%%%%%%%%%%%%%
% Calibration toneの音圧設定
%
% 2016段階：
% default 70dB  NHならこの程度が良いはず。
% ParamHIGUI.SPLdB_CalibTone = 70; % This should be 70 dB for NH listeners.
%
% 変更,  12 Jun 2017
% HI simulator GUI版のCalibration toneの音圧設定: default 80dBに。
% Mic入力時の、digital levelのダイナミックレンジの問題からこちらに変更。
% -26dB RMSの1 kHz sin波(FS換算だと-23dB)が　80 dBに。
%   in function PlayCalibTone_Callback(hObject, eventdata, handles)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 消去分：これはISO7029ではない    10 15 15 15 25 35 43; ...  % 60yrs
% 消去分：これはISO7029ではない    25 30 32 28 38 50 60; ...  % 80yrs
% ParamHIGUI.SwCalibTone = 1;
% OutLeveldB = -26;
% AmpCalib   = 10^(OutLeveldB/20)*sqrt(2); % set about the same as recording level
%
