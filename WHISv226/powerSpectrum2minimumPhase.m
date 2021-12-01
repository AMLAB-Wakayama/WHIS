function mpResponse = powerSpectrum2minimumPhase(powerSpectrum,fs)
%%
%   mpResponse = powerSpectrum2minimumPhase(powerSpectrum,fs)
%   mpResponse  : minimum phase impulse response
%   powerSpectrum   : power spectrum slice (Half FFT length + 1)
%   fs  : sampling frequency (Hz)

%   by Hideki Kawahara
%   14/June/2011

doubleSpectrum = [powerSpectrum;powerSpectrum(end-1:-1:2)];
fftl = length(doubleSpectrum);
cepstrum = ifft(log(doubleSpectrum)/2);% 複素ケプストラムの定義(lnしてfftして割る2)(割る2はfftの前でも結果は同じだった)2011/7/2 Nishi
mpResponse = real(ifft(exp(fft([cepstrum(1);2*cepstrum(2:fftl/2);0*cepstrum(fftl/2+1:end)]))));
return;

%溝渕以下問題解決
%西メモ
%
%conjは復素共役を出力.なぜ？参考書には 上記のrealとconjにあたる記述がない