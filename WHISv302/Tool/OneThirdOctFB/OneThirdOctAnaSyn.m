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
    %�킴�ƂP��΂��ɂ��Ă݂� --   ���`�ɍ팸
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
    Fout = FBoct3DlyCmp(nf,:); % compensated�̕��Ōv�Z
    FoutAmp = abs(hilbert(Fout));
    FoutPhs = angle(hilbert(Fout));
    RmsFoutAmp0 = sqrt(mean(FoutAmp.^2));
    
    %% Mod
    % �l�X�ȕό`�������Ă݂�B
    if ParamOct3.SwModify == 1,
        StrModify = 'Add constant';
        FoutAmp = FoutAmp*0.1 + mean(FoutAmp)*ones(1,LenSnd); %  flat respose
    elseif ParamOct3.SwModify == 2
        StrModify = 'Add randn';
        FoutAmp = FoutAmp*0.1 + 0.005*randn(1,LenSnd);
        %  �܂�white noise�I�Ȃ̂�reallity�Ƃ��Ă͋߂������B�����̎����𑹂Ȃ�Ȃ��B�P��SNR�������Ȃ��������B
    elseif ParamOct3.SwModify == 3
        StrModify = 'Lowpass';
        FoutAmp = filter(bzLP,apLP,FoutAmp);
    elseif ParamOct3.SwModify == 4
        StrModify = 'Lowpass+SS';
        CoefSS = 0.8;
        CoefSS = 1;
        CoefReduct = 1; % --- ����Ӗ��Ȃ��C������B CoeffSS�ƕ�������Ɛ���͓���B
        FoutAmp = filter(bzLP,apLP,FoutAmp);
        RmsFoutAmp = sqrt(mean(FoutAmp.^2));
        FoutAmp= max(CoefReduct * FoutAmp- CoefReduct*CoefSS*RmsFoutAmp,0); % Spec subtraction
        RmsFoutAmp2 = sqrt(mean(FoutAmp.^2));
        ReductiondB2(nf) = 20*log10(RmsFoutAmp2/RmsFoutAmp);
        % SS������邱�Ƃɂ��A�]�v�Ȏc�����I�Ȃ��̂͏�����̂ŗǂ������B
        % ReductiondB �́A-3����-8dB���x�Ȃ̂ŁA������g����C������B
        % sin�g�������ƁA���̐������኱�ł邪�Amain��c�܂���قǂł͂Ȃ��B
        FoutAmp = FoutAmp* RmsFoutAmp0/RmsFoutAmp2; % �\���͌��Ɠ���rms�l�ŏo��--> audiogram�ɉe�����o�Ȃ��悤
        RmsFoutAmp3 = sqrt(mean(FoutAmp.^2));
        ReductiondB3(nf) = 20*log10(RmsFoutAmp3/RmsFoutAmp);
        
        %���ǁA���Ƃɔ{���ł��ǂ��̂ŁAmodulation depth���߂�--- enhance�ɂ���Ȃ�B
        % modulation depth ---������x���邱��
        %  --->   depth reduction�ɂ��ẮA������߂邵���Ȃ����B
        
    elseif ParamOct3.SwModify == 5
        StrModify = 'SS';
        MeanFoutAmp = mean(FoutAmp);
        FoutAmp = FoutAmp*0.1 + MeanFoutAmp*ones(1,LenSnd); % modulation depth������
        FoutAmp= max(FoutAmp- MeanFoutAmp*1.1,0); % Spec subtraction
        % ���܂艹�̕ω��Ȃ��Bmodulation depth�����̂悤�ɂ��ĕς���͓̂��
    else
        StrModify = 'No Modification';
    end;
    
    %% Synth %%%%
    FoutSyn = real(FoutAmp.*exp(j*FoutPhs));  %�@Amp�������Ȃ犮�S�ɂ��ǂ邱�Ƃ��m�F
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

% ���̃o�[�W�����ł́A���Ȃ��B����Ȃ������ԈႢ�Ȃ��Ǝv����B
% ParamOct3.FcShiftRatio = 1; % �ʏ�V�t�g�Ȃ�
% if isfield(ParamOct3,'SwShiftOct6') == 1 && ParamOct3.SwShiftOct6 == 1   % Fc��1/6oct�����炷�ꍇ
%     ParamOct3.FcShiftRatio = 2^(1/6); % 1/6oct�V�t�g
%     disp(' ---   1/6 Octave shift of center frequency ---');
% end;
% if ParamOct3.FcShiftRatio ~= 1
%     ParamOct3.FcList = ParamOct3.FcList*ParamOct3.FcShiftRatio; % �V�t�g���܂�
%     ParamOct3.FcLabel = round(ParamOct3.FcLabel*ParamOct3.FcShiftRatio);  % ������ꉞ�ύX
% end;

