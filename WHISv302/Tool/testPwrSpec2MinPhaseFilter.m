%
%       test Minimum Phase Filter from Power Sepctrum
%       Irino, T.
%       Created: 25 Oct 21 (from OurMidCrctFilt.m, powerSpectrum2minimumPhase.m)
%       Modified: 25 Oct 21
%       Modified: 26 Oct 21 % PwrSpec2MinPhaseFilter
%
%
%
addpath('/Users/irino/Google ドライブ/GitHub/GCFB/GCFBv231/Tool')
StrCrct = 'ELC';
fs = 48000;
Nrslt = 2048;

% [crctPwr, freq] = OutMidCrct(StrCrct,Nrslt,fs,0);
[FIRCoef, Param]= MkFilterField2Cochlea(StrCrct,fs,1);
[frsp0, freq0] =freqz(FIRCoef,1,Nrslt,fs);
 frsp0 = [frsp0; frsp0(end)];
 freq0 = [freq0; fs/2];
FrspdB0 =20*log10(abs(frsp0));

crctPwr = abs(frsp0).^2;
tic
[FilterMinPhs] = PwrSpec2MinPhaseFilter(freq0,crctPwr,fs);
toc
[frsp1, freq1] =freqz(FilterMinPhs,1,Nrslt,fs);
FrspdB1 =20*log10(abs(frsp1));

rms(FrspdB0(1:end-1)-FrspdB1) 

tic
mpResponse = powerSpectrum2minimumPhase(crctPwr,fs);
toc
[frsp2, freq2 ] = freqz(mpResponse,1,Nrslt);

subplot(2,1,1)
tms = (0:length(FilterCoeff)-1)/fs*1000;
tms2 = (0:length(mpResponse)-1)/fs*1000;

plot(tms,FilterCoeff, tms2, mpResponse+1);
hold on

subplot(2,1,2)

FrspdB2 =20*log10(abs(frsp2));
plot(freq1,FrspdB1, freq2,FrspdB2,'--', freq0,10*log10(crctPwr),'-.', freq0,FrspdB0,'--');

[ rms(FrspdB0(1:end-1)-FrspdB1)  rms(FrspdB1-FrspdB2)  rms(FrspdB0(1:end-1)-FrspdB2)]


%% %%%%%%%%
% Trash
%%%%%%%
%
%conjは復%%
%   mpResponse = powerSpectrum2minimumPhase(powerSpectrum,fs)
%   mpResponse  : minimum phase impulse response
%   powerSpectrum   : power spectrum slice (Half FFT length + 1)
%   fs  : sampling frequency (Hz)

%   by Hideki Kawahara
%   14/June/2011

% doubleSpectrum = [powerSpectrum;powerSpectrum(end-1:-1:2)];
% fftl = length(doubleSpectrum);
% cepstrum = ifft(log(doubleSpectrum)/2);% 複素ケプストラムの定義(lnしてfftして割る2)(割る2はfftの前でも結果は同じだった)2011/7/2 Nishi
% mpResponse = real(ifft(exp(fft([cepstrum(1);2*cepstrum(2:fftl/2);0*cepstrum(fftl/2+1:end)]))));

