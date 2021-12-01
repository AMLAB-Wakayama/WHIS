%
%       Minimum Phase Filter from Power Sepctrum
%       Irino, T.
%       Created:  25 Oct 21 (from OurMidCrctFilt.m, powerSpectrum2minimumPhase.m by HK)
%       Modified: 26 Oct 21 
%
%       [FilterMinPhs] = PwrSpec2MinPhaseFilter(freq,powerSpectrum,fs)
%       INPUT: freq: FFT frequency  ( uniform in 0<= freq <= fs/2 :  FFTlength/2+1) 
%                   powerSpectrum: power spectrum on freq
%                   fs: sampling frequency  --- for checking freq
%       OUTPUT: FilterMinPhs : minimum phase filter
%
%       See example test program 
%
function [FilterMinPhs] = PwrSpec2MinPhaseFilter(freq,powerSpectrum,fs)

if length(freq) ~= length(powerSpectrum)
     error('Lengths of freq and powerSpectrum are different.')
end   
% check the frequency range
if freq(1) ~= 0 || freq(end) ~= fs/2
    error('freq(1) ~= 0 || freq(end) ~= fs/2.  0<= freq <= fs/2 ')
end   
if abs(mean(diff(freq)) - mean(diff(freq(1:10)))) > 10*eps
    error('Frequency spacing is not uniform.  Uniformly sampled in 0<= freq <= fs/2 ')
end
 
% The same algorithm as in powerSpectrum2minimumPhase.m by HK
doubleSpectrum = [powerSpectrum;powerSpectrum(end-1:-1:2)];
fftl = length(doubleSpectrum);
cepstrum = ifft(log(doubleSpectrum)/2);
FilterMinPhs = real(ifft(exp(fft([cepstrum(1);2*cepstrum(2:fftl/2);0*cepstrum(fftl/2+1:end)]))));

end

%% %%%%%%
% Trash
%%%%%%%%%
%
% Using firpm is too slow. --- Do not use it. 26 Oct 21
%
% LenCoef = 100;
% NCoef = fix(LenCoef/16000*fs/2)*2;            % fs dependent length, even number only
% FIRCoef = firpm(NCoef,freq/(fs/2),sqrt(PwrSpec));  % the same coefficient
% 
% Win     = TaperWindow(length(FIRCoef),'han',LenCoef/10); % Necessary to avoid sprious
% FIRCoef = Win.*FIRCoef;
% plot(FIRCoef)
% 
% % minimum phase reconstruction -- important to avoid pre-echo
% [dummy, x_mp] = rceps(FIRCoef);
% FilterCoeff = x_mp(1:fix(length(x_mp)/2));  % half length is suffient
% % toc


%
%   mpResponse = powerSpectrum2minimumPhase(powerSpectrum,fs)
%   mpResponse  : minimum phase impulse response
%   powerSpectrum   : power spectrum slice (Half FFT length + 1)
%   fs  : sampling frequency (Hz)
%   by Hideki Kawahara
%   14/June/2011
%
% doubleSpectrum = [powerSpectrum;powerSpectrum(end-1:-1:2)];
% fftl = length(doubleSpectrum);
% cepstrum = ifft(log(doubleSpectrum)/2);% 複素ケプストラムの定義(lnしてfftして割る2)(割る2はfftの前でも結果は同じだった)2011/7/2 Nishi
% mpResponse = real(ifft(exp(fft([cepstrum(1);2*cepstrum(2:fftl/2);0*cepstrum(fftl/2+1:end)]))));

