%
%   Batch execution function for WHISv300
%   Irino, T.
%   Created:   14 Feb 21
%   Modified:   14 Feb 21
%   Modified:   25 Jul  21  (HISparam --> WHISparam)
%   Modified:   2 Sep  21   using GCFBv231
%   Modified:  10 Sep  21   using GCFBv231
%   Modified:  20 Oct  21   dtvfとFBAnaSynの分岐はWHISv300の中に。
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
%   Note: 利用法  17 Oct 18, 10 Sep 21
%       Calbration tone はdigital levelで、RMS = -26 dB として計算しています。
%       すべての実験で、このCalbration toneを使って再生し、実験にあわせたレベルで校正してください。
%       1) WHISparam_GUIの場合は、80dBで校正します。これは、大きな声が入ってもクリッピングしないように。
%               この場合、WHISparam.CalibTone.SPLdB = 80; (default値)です。
%       2) 聴取実験で、Calbration toneを65dBに合わせた場合、
%               WHISparam.CalibTone.SPLdB = 65; となるように引数を設定してください。
%
%        背景：計算機は数値だけを知っています。この数値が外界で何dBになるかを知りません。
%                  これを教えるのが、Calbration toneによる校正です。
%                  対応づけがちゃんとできていない場合、計算機の内部処理は間違えます。
%
%
function [SndWHIS,SrcSnd,CalibTone,WHISparam] = WHISv300_Batch(SndLoad, WHISparam)

[mm, nn] = size(SndLoad);
if min(mm, nn)  > 1
    error('入力音は、モノラル(行ベクトル）とすること。実験の際、間違えないようにするため。');
    return;
end
SndLoad = SndLoad(:)'; % 行ベクトル

%%  %%%%%%%%%%%
% 初期設定  'batch'を明示。　GUIでも同じInitParamHIを使うが、これは'GUI'で利用。
%%%%%%%%%%%%%%%%%
WHISparam.SwGUIbatch = 'Batch';
WHISparam.AllowDownSampling = 0; % BatchではDownSamplingは行わない。

if isfield(WHISparam,'SynthMethod') == 0
    WHISparam.SynthMethod = 'DTVF';  % default DTVF
end

%% %%%%%%%%%%%%%%%%%
% 音圧レベル合わせ
%%%%%%%%%%%%%%%%%%%%
disp(['CalibTone SPLdB = '  num2str(WHISparam.CalibTone.SPLdB) ' (dB)']);
disp(['SrcSnd  SPLdB    = '  num2str(WHISparam.SrcSnd.SPLdB) ' (dB)']);

[CalibTone, WHISparam]  = WHISv300_MkCalibTone(WHISparam);
RecordedCalibTone =  CalibTone;
% Batchでは、CalibToneを外部から録音できないので、同じとみなす。(GUIでは一致するように録音するが）
% 処理の確認では、ここにsaveされたRecordedCalibToneを読み込む。

[SrcSnd, WHISparam] = WHISv300_GetSrcSndNrmlz2CalibTone(SndLoad,RecordedCalibTone,WHISparam);

% WHISparam.RecordedCalibTone =  CalibTone;
% WHISparam.SndLoad = SndLoad;
% SrcSnd = WHISparam.SrcSnd; % calbration tone でnormalizeされたSrcSnd

%% %%%%%%%%%%%%%%%%
% 難聴のパラメータ設定
% default値はなしにする。--- WHISv300で、設定なしの場合errorが出るようにした。
%%%%%%%%%%%%%%%%%%
[SndWHIS, WHISparam] = WHISv300(SrcSnd, WHISparam); 

return


%% %%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%


% if isfield(HISparam, 'AudiogramNum') == 0    % See GCFBv230_HearingLoss
%　注意  パラメータの名前も含め要検討　　2021/2/14
%  HISparam.AudiogramNum = 3;  % デフォルト ISO7029 70yr 男
% end
%if isfield(HISparam, 'getComp') == 0   %  ----- このパラメータ名、あまりよくない。WHISで仕切り直し予定。
%    HISparam.getComp = 0;  % デフォルト 圧縮特性 0%
%end
% NumComp = find(HISparam.getComp == HISparam.Table_getComp);  %CompはTableから


%%%   14 Feb 2021 現在で未完成のまま。
%  ---  時間方向劣化を検討するため、そちらに行った


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
% % いざ実行！
% % 以下の内容：　function Exec_HIsimFastGC(hObject, eventdata, handles)
% %  line 966
% %  ここは、HIsimFastGCのパラメータに入れるだけなので、そのまま
% %%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HISparam.fs                                 = ParamHIbatch.fs;
% HISparam.SrcSndSPLdB             = ParamHIbatch.SrcSndSPLdB;  % normalizeに使っている
% HISparam.FaudgramList             = ParamHIbatch.FaudgramList;
% HISparam.DegreeCompression  = ParamHIbatch.DegreeCompression_Faudgram;
% HISparam.HLdB_LossLinear       = ParamHIbatch.HLdB_LossLinear;
% HISparam.HearingLevelVal         = ParamHIbatch.HearingLevelVal;             % 13 Dec 18 HIsimFastGCで使用　Gain補正のため
% %  HISparam.HLdB_LossCompression = ParamHIbatch.HLdB_LossCompression; % 13 Dec18 これは設定不要。 HIsimFastGCで使わない。
% HISparam.SwAmpCmpnst           = ParamHIbatch.SwAmpCmpnst;
% HISparam.AllowDownSampling = 1;
% [HIsimSnd, ~] = HIsimFastGC(ParamHIbatch.SrcSnd, HISparam); % calbration tone でnormalizeされたSrcSndを使う
%
% HIsimSnd = HIsimSnd(:)'; %行ベクトル

%% %%%%%%%%%%%%%%%%
% 難聴のパラメータ設定
%%%%%%%%%%%%%%%%%%
% default値はなしにする。--- WHISv300で、設定なしの場合errorが出るようにした。
% if isfield(WHISparam.HLoss,'Type') == 0
%     WHISparam.HLoss.Type = 'HL3'; % デフォルト ISO7029 70yr 男      --  HISparam.AudiogramNum
% end
%
% if isfield(WHISparam.HLoss,'CompressionHealth') == 0
%     WHISparam.HLoss.CompressionHealth = 0.5; % Initial value of compression  --  HISparam.getComp
% end


