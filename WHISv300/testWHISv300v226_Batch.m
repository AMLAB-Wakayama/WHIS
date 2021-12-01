%
%  testWHISv300_Batch
%  Irino, T.
%  Created:   9 Feb 21 (from testHISimBatch)
%  Modified:  9 Feb 21
%  Modified: 25 Jul 21
%  Modified: 17 Aug 21
%  Modified:  2 Sep 21
%  Modified: 10 Sep 21
%  Modified:  26 Sep 21
%  Modified:  10 Oct 21
%  Modified:  20 Oct 21
%  Modified:  21 Oct 21 renamed testWHISv300v226_Batch.m
%
%
clear
clf

StartupWHIS
DirProg = fileparts(which(mfilename));
DirData = [getenv('HOME') '/Data/WHIS/'];
DirSnd = [ DirData  '/Sound/'];
if exist(DirSnd) == 0, mkdir(DirSnd); end
NameSrcSnd = 'Snd_Hello123';  % example file fs 48 kHz
if exist([DirSnd NameSrcSnd '.wav']) == 0
    str = [ 'cp -p -f "' DirProg '/' NameSrcSnd '.wav" '  DirSnd ];  % "を使う「Google ドライブ/」対応 
    disp(str);
    unix(str);
end

SwSnd = 1;
if SwSnd == 2,
    % NameSrcSnd = 'Snd_PulseTrain';  % 48 kHz
    if exist([DirProg NameSrcSnd '.wav']) == 0
        Fo = 100;
        fs = 48000;
        Tsnd = 0.2;
        LenSnd = Tsnd*fs;
        Snd = ones(1,LenSnd)*0.00001;
        nPulse = [10:fs/Fo:LenSnd];
        Snd(nPulse) = 0.5;
        audiowrite([DirSnd NameSrcSnd '.wav'],Snd,fs,'BitsPerSample',24);
    end
end;

NameSnd = [DirSnd NameSrcSnd ];

InfoSnd = audioinfo([NameSnd '.wav']);
% 16 bit data
[SndIn, fs] = audioread([NameSnd '.wav']);
SndIn = SndIn(:)';
plot(SndIn);
WHISparam.fs = fs;

%% %%%%%%%%%
% WHIS
%%%%%%%%%%%

WHISparam.HLoss.Type = 'HL3';
WHISparam.HLoss.Type = 'HL2';
% WHISparam.HLoss.Type = 'NH';  % もとどおりのはず error -20dB --- NG
WHISparam.CalibTone.SPLdB = 65;  % %元はWHISparam.SPLdB_CalibTone = 65;  名前を変更（整合性を取るため）
WHISparam.SrcSnd.SPLdB = 65;
WHISparam.HLoss.CompressionHealth = 0.5;
%WHISparam.HLoss.CompressionHealth = 1;
%WHISparam.HLoss.CompressionHealth = 0;

SwWHISversionList = [1:3];
SwWHISversionList = 3;
%WHISparam.EMLoss.LPFfc = 256*2;
%WHISparam.EMLoss.LPFfc = 2;
%WHISparam.EMLoss.LPForder = 2;
StrEMLoss = '';
if isfield(WHISparam,'EMLoss') == 1 && isfield(WHISparam.EMLoss,'LPFfc') == 1
    StrEMLoss = [ '_EmLpf' int2str(WHISparam.EMLoss.LPFfc)];
end
            
CmprsHlthList = [1 0.5 0];
for nCmprsHlth = 1:length(CmprsHlthList)
    WHISparam.HLoss.CompressionHealth = CmprsHlthList(nCmprsHlth);
    StrCmprsHlth =  ['_Cmprs' int2str(WHISparam.HLoss.CompressionHealth *100) ];
    
    for SwWHISversion= SwWHISversionList
        if SwWHISversion == 1
            StrWHIS = '_WHISv300dtvf';
            WHISparam.SynthMethod = 'DTVF';
            [SndWHIS,SrcSnd,RecCalibTone,WHISparam1] = WHISv300_Batch(SndIn, WHISparam) ;
        elseif SwWHISversion == 2
            StrWHIS = '_WHISv300fabs';
            WHISparam.SynthMethod = 'FBAnaSyn';
            [SndWHIS,SrcSnd,RecCalibTone,WHISparam1] = WHISv300_Batch(SndIn, WHISparam) ;
        elseif SwWHISversion == 3
            StrEMLoss = '';
            StrWHIS = '_WHISv226';
            addpath([DirProg  '/../WHISv226/']);
            ParamHI.fs = WHISparam.fs;
            ParamHI.AudiogramNum    = str2num(WHISparam.HLoss.Type(3));  % WHISparam.HLoss.Type = 'HL2';
            ParamHI.SPLdB_CalibTone = WHISparam.CalibTone.SPLdB;
            ParamHI.SrcSndSPLdB       = WHISparam.SrcSnd.SPLdB;
            ParamHI.getComp             = WHISparam.HLoss.CompressionHealth*100;
            ParamHI.OutMidCrct          = 'FF'; % free field as an example
            [SndWHIS,SrcSnd]             = HIsimBatch(SndIn, ParamHI) ;
        end
        
        NameSrcSnd = [NameSnd  StrWHIS '_Src'];
        NameSndWHIS = [NameSnd StrWHIS];
        
        %% %%%%%%%%
        % Playback & Keep Snd
        %%%%%%%%%%%
        % ap = audioplayer(SndIn,fs);
        % playblocking(ap);
        
        NameSrcSnd1 = [NameSrcSnd  '.wav'];
        [a b c] = fileparts(NameSrcSnd1); disp(b);
        audiowrite(NameSrcSnd1,SrcSnd,fs,'BitsPerSample',24);
        ap = audioplayer(SrcSnd,fs);
        playblocking(ap);
        
        NameSrcSnd_Rdct20 = [NameSrcSnd  '_Rdct-20dB.wav'];
        [a b c] = fileparts(NameSrcSnd_Rdct20); disp(b);
        SrcSndRdct20dB = 10^(-20/20)*SrcSnd;  % -20 dB
        audiowrite(NameSrcSnd_Rdct20,SrcSndRdct20dB,fs,'BitsPerSample',24);
        ap = audioplayer(SrcSndRdct20dB,fs);
        playblocking(ap);
        
        NameSndWHIS1 = [NameSndWHIS '_' WHISparam.HLoss.Type StrCmprsHlth StrEMLoss '.wav'];
        [a b c] = fileparts(NameSndWHIS1); disp(b);
        audiowrite(NameSndWHIS1,SndWHIS,fs,'BitsPerSample',24);
        ap = audioplayer(SndWHIS,fs);
        playblocking(ap);
        
        DiffRMS =rms(SndWHIS)/rms(SrcSnd);
        RMSleveldB(SwWHISversion,nCmprsHlth,:) = 20*log10([rms(SrcSnd), rms(SrcSndRdct20dB), rms(SndWHIS)  DiffRMS])
        DistortionRMS =20*log10(rms(SrcSnd-SndWHIS(1:length(SrcSnd)))/rms(SndWHIS));
        StrCond(SwWHISversion,nCmprsHlth,:) = {[StrWHIS StrCmprsHlth]}

%         if SwWHISversion == 1 && CompressionHealth == 0
%             disp(WHISparam1.CalibTone.Name);
%             audiowrite([DirSnd WHISparam1.CalibTone.Name '.wav'],RecCalibTone,fs,'BitsPerSample',24);
%             %ap = audioplayer(RecCalibTone,fs);
%             %playblocking(ap);
%             RMSlevel(SwWHISversion,nCmprsHlth,:) = 20*log10([rms(SrcSnd), rms(SrcSndRdct20dB), rms(SndWHIS), rms(RecCalibTone)])
%         end
        

        
    end
end

%% %%%%%%%
% Trash
%%%%%%%%%

%getComp = 0; % 0 %
%WHISparam.getComp = 50; % 50 %
% WHISparam.getComp = 100; % 100 %


% GUI版との比較
% WHISparam.HLoss.Type = 'HL2';
% WHISparam.CalibTone.SPLdB = 80;
% WHISparam.SrcSnd.SPLdB = 60;
% 

% NameSrcSnd = 'WHIS_Rec20211012T103524';

