%
%   test OneThirdOctAnaSyn
%   Irino, T.
%   Created:  16 Feb 2021
%   Modified:  16 Feb 2021
%   Modified:  19 Feb 2021
%   Modified:  20 Feb 2021
%   Modified:  22 Feb 2021
%
clear

fs = 48000;
Tsnd = 0.5; %
LenSnd = Tsnd*fs;
DirSnd = [getenv('HOME') '/tmp/'];

SwSnd =3;
ParamOct3.SwModify = 0; % OneThirdOctFB�ł̕ό`�Ȃ��B���͍���
% ParamOct3.SwModify = 1; % OneThirdOctFB�ł̕ό`�̑I��
%ParamOct3.SwModify = 3;
ParamOct3.TMTFlpfFc = 16; % if ParamOct3.SwModify == 3
%ParamOct3.TMTFlpfFc = 8;
%ParamOct3.SwCombReduction = 1; %�@1/3oct filter���P�����ɋ��`�ɔ���
%ParamOct3.FreqRange = [100 3600]; %  �d�b�� 300-3400

if SwSnd  == 1
    Snd = [ zeros(1,100), 1, zeros(1,LenSnd-101)];
    NameSnd = 'Snd_impulse';
elseif SwSnd == 2,
    Snd = 0.1*sin(2*pi*1000*(0:LenSnd-1)/fs);
    NameSnd = 'Snd_1kHzSin';
elseif SwSnd == 3,
    % NameSnd = 'Snd_Konnichiwa'; % 16 kHz
    NameSnd0 = 'mis_40101_babble+6dB';
    [Snd, fs] = audioread([DirSnd NameSnd0 '.wav']);
    NameSnd = ['Snd_' NameSnd0];
    Snd = Snd(:)'; % �s�x�N�g��
end;

LenSnd = length(Snd);
ParamOct3.fs = fs;

ap = audioplayer(Snd,fs);
playblocking(ap);
RmsSnd = sqrt(mean(Snd.^2));

%% %%%
tic;
ParamOct3.SwShiftOct6 = 0;
[SndSyn, FBoct3Mod, ParamOct3] = OneThirdOctAnaSyn(Snd,ParamOct3);
[LenOct3,LenSnd] = size(FBoct3Mod);
toc

% 1/6 oct shift��FB��t��������
%ParamOct3.SwShiftOct6 = 1;
% SynSnd6 = OneThirdOctFB(Snd,ParamOct3);
% SndSyn = (SynSyn+SynSnd6)/2;
% ���������Ă��ό`���͂������Ĉ��Ȃ�-- ���b�v���͌����āA1dB�����ɂȂ�B

%RmsSnd
%RmsSndSyn = sqrt(mean(SndSyn.^2))
%AmpSyn = RmsSnd/RmsSndSyn
% ParamOct3.GainSyn

ap2 = audioplayer(SndSyn,fs);
playblocking(ap2);
% OK �قڗ򉻂Ȃ�
RmsErrdB = 20*log10(sqrt(mean((Snd-SndSyn).^2))/sqrt(mean(Snd.^2)))

SndDiff = Snd-SndSyn;
ap3 = audioplayer(SndDiff,fs);
playblocking(ap3);

audiowrite([DirSnd NameSnd '_Orig.wav' ], Snd,fs);
NameSndSyn = [NameSnd '_Oct3Syn.wav'];
audiowrite([DirSnd NameSndSyn ], SndSyn,fs);

%% %%%%%%%%%%%%
figure(1); clf;
subplot(2,1,1)
imagesc(FBoct3Mod);
set(gca,'YDir','normal');
axis([0 4000 0 LenOct3]);

subplot(2,1,2)
nn = 1:LenSnd;
plot(nn,Snd,nn,SndSyn/max(abs(SndSyn)))
axis([0 400,-1, 1.2])

%% %%%%%%%%%%%%
figure(2);clf
[frsp1 freq] = freqz(Snd,1,LenSnd,fs);
[frsp2 freq] = freqz(SndSyn,1,LenSnd,fs);
%plot(freq,20*log10(abs(frsp1)),freq,20*log10(abs(frsp2)))
semilogx(freq,20*log10(abs(frsp1)),freq,20*log10(abs(frsp2)))
grid on;
ax = axis;
%axis([0 fs/2 (ax(4)+[-100 5])]);
axis([10 fs/2 -20 80] );
if SwSnd == 1, axis([10 fs/2 -10 20] ); end;

figure(3);clf
subplot(3,1,1);
spectrogram(Snd,128,100,128,fs,'yaxis', 'MinThreshold',-100);
subplot(3,1,2);
spectrogram(SndSyn,128,100,128,fs,'yaxis', 'MinThreshold',-100);
subplot(3,1,3);
spectrogram(SndDiff,128,100,128,fs,'yaxis', 'MinThreshold',-100);


