%
% testHilbert
%  Irino, T.
%  Created: 6 Mar 2021
%  Modified: 6 Mar 2021
%
fs = 2000;

rng(123);
Snd = randn(1,2000);

Snd_cx = hilbert(Snd);

[bz ap] = butter(2,500/fs);
Snd_LPF = filter(bz, ap, Snd);
ModAmp = abs(hilbert(Snd_LPF));

SndAbs = abs(Snd_cx);
SndPhs = angle(Snd_cx);

SndMod = SndAbs.*ModAmp;
SndSyn = real(SndMod.*exp(j*SndPhs));

SndSyn2 = Snd.*ModAmp;
rms(SndSyn2-SndSyn)

nn = 1:length(Snd);
plot(nn,SndSyn, nn,SndSyn2,nn,ModAmp+3)



 