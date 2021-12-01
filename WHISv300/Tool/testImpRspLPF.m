%
%   test TimeDelay of LPF
%   Irino T.,
%   Created: 23 Feb 2021
%   Modified: 23 Feb 2021
%
fs = 2000;
nLocImp = 100;
Imp = [zeros(1,nLocImp), 1, zeros(1,fs*2-nLocImp)];
LenSnd = length(Imp);
FcList = [1 2, 4 8 16 32 64 128 256];
NumOrder = 1;

for nFc = 1:length(FcList)
    Fc = FcList(nFc);
    
    [bzLP, apLP] = butter(NumOrder ,Fc/(fs/2));  % modulation cutoff
    ImpRsp = filter(bzLP, apLP,Imp);

    [dummy nPeak] = max(ImpRsp);
   PeakSmpl(nFc) = nPeak - nLocImp;
   PeakSmplPrd(nFc)  = round(fs/Fc*0.176);

    AmpRatio(nFc) = rms(ImpRsp)/rms(Imp);
    AmpRatioPrd(nFc) = sqrt(Fc/(fs/2));
   
    plot(1:LenSnd,Imp,1:LenSnd,ImpRsp*100,'--');
    hold on;
    ax = axis;
    axis([0 1000, ax(3:4)])
    
end;

[AmpRatio; AmpRatioPrd]
[FcList; PeakSmpl;   PeakSmplPrd]
rms(PeakSmpl- PeakSmplPrd)