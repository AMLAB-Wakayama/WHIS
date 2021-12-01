%
%  testWHISv300_Batch_CmprSnd
%  Irino, T.
%  Created:  2  Sep 21
%  Modified:  2  Sep 21
%  Modified: 10 Oct 21
%
%
clear
clf

DirSnd = [ getenv('HOME')  '/Data/WHIS/Sound/'];
NameSrcSnd = 'Snd_Hello123';  % 48 kHz

cnt = 0;
for CmprsHlth = [0.5]
    cnt = cnt+1;
    figure(cnt); clf;
    StrCmprs = ['_Cmprs'  int2str(CmprsHlth*100)];
    StrSfx = ['_EmLpf512'];
    %[SndWHISv2, fs] =  audioread([DirSnd NameSrcSnd '_WHISv225_HL3'  StrCmprs  StrSfx '.wav']);
    % [SndWHISv3, fs] =  audioread([DirSnd NameSrcSnd '_WHISv300_HL3'  StrCmprs   StrSfx '.wav']);
    [SndWHISv3fbas, fs] =  audioread([DirSnd NameSrcSnd '_WHISv300fbas_HL3'  StrCmprs   StrSfx '.wav']);
    [SndWHISv3, fs] =  audioread([DirSnd NameSrcSnd '_WHISv300fbas_HL3'  StrCmprs   StrSfx '_NH.wav']);
    SndWHISv2 = SndWHISv3;
    
    nvld = 1:min(length(SndWHISv2),length(SndWHISv3));
    tms = (nvld-1)/fs*1000;
    
    plot(tms,SndWHISv2(nvld),tms,SndWHISv3(nvld)+0.4, tms,SndWHISv3fbas(nvld)+0.4, ...
        tms,SndWHISv2(nvld)-SndWHISv3(nvld)+1.2,  tms,SndWHISv3(nvld)-SndWHISv3fbas(nvld)+0.4)
            
    
    [ CmprsHlth,  20*log10([rms(SndWHISv2),  rms(SndWHISv3),  ...
        rms(SndWHISv2)/rms(SndWHISv3),  rms(SndWHISv2(nvld)-SndWHISv3(nvld))/rms(SndWHISv3(nvld)) ]) ]
end

ap = audioplayer(SndWHISv3(nvld)-SndWHISv3fbas(nvld),fs);
playblocking(ap)

