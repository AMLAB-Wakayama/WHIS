%
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

SwSnd =2;

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
    Snd = Snd(:)'; % 行ベクトル
end;

LenSnd = length(Snd);
ParamOct3.fs = fs;

ap = audioplayer(Snd,fs);
playblocking(ap);
RmsSnd = sqrt(mean(Snd.^2));

%% %%%
tic;
OneThirdOctFB(Snd,ParamOct3);

[FBoct3, FBoct3DlyCmp, PwrdB, ParamOct3] = OneThirdOctFB(Snd,ParamOct3);
[LenOct3, dummy] = size(FBoct3DlyCmp);
toc
SndSyn = ParamOct3.GainSyn*mean(FBoct3DlyCmp);

SndDiff = Snd-SndSyn;

%% %%%%%%%%%%%%
figure(1); clf;
subplot(2,1,1)
imagesc(FBoct3DlyCmp);
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


