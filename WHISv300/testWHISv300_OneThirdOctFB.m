%
%  testWHISv300_OneThirdOctFB
%  Irino, T.
%  Created:  2 Sep 21 (from testOneThirdOct)
%  Modified: 2  Sep 21
%  Modified: 26  Sep 21
%
%
clear
clf

DirHome = getenv('HOME');
DirFig = [ pwd  '/Fig/'];

%DirSnd = [ pwd  '/Sound/'];
DirSnd = [ getenv('HOME')  '/Data/WHIS/Sound/'];
NameSnd = 'Snd_Hello123';  % 48 kHz
addpath([pwd '/Tool/OneThirdOctFB'])

InfoSnd = audioinfo([DirSnd NameSnd '.wav']);
% 16 bit data
[Snd, fs] = audioread([DirSnd NameSnd '.wav']);
Snd = Snd(:)';

ParamOct3.fs = fs;

ap = audioplayer(Snd,fs);
playblocking(ap);
RmsSnd = sqrt(mean(Snd.^2));

%% 
tic;
ParamOct3.TMTFlpfFc = 8; % 16; % 256=16*16;
%  ParamOct3.TMTFlpfFc = fs/4; % こうしてもRmsErrdB=-16.3201  --- これ以下にはならないということ

[SndSyn, FBoct3Mod, ParamOct3] = OneThirdOctAnaSyn_LPenv(Snd,ParamOct3);
ParamOct3
[LenOct3,LenSnd] = size(FBoct3Mod);

ap2 = audioplayer(SndSyn,fs);
playblocking(ap2);

RmsErrdB = 20*log10(sqrt(mean((Snd-SndSyn).^2))/sqrt(mean(Snd.^2)))

SndDiff = Snd-SndSyn; %差分波形
%ap3 = audioplayer(SndDiff,fs);
%playblocking(ap3);

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

figure(3);clf
subplot(3,1,1);
spectrogram(Snd,128,100,128,fs,'yaxis', 'MinThreshold',-100);
subplot(3,1,2);
spectrogram(SndSyn,128,100,128,fs,'yaxis', 'MinThreshold',-100);
subplot(3,1,3);
spectrogram(SndDiff,128,100,128,fs,'yaxis', 'MinThreshold',-100);


%% %%%%%%
% 
%%%%%%%

% 1/6 oct shiftのFBを付け加える
%ParamOct3.SwShiftOct6 = 1;
% SynSnd6 = OneThirdOctFB(Snd,ParamOct3);
% SndSyn = (SynSyn+SynSnd6)/2;
% これをやっても変形音はたいして違わない-- リップルは減って、1dB未満になる。

%RmsSnd
%RmsSndSyn = sqrt(mean(SndSyn.^2))
%AmpSyn = RmsSnd/RmsSndSyn
% ParamOct3.GainSyn

