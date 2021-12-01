%
%   Batch execution function for HIsimFastGC    
%   Yomura, N.,  Okuya,Y.,  Yamauti,Y.,   Irino, T.
%   Created:     x Jun 18   % YO, YY from makeHIsimfile.m (by Yomura, N.,)
%   Modified:    7 Jul 18   % IT, functionを呼ぶように改変
%   Modified:    7 Jul 18   % IT, 名前変更　MkHIsimfile -> HIsimBatch
%   Modified:    8 Jul 18   % IT, debug
%   Modified:  11 Jul 18  % IT, debug
%   Modified:   6 Aug 18  % IT, ParamHIbatchを出力
%    Modified:  16 Oct 18 % IT,  HIsimFastGC_InitParamHI.mの記述を若干変更。
%    Modified:  17 Oct 18 % IT, 利用法を記入。HIsimFastGC(ParamHIbatch.SrcSnd, HISparam);を確認。
%    Modified:  18 Oct 18 % IT, defaultのセッティングを禁止：必ず指定させるように。間違い防止。
%    Modified:  20 Oct 18  % IT, ParamHI.SwGUIbatch = 'GUI' or 'Batch'の明示必須に
%    Modified:  11 Dec 18 % IT, ParamHIbatch.AudiogramNumが、NaNなら、ParamHIbatch.HearingLevelValを直接設定する
%    Modified:  12 Dec  18 % 詳細検討用
% 
%   function [HIsimSnd, SrcSnd] = HIsimBatch(SndIn, ParamHIbatch);
%   INPUT:  SndIn : input sound 
%           ParamHIbatch : parameters
%                        AudiogramNum : audiogram select (1~8の数値)
%                               help HIsimFastGC_InitParamHIで出てくる設定参照のこと。
%                        getComp : compression percent value 
%                                           (0%, 33%, 50%, 67%, 100%の数字)
%                        SPLdB_CalibTone : calibtone level    % デフォルト 80dB
%                        SrcSndSPLdB : source_sound sound pressure level dB  % デフォルト 65dB
%
%   OUTPUT: HIsimSnd : processed sound
%           SrcSnd : source sound  HIsimに入力される信号なので、SrcSndという名前
%           ParamHIbatch: 処理の詳細がわかるように出力
%
%   Note: 利用法  17 Oct 18
%       Calbration tone はdigital levelで、RMS = -26 dB として計算しています。
%       すべての実験で、このCalbration toneを使って再生し、実験にあわせたレベルで校正してください。
%       1) HIsimFastGC_GUIの場合は、80dBで校正します。これは、大きな声が入ってもクリッピングしないように。
%               この場合、ParamHIbatchIn.SPLdB_CalibTone = 80; (default値)です。
%       2) 聴取実験で、Calbration toneを65dBに合わせた場合、
%               ParamHIbatchIn.SPLdB_CalibTone = 65; となるように引数を設定してください。
%
%        背景：計算機は数値だけを知っています。この数値が外界で何dBになるかを知りません。
%                  これを教えるのが、Calbration toneによる校正です。
%                  対応づけがちゃんとできていない場合、計算機の内部処理は間違えます。
%
%
function [HIsimSnd,SrcSnd,ParamHIbatch] = HIsimBatch(SndIn, ParamHIbatchIn) 

[mm, nn] = size(SndIn);
if min(mm, nn)  > 1,
    error('モノラル入力をすること。実験の際、間違えないようにするため。');
    return;
end;
SndIn = SndIn(:)'; % 行ベクトル

%%  %%%%%%%%%%%
% 初期設定  'batch'を明示。　GUIでも同じInitParamHIを使うが、これは'GUI'で利用。
%%%%%%%%%%%%%%%%%
ParamHIbatchIn.SwGUIbatch = 'Batch';
ParamHIbatch = HIsimFastGC_InitParamHI(ParamHIbatchIn);

%% %%%%%%%%%%%%%%%%%
% 音圧レベル合わせ
%%%%%%%%%%%%%%%%%%%%
disp(['SPLdB_CalibTone = '  num2str(ParamHIbatch.SPLdB_CalibTone) ' (dB)']);
disp(['SrcSndSPLdB = '  num2str(ParamHIbatch.SrcSndSPLdB) ' (dB)']);

[CalibTone, ParamHIbatch]  = HIsimFastGC_MkCalibTone(ParamHIbatch);
ParamHIbatch.RecordedCalibTone =  CalibTone; 
    % Batchでは、録音できないので、同じとみなす。
    % 処理の確認では、ここにsaveされたRecordedCalibToneを読み込む。
ParamHIbatch.SndLoad = SndIn;
 [ParamHIbatch] = HIsimFastGC_GetSrcSndNrmlz2CalibTone(ParamHIbatch);
 SrcSnd = ParamHIbatch.SrcSnd; % calbration tone でnormalizeされたSrcSnd

%% %%%%%%%%%%%%%%%%
% 難聴のパラメータ設定
%%%%%%%%%%%%%%%%%%
if isfield(ParamHIbatchIn, 'AudiogramNum') == 0
    ParamHIbatch.AudiogramNum = 3;  % デフォルト ISO7029 70yr 男
end
if isfield(ParamHIbatchIn, 'getComp') == 0
    ParamHIbatch.getComp = 0;  % デフォルト 圧縮特性 0%
end;
% ParamHIbatch.getComp
NumComp = find(ParamHIbatch.getComp == ParamHIbatch.Table_getComp);  %CompはTableから


if isnan(ParamHIbatch.AudiogramNum) == 0, %NaN以外なら、HearingLevelListから設定。
    ParamHIbatch.HearingLevelVal = ParamHIbatch.HearingLevelList(ParamHIbatch.AudiogramNum,:);
else   % ParamHIbatch.AudiogramNumが、NaNなら、直接設定する。　11 Dec 2018
   % ParamHIbatch.HearingLevelValの値が入っていることが前提
    if length(ParamHIbatch.HearingLevelVal) == length(ParamHIbatch.FaudgramList), %同じ長さチェック
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

%% levelについて検討。

%ParamHIbatch
%ParamHIbatch.DegreeCompression_Faudgram
%ParamHIbatch.HLdB_LossCompression
%ParamHIbatch.HLdB_LossLinear


%pause
%



%%  %%%%%%%%%%%%%%%%%%%%%%%
% いざ実行！
% 以下の内容：　function Exec_HIsimFastGC(hObject, eventdata, handles)
%  line 966
%  ここは、HIsimFastGCのパラメータに入れるだけなので、そのまま
%%%%%%%%%%%%%%%%%%%%%%%%%%

HISparam.fs                                 = ParamHIbatch.fs;
HISparam.SrcSndSPLdB             = ParamHIbatch.SrcSndSPLdB;  % normalizeに使っている
HISparam.FaudgramList             = ParamHIbatch.FaudgramList;
HISparam.DegreeCompression  = ParamHIbatch.DegreeCompression_Faudgram;
HISparam.HLdB_LossLinear       = ParamHIbatch.HLdB_LossLinear;
HISparam.HearingLevelVal         = ParamHIbatch.HearingLevelVal;             % 13 Dec 18 HIsimFastGCで使用　Gain補正のため
%  HISparam.HLdB_LossCompression = ParamHIbatch.HLdB_LossCompression; % 13 Dec18 これは設定不要。 HIsimFastGCで使わない。
HISparam.SwAmpCmpnst           = ParamHIbatch.SwAmpCmpnst;
HISparam.AllowDownSampling = 1;
[HIsimSnd, ~] = HIsimFastGC(ParamHIbatch.SrcSnd, HISparam); % calbration tone でnormalizeされたSrcSndを使う

HIsimSnd = HIsimSnd(:)'; %行ベクトル

return;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 以下の部分：
% function HIsimFastGC_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% 外部関数として定義

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
%  DrawAudiogramの一部。　line 1135あたり.
%%%%%%%%%%%%%%%%%%
%ParamHIbatch.HLdB_LossLinearを求めてる
%if isfield(ParamHIbatch, 'getComp') == 0
%    ParamHIbatch.getComp = 0;  % デフォルト 圧縮特性 0%
%    ParamHIbatch.DegreeCompressionPreSet = 0;
%else
%    if     ParamHIbatch.getComp == 100, ParamHIbatch.DegreeCompressionPreSet = 1;
%    elseif ParamHIbatch.getComp == 67,  ParamHIbatch.DegreeCompressionPreSet = 2/3;
%    elseif ParamHIbatch.getComp == 50,  ParamHIbatch.DegreeCompressionPreSet = 0.5;
%    elseif ParamHIbatch.getComp == 33,  ParamHIbatch.DegreeCompressionPreSet = 1/3;
%    elseif ParamHIbatch.getComp == 0,   ParamHIbatch.DegreeCompressionPreSet = 0;
%    end;
%end
