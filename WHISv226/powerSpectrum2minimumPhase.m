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
cepstrum = ifft(log(doubleSpectrum)/2);% ���f�P�v�X�g�����̒�`(ln����fft���Ċ���2)(����2��fft�̑O�ł����ʂ͓���������)2011/7/2 Nishi
mpResponse = real(ifft(exp(fft([cepstrum(1);2*cepstrum(2:fftl/2);0*cepstrum(fftl/2+1:end)]))));
return;

%�a���ȉ�������
%������
%
%conj�͕��f�������o��.�Ȃ��H�Q�l���ɂ� ��L��real��conj�ɂ�����L�q���Ȃ�