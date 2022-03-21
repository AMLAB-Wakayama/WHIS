%
%   Analysis/Synthesis OneThird Oct Filterbank
%   Irino T.,
%   Created: 16 Feb 2021 % from oct3fit.m
%   Modified: 16 Feb 2021
%   Modified:  19 Feb 2021
%   Modified:  22 Feb 2021 % renamed from OneThirdOctFB
%
%
function [SndSyn, FBoct3Mod, ParamOct3] = OneThirdOctAnaSyn(Snd,ParamOct3)

disp(['### ' mfilename ' ###'])

if isfield(ParamOct3,'fs') == 0
    ParamOct3.fs = 48000;  % better than 44100
end;
if isfield(ParamOct3,'FreqRange') == 0,
    ParamOct3.FreqRange = [100 13000]; % 100-12500Hz
end;
% Analysis
[FBoct3, FBoct3DlyCmp, PwrdB, ParamOct3] = OneThirdOctFB(Snd,ParamOct3);

if isfield(ParamOct3,'SwModify') == 0,
    ParamOct3.SwModify = 0; % no modification
end;
if isfield(ParamOct3,'TMTFlpfFc') == 0,
    ParamOct3.TMTFlpfFc = 16;
end;
[bzLP, apLP] = butter(2,ParamOct3.TMTFlpfFc/(ParamOct3.fs/2));  % modulation cutoff

ParamOct3.NumRange = find(ParamOct3.FcLabel >=  min(ParamOct3.FreqRange) & ...
    ParamOct3.FcLabel <=  max(ParamOct3.FreqRange) );
if isfield(ParamOct3,'SwCombReduction') == 1
    %わざと１つ飛ばしにしてみる --   櫛形に削減
    ParamOct3.NumRange = min(ParamOct3.NumRange):2:max(ParamOct3.NumRange);
end;
ParamOct3.FcLabel = ParamOct3.FcLabel(ParamOct3.NumRange);
ParamOct3.FcList = ParamOct3.FcList(ParamOct3.NumRange);

FBoct3 = FBoct3(ParamOct3.NumRange,:);
FBoct3DlyCmp = FBoct3DlyCmp(ParamOct3.NumRange,:);

%% %%%%%%%%%%%%%%%
% Modification/Synthesis processing
%%%%%%%%%%%%%%%%%
[LenOct3, LenSnd] = size(FBoct3DlyCmp);
FBoct3Mod = zeros(LenOct3,LenSnd);

for nf = 1:LenOct3
    %% Ana
    Fout = FBoct3DlyCmp(nf,:); % compensatedの方で計算
    FoutAmp = abs(hilbert(Fout));
    FoutPhs = angle(hilbert(Fout));
    RmsFoutAmp0 = sqrt(mean(FoutAmp.^2));
    
    %% Mod
    % 様々な変形を試してみる。
    if ParamOct3.SwModify == 1,
        StrModify = 'Add constant';
        FoutAmp = FoutAmp*0.1 + mean(FoutAmp)*ones(1,LenSnd); %  flat respose
    elseif ParamOct3.SwModify == 2
        StrModify = 'Add randn';
        FoutAmp = FoutAmp*0.1 + 0.005*randn(1,LenSnd);
        %  まだwhite noise的なのでreallityとしては近い感じ。音声の質感を損なわない。単にSNRが悪くなった感じ。
    elseif ParamOct3.SwModify == 3
        StrModify = 'Lowpass';
        FoutAmp = filter(bzLP,apLP,FoutAmp);
    elseif ParamOct3.SwModify == 4
        StrModify = 'Lowpass+SS';
        CoefSS = 0.8;
        CoefSS = 1;
        CoefReduct = 1; % --- これ意味ない気がする。 CoeffSSと分離すると制御は難しい。
        FoutAmp = filter(bzLP,apLP,FoutAmp);
        RmsFoutAmp = sqrt(mean(FoutAmp.^2));
        FoutAmp= max(CoefReduct * FoutAmp- CoefReduct*CoefSS*RmsFoutAmp,0); % Spec subtraction
        RmsFoutAmp2 = sqrt(mean(FoutAmp.^2));
        ReductiondB2(nf) = 20*log10(RmsFoutAmp2/RmsFoutAmp);
        % SSをいれることにより、余計な残響音的なものは消えるので良いかも。
        % ReductiondB は、-3から-8dB程度なので、これも使える気がする。
        % sin波をいれると、他の成分が若干でるが、mainを歪ませるほどではない。
        FoutAmp = FoutAmp* RmsFoutAmp0/RmsFoutAmp2; % 表現は元と同じrms値で出力--> audiogramに影響が出ないよう
        RmsFoutAmp3 = sqrt(mean(FoutAmp.^2));
        ReductiondB3(nf) = 20*log10(RmsFoutAmp3/RmsFoutAmp);
        
        %結局、もとに倍数でもどすので、modulation depthが戻る--- enhanceにすらなる。
        % modulation depth ---もう一度見ること
        %  --->   depth reductionについては、あきらめるしかないか。
        
    elseif ParamOct3.SwModify == 5
        StrModify = 'SS';
        MeanFoutAmp = mean(FoutAmp);
        FoutAmp = FoutAmp*0.1 + MeanFoutAmp*ones(1,LenSnd); % modulation depthを減少
        FoutAmp= max(FoutAmp- MeanFoutAmp*1.1,0); % Spec subtraction
        % あまり音の変化なし。modulation depthをこのようにして変えるのは難しい
    else
        StrModify = 'No Modification';
    end;
    
    %% Synth %%%%
    FoutSyn = real(FoutAmp.*exp(j*FoutPhs));  %　Ampが同じなら完全にもどることを確認
    FBoct3Mod(nf,:)= FoutSyn;

    ErrdB(nf) =  10*log10(mean((Fout-FoutSyn).^2)/mean(Fout.^2));
    
end;

disp([ ' ---  Modification: ' StrModify ' ---']);
% Synth
SndSyn = ParamOct3.GainSyn*mean(FBoct3DlyCmp);

return

%% %%%%%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%%%%%

% このバージョンでは、やれない。入れない方が間違いないと思われる。
% ParamOct3.FcShiftRatio = 1; % 通常シフトなし
% if isfield(ParamOct3,'SwShiftOct6') == 1 && ParamOct3.SwShiftOct6 == 1   % Fcを1/6octをずらす場合
%     ParamOct3.FcShiftRatio = 2^(1/6); % 1/6octシフト
%     disp(' ---   1/6 Octave shift of center frequency ---');
% end;
% if ParamOct3.FcShiftRatio ~= 1
%     ParamOct3.FcList = ParamOct3.FcList*ParamOct3.FcShiftRatio; % シフトも含め
%     ParamOct3.FcLabel = round(ParamOct3.FcLabel*ParamOct3.FcShiftRatio);  % これも一応変更
% end;

