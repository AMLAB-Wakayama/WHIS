%
%   Lowpass envelope using  OneThird Oct Filterbank
%   Irino T.,
%   Created:   2 Sep 2021  % from OneThirdOctAnaSyn
%   Modified:   2 Sep 2021 % 
%   Modified:  26 Sep 2021 % downsampling of envelope
%
%
function [SndSyn, FBoct3Mod, ParamOct3] = OneThirdOctAnaSyn_LPenv(Snd,ParamOct3)

disp(['### ' mfilename ' ###'])

if isfield(ParamOct3,'fs') == 0
    ParamOct3.fs = 48000;  % better than 44100
end

ParamOct3.fsEnv = 2000; % fs envelop should be as low as possible for definition of LPF

if isfield(ParamOct3,'FreqRange') == 0
    ParamOct3.FreqRange = [100 13000]; % 100-12500Hz
end
if isfield(ParamOct3,'StrNorm') ==0
    ParamOct3.StrNorm = 'Normlize2InputSnd';
end
if isfield(ParamOct3,'LPFfc') == 0
    ParamOct3.LPFfc = 16;
end
if isfield(ParamOct3,'LPForder') == 0
    ParamOct3.LPForder = 2;
end


[bzLP, apLP] = butter(ParamOct3.LPForder,ParamOct3.LPFfc/(ParamOct3.fsEnv/2));  % modulation cutoff
StrModify = ['Lowpass filter, fcMod = ' int2str(ParamOct3.LPFfc) ' (Hz)'];
disp([ ' ---  Modification: ' StrModify ' ---']);

%% %%%%%
% Analysis
%%%%%%%
[FBoct3, FBoct3DlyCmp, PwrdB, ParamOct3] = OneThirdOctFB(Snd,ParamOct3);

%% %%%%%%%%%%%%%%%
% Modification/Synthesis processing
%%%%%%%%%%%%%%%%%
[LenOct3, LenSnd] = size(FBoct3DlyCmp);
FBoct3Mod = zeros(LenOct3,LenSnd);

for nf = 1:LenOct3
    %% Ana
    Fout = FBoct3DlyCmp(nf,:); % compensated�̕��Ōv�Z
    FoutAmp = abs(hilbert(Fout));
    FoutPhs   = angle(hilbert(Fout));
    
    %% Mod Lowpass filtering
    ModEnv = resample(FoutAmp,ParamOct3.fsEnv,ParamOct3.fs); 
    ModEnvLP = filter(bzLP,apLP,ModEnv);
    FoutAmpMod1 = resample(ModEnvLP,ParamOct3.fs,ParamOct3.fsEnv);
    LenMod = length(FoutAmpMod1);
    FoutAmpMod = [FoutAmpMod1(1:min(LenSnd,LenMod)), zeros(1,LenSnd-LenMod)];
    
    %% Synth %%%%
    FoutSyn = real(FoutAmpMod.*exp(j*FoutPhs));  %�@resample������Amp�������Ȃ犮�S�ɂ��ǂ邱�Ƃ��m�F
    FBoct3Mod(nf,:)= FoutSyn;
    
    % ErrdB(nf) =  10*log10(mean((Fout-FoutSyn).^2)/mean(Fout.^2));
end
SndSyn0 = mean(FBoct3Mod);

ParamOct3.AmpNorm = ParamOct3.GainAnaSyn; % simple ana/syn�̃��x��
if strcmp(ParamOct3.StrNorm,'Normlize2InputSnd') == 1
    ParamOct3.AmpNorm =  rms(Snd)/rms(SndSyn0);
end

SndSyn = ParamOct3.AmpNorm*SndSyn0;

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


% ParamOct3.NumRange = find(ParamOct3.FcLabel >=  min(ParamOct3.FreqRange) & ...
%     ParamOct3.FcLabel <=  max(ParamOct3.FreqRange) );
% if isfield(ParamOct3,'SwCombReduction') == 1
%     %�킴�ƂP��΂��ɂ��Ă݂� --   ���`�ɍ팸
%     ParamOct3.NumRange = min(ParamOct3.NumRange):2:max(ParamOct3.NumRange);
% end
% ParamOct3.FcLabel = ParamOct3.FcLabel(ParamOct3.NumRange);
% ParamOct3.FcList    = ParamOct3.FcList(ParamOct3.NumRange);
% 
% FBoct3 = FBoct3(ParamOct3.NumRange,:);
% FBoct3DlyCmp = FBoct3DlyCmp(ParamOct3.NumRange,:);


% 48kHz�ɑ΂��āA16Hz�̃t�B���^�͍��Ȃ��B
% resampling���āA16 Hz���B
%�@modulation �̃T���v�����O���g���̒�` --- GCFB�Ɠ����ɂ��Ă������B
% ParamOct3.fsMod = 100;
% [bzLP, apLP] = butter(2,ParamOct3.LPFfc/(ParamOct3.fsMod/2));  % modulation cutoff
% ParamOct3.LPFfc
%         if 0 resample ����K�v�Ȃ�
%             EnvAmp = resample(FoutAmp,ParamOct3.fsMod,ParamOct3.fs); % downsampling
%             EnvAmpMod = filter(bzLP,apLP,EnvAmp); % LPF
%             FoutAmpMod1 = resample(EnvAmpMod,ParamOct3.fs,ParamOct3.fsMod); % upsampling
%             Len0 = length(FoutAmp);  Len1 = length(FoutAmpMod1);
%             [Len0 Len1]
%             FoutAmpMod = [FoutAmpMod1(1:min(Len0,Len1))  zeros(1,Len0-Len1)];
%         end
% 20*log10(rms(FoutAmpMod-FoutAmp)/rms(FoutAmp))



%         % ���܂�Ӗ��̂���ό`�͂Ȃ��̂ŁA�Ƃ肠�����g��Ȃ��B
%         if 0      % �l�X�ȕό`�������Ă݂�B
%             if ParamOct3.SwModify == 2
%                 StrModify = 'Add constant';
%                 FoutAmpMod = FoutAmp*0.1 + mean(FoutAmp)*ones(1,LenSnd); %  flat respose
%             elseif ParamOct3.SwModify == 3
%                 StrModify = 'Add randn';
%                 FoutAmpMod = FoutAmp*0.1 + 0.005*randn(1,LenSnd);
%                 %  �܂�white noise�I�Ȃ̂�reallity�Ƃ��Ă͋߂������B�����̎����𑹂Ȃ�Ȃ��B�P��SNR�������Ȃ��������B
%                 
%             elseif ParamOct3.SwModify == 4
%                 StrModify = 'Lowpass+SS';
%                 CoefSS = 0.8;
%                 CoefSS = 1;
%                 CoefReduct = 1; % --- ����Ӗ��Ȃ��C������B CoeffSS�ƕ�������Ɛ���͓���B
%                 FoutAmp = filter(bzLP,apLP,FoutAmp);
%                 RmsFoutAmp = sqrt(mean(FoutAmp.^2));
%                 FoutAmp= max(CoefReduct * FoutAmp- CoefReduct*CoefSS*RmsFoutAmp,0); % Spec subtraction
%                 RmsFoutAmp2 = sqrt(mean(FoutAmp.^2));
%                 ReductiondB2(nf) = 20*log10(RmsFoutAmp2/RmsFoutAmp);
%                 % SS������邱�Ƃɂ��A�]�v�Ȏc�����I�Ȃ��̂͏�����̂ŗǂ������B
%                 % ReductiondB �́A-3����-8dB���x�Ȃ̂ŁA������g����C������B
%                 % sin�g�������ƁA���̐������኱�ł邪�Amain��c�܂���قǂł͂Ȃ��B
%                 FoutAmpMod = FoutAmp* RmsFoutAmp0/RmsFoutAmp2; % �\���͌��Ɠ���rms�l�ŏo��--> audiogram�ɉe�����o�Ȃ��悤
%                 RmsFoutAmp3 = sqrt(mean(FoutAmpMod.^2));
%                 ReductiondB3(nf) = 20*log10(RmsFoutAmp3/RmsFoutAmp);
%                 
%                 %���ǁA���Ƃɔ{���ł��ǂ��̂ŁAmodulation depth���߂�--- enhance�ɂ���Ȃ�B
%                 % modulation depth ---������x���邱��
%                 %  --->   depth reduction�ɂ��ẮA������߂邵���Ȃ����B
%                 
%             elseif ParamOct3.SwModify == 5
%                 StrModify = 'SS';
%                 MeanFoutAmp = mean(FoutAmp);
%                 FoutAmp = FoutAmp*0.1 + MeanFoutAmp*ones(1,LenSnd); % modulation depth������
%                 FoutAmpMod= max(FoutAmp- MeanFoutAmp*1.1,0); % Spec subtraction
%                 % ���܂艹�̕ω��Ȃ��Bmodulation depth�����̂悤�ɂ��ĕς���͓̂��
%             end
%         end
        