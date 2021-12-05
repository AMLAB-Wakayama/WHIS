% 
%  testHIsimBatch
%  Irino, T.
%  Created: 8 Jul 18 (from Try_MkHisimfile)
%  Modified: 8 Jul 18 
%  Modified: 11 Jul 18 
%
%
clear

DirSnd = [ getenv('HOME')  '/tmp/'];
NameSrcSnd = ['Snd_akasatana'];
NameSnd = [DirSnd NameSrcSnd ];
NameSrcSnd = [NameSnd '_Src'];
NameHIsimSnd = [NameSnd '_HIsim'];

ParamHI.AudiogramNum = 3;          
ParamHI.SPLdB_CalibTone = 80;    
ParamHI.SrcSndSPLdB = 65;

ParamHI.getComp = 0; % 0 %
ParamHI.getComp = 50; % 50 %
% ParamHI.getComp = 100; % 100 %

    
    Info = audioinfo([NameSnd '.wav']);
    % 16 bit data
    [SndIn, fs] = audioread([NameSnd '.wav']);
    SndIn = SndIn(:)';
    plot(SndIn);
    
    [HIsimSnd,SrcSnd] = HIsimBatch(SndIn, ParamHI) ;
    
    NameSrcSnd1 = [NameSrcSnd '_Cmprs' int2str(ParamHI.getComp) '.wav']
    NameHIsimSnd1 = [NameHIsimSnd '_Cmprs' int2str(ParamHI.getComp) '.wav']
    audiowrite(NameSrcSnd1,SrcSnd,fs,'BitsPerSample',24);
    audiowrite(NameHIsimSnd1,HIsimSnd,fs,'BitsPerSample',24);
    

%% %%%%%%%%%
% MkHISimFileの場合 % 結果が一致することを確認。
%%%%%%%%%

pwd1 = pwd;
addpath([pwd1 ]);
addpath([pwd1 '/Previous/Batch_HIsim']);
ParamHI.getComp;
ParamHI.CompPctVal = ParamHI.getComp;  
%  この変数が謎。 ParamMkHI.CompPctVal はMkHIsimFile_21Jun18で使われていない。
%size(SndIn)

[HIsimsnd_normalize_snd] = MkHIsimFile_21Jun18_modIT11Jul18(SndIn, ParamHI);

subplot(2,1,1)
plot(1: length(HIsimSnd), HIsimSnd, 1:length(HIsimsnd_normalize_snd), HIsimsnd_normalize_snd+0.02)
subplot(2,1,2)
plot(1: length(HIsimSnd), HIsimSnd-HIsimsnd_normalize_snd(:)')

rms(HIsimSnd-HIsimsnd_normalize_snd(:)')
