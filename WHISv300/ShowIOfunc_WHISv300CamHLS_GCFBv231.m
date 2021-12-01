%
%  Plot  IOfunction by WHIS and GCFBv231
%  Irino, T.
%  Created:  22 Aug 21
%  Modified:  22 Aug 21
%  Modified:  10 Sep 21
%  Modified:  26 Sep 21
%  Modified:  12 Oct 21
%  Modified:  20 Oct 21
%  Modified:  21 Oct 21 renamed ShowIOfunc_WHISv300v225_GCFBv231
%  Modified:   1 Nov 21 tidy up
%  Modified:   4 Nov 21 WHISv226 (FreeField vesion) was introduced
%  Modified:  28 Nov 21 mod  WHISv226
%
clear

% startup directory setting
StartupWHIS
DirProg = fileparts(which(mfilename)); % このプログラムがあるところ
% DirProg1 = '/Users/irino/Google ドライブ/GitHub/WHIS/WHISv300'
% strcmp(DirProg,DirProg1)
DirData = [getenv('HOME') '/Data/WHIS/'];
DirSnd = [ DirData  '/Sound/'];
if exist(DirSnd) == 0, mkdir(DirSnd); end

% DirFig = [DirData '/Fig/'];
DirFig = [DirProg '/Fig/'];
DirFigWHIS = DirFig;
if exist(DirFig) == 0, mkdir(DirFig); end
DirGdrive = '/Volumes/GoogleDrive/マイドライブ/';
if exist(DirGdrive) == 0
    DirGdrive = [getenv('HOME')   '/Google ドライブ/'];
end
addpath([DirGdrive  '/YamasemiWork/m-file/WHISv226/']);  % WHISv225/226
addpath([DirGdrive  '/YamasemiWork/m-file/WHIS_CamHLS/']); %CamHLS


fs = 48000;
%%%% GCFB parameter setting %%%%
GCparam = []; % reset all
GCparam.fs = fs;              % 一応設定
% このプログラム中のNHのGCFBv231に必要なものもおく
GCparam.NumCh  = 100;
GCparam.FRange = [100, 12000];
GCparam.OutMidCrct = 'No';  %cochlear inputを見るときは、ELCをいれないこと。
% IOを求めるので、ELCではない。GCparam.OutMidCrct = 'ELC';  %ELCは、通常の外界の音　ーーー　今回は入出力関係のみ
% GCparam.OutMidCrct ='FreeField'; % for checking GCparam.OutMidCrct 31 Oct 21

GCparam.Ctrl = 'dynamic'; % used to be 'time-varying'
GCparam.DynHPAF.StrPrc = 'frame-base';

WHISparam.fs = fs;
WHISparam.GCparam = GCparam;

% full
Param.fcList = [125 250 500 1000 2000 4000 8000];
%Param.fcList = [ 4000 8000];
% Param.SigSPLlist = [-10:10:100];
Param.SPLdBlist = [-10:10:100]; % <-- renamed from Param.SigSPLlist;
Param.CmprsHlthList = [1 0.5 0];

% check IO
% Param.fcList = [4000];
% Param.SPLdBlist = [50:5:60];
% Param.CmprsHlthList = [0.6];
% WHISparam.SwPlot = 1;

%%%%
WHISparam.CalibTone.SPLdB = 65;
% WHISparam.SrcSnd.SPLdB = 65;
%Param.CmprsHlthList = [0 1 0.5];
% WHISparam.HLoss.Type = 'HL2'; 
WHISparam.HLoss.Type = 'HL2_Tsuiki2002_80yr';
WHISparam.HLoss.Type = 'HL3'; 
GCparam.HLoss.Type = WHISparam.HLoss.Type; 
[GCparam2] = GCFBv231_HearingLoss(GCparam); % GCparam.HLossの設定を取るだけ
WHISparam.HLoss.FaudgramList = GCparam2.HLoss.FaudgramList;
WHISparam.HLoss.HearingLeveldB = GCparam2.HLoss.HearingLeveldB;
WHISparam.HLoss.SwType = GCparam2.HLoss.SwType;
WHISparam.HLoss.Type = GCparam2.HLoss.Type;
% 自動化した。もともとは：
% WHISparam.HLoss.HearingLeveldB = [ 23.5, 24.3, 26.8,  27.9,  32.9,  48.3,  68.5];
%書き下した。for WHISv225/226, CamHLS用　　ーーー　WHISv300の場合、同じもので上書きされる
WHISparam.AllowDownSampling = 0;



%% %%%%%%%%%%%%%
% Processing
%%%%%%%%%%%%%%

for SwWHISversion = 0:4 % 0:2 4% 1:4  % 1:3
    if        SwWHISversion == 0, StrWHIS = 'GCFBv231'; % GCFB -- Not WHIS
    elseif SwWHISversion == 1, StrWHIS = 'WHISv300dtvf'; % direct tv filter
    elseif SwWHISversion == 2  StrWHIS = 'WHISv300fbas'; % FB ana/syn
    elseif SwWHISversion == 3  StrWHIS = 'WHISv225'; % direct tv filter
    elseif SwWHISversion == 4  StrWHIS = 'CamHLS';  % Cambridge Hearing Loss Simulator by MAS
    end
    
    Rslt = [];
    
    % sound condition
    Tsnd = 0.25; % sec
    zz = zeros(1,0.025*fs);  % 25 ms silence
    
    StrOMC = '';
    StrXlabel = 'Cochlea input (dB)';
    if strcmp(GCparam.OutMidCrct,'No') == 0,
        StrOMC = ['_' GCparam.OutMidCrct];
        StrXlabel = [GCparam.OutMidCrct ' level (dB)'];
    end
    if SwWHISversion >=1
        DirFig = DirFigWHIS;
        NameFig = ['Fig_IOfunc_' StrWHIS '_GCFB231_NH+' WHISparam.HLoss.Type StrOMC];
    elseif SwWHISversion == 0
        DirFig = [DirProg '/../../GCFB/GCFBv231/Fig/'];
        NameFig = ['Fig_IOfunc_ExctPtn_' WHISparam.HLoss.Type StrOMC];
    end
    DirNameFig = [DirFig  NameFig];
    disp([' '])
    disp(['NameFig : ' NameFig])
    
    if exist([DirNameFig '.mat']) == 2
        disp('--- loading Rslt ---')
        load(DirNameFig)
        Param = Rslt.Param;
        if isfield(Param,'SPLdBlist') == 0  % for compativility
            Param.SPLdBlist = Param.SigSPLlist;
        end
    else
        disp('--- Caliculation ---')
        for nfc = 1:length(Param.fcList)
            fc = Param.fcList(nfc);
            SndOrig = sin(2*pi*fc*(0:Tsnd*fs-1)/fs);
            TW = TaperWindow(length(SndOrig),'han',0.005*fs); % 5ms Taper
            SndOrig = [zz TW(:)'.*SndOrig zz];
            Tsnd = length(SndOrig)/fs;
            disp(['Duration of sound = ' num2str(Tsnd*1000) ' (ms)']);
            HL0SPLdBatCch(nfc) = HL2PinCochlea(fc,0);
            
            cnt = 0;
            for nCmprsHlth = 1:length(Param.CmprsHlthList)
                CmprsHlth = Param.CmprsHlthList(nCmprsHlth);
                WHISparam.HLoss.CompressionHealth  = CmprsHlth;
                
                for nSPL = 1:length(Param.SPLdBlist)
                    WHISparam.SrcSnd.SPLdB = Param.SPLdBlist(nSPL);
                    
                    %% %%%%%%%%%%%%%%%%%%%%
                    %  WHISによる模擬難聴音合成
                    %%%%%%%%%%%%%%%%%%
                    
                    [CalibTone, WHISparam]  = WHISv300_MkCalibTone(WHISparam);
                    RecordedCalibTone =  CalibTone;
                    [SrcSnd4Check, WHISparam] = WHISv300_GetSrcSndNrmlz2CalibTone(SndOrig,RecordedCalibTone,WHISparam);
                    % SrcSnd4Check はチェック用
                    
                    WHISparam.StrWHIS = StrWHIS;
                    if SwWHISversion == 0
                        error('Execute ShowIOfunc_ExctPtn_GCFBv231.m in GCFBv231 in advance. ' )
                    elseif SwWHISversion == 1 %  WHISv300dtvf direct tv filter
                        WHISparam.SynthMethod = 'DTVF';
                        [SndWHIS,SrcSnd,CalibTone,WHISparam] = WHISv300_Batch(SndOrig, WHISparam);
                    elseif SwWHISversion == 2 % WHISv300fbas FB ana/syn
                        WHISparam.SynthMethod = 'FBAnaSyn';
                        [SndWHIS,SrcSnd,CalibTone,WHISparam] = WHISv300_Batch(SndOrig, WHISparam);
                    elseif SwWHISversion == 3 % WHISv225 direct tv filter
                        ParamHI.fs = fs;
                        ParamHI.AudiogramNum = str2num(WHISparam.HLoss.Type(3));  % WHISparam.HLoss.Type = 'HL2'; 80yr
                        ParamHI.SPLdB_CalibTone = WHISparam.CalibTone.SPLdB;
                        ParamHI.SrcSndSPLdB = WHISparam.SrcSnd.SPLdB;
                        ParamHI.getComp = WHISparam.HLoss.CompressionHealth*100;
                        [SndWHIS,SrcSnd] = HIsimBatch(SndOrig, ParamHI) ;
                    elseif SwWHISversion == 4  % 'CamHLS';
                        % Cambridge Hearing Loss Simulator by MAR
                        ParamCamHLS.SRC_POSN = GCparam.OutMidCrct;
                        ParamCamHLS.Type = WHISparam.HLoss.Type;
                        ParamCamHLS.FaudgramList = WHISparam.HLoss.FaudgramList;
                        ParamCamHLS.HearingLeveldB = WHISparam.HLoss.HearingLeveldB;
                        % see testCamHLS_IOfunc.m
                        % to compensate cochlear input
                        ParamCamHLS.target_roots_SPL = Param.SPLdBlist(nSPL) - HL0SPLdBatCch(nfc);
                        [SndWHIS, SrcSnd, ParamCamHLS] = CamHLS(SndOrig,fs,ParamCamHLS);
                        size(SrcSnd)
                    end
                    
                    disp(['--- Using ' StrWHIS ' ---']);
                    [20*log10([rms(SrcSnd4Check), rms(SrcSnd)])] % 一致を確認
                    
                    
                    %% %%%%%%%%%%%%%%%%%%%%
                    %  GCFBの NHで分析
                    %%%%%%%%%%%%%%%%%%
                    if nSPL == 1    % MeddisHCLevelに合わせるためのAmpdB算出. 1回だけ計算
                        OutLeveldB =  WHISparam.SrcSnd.SPLdB;
                        [SndEqM, AmpdB] = Eqlz2MeddisHCLevel(SrcSnd,OutLeveldB);
                        AmpdB4Meddis = AmpdB(2);
                    end
                    
                    for SwSndSrcWHIS = 1:2 % 1:2
                        if SwSndSrcWHIS == 1,   SndAna = SrcSnd;
                        else                    SndAna = SndWHIS;
                        end
                        SndAna = 10^(AmpdB4Meddis/20)*SndAna;
                        
                        figure(20); plot(SndAna)
                        [nSPL, SwSndSrcWHIS, CmprsHlth]
                        figure(10);
                        %%%% GCFB exec %%%%
                        tic
                        GCparam.HLoss.Type = 'NH';
                        GCparam.HLoss.CompressionHealth = 1; %
                        %   Snd =  Eqlz2MeddisHCLevel(SndOrig,SigSPL);
                        [cGCframe, scGCsmpl,GCparamNH,GCresp] = GCFBv231(SndAna,GCparam);
                        tm = toc;
                        disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' ...
                            num2str(tm/Tsnd,4) ' times RealTime.']);
                        disp(' ');
                        cnt = cnt+1;
                        Telapse(cnt) = tm;
                        
                        % 20*log10(max(max(cGCframe)))
                        figure(SwSndSrcWHIS);
                        subplot(3,4,nSPL)
                        [~, nChFr1] = min(abs(fc-GCresp.Fr1));
                        nRange = max(1,min(100,nChFr1+(-5:10)));
                        MeancGCframedB = 20*log10(mean(cGCframe,2));
                        MeancGCframedB = MeancGCframedB + GCparamNH.MeddisIHCLevel_RMS0dB_SPLdB; % MeddisIHCの補正
                        [ MaxGCframedB1, nCh1] =  max(MeancGCframedB(nRange)); %　excitation pattenの最大値
                        MaxGCframedB(SwSndSrcWHIS, nSPL) = MaxGCframedB1;
                        nChPeak = nRange(nCh1);  %範囲内の最大ch
                        %[nChPeak, GCparamNH.Fr1(nChPeak)/1000]
                        plot(1:GCparam.NumCh, MeancGCframedB,nChPeak*[1 1],MaxGCframedB(SwSndSrcWHIS, nSPL)+[-20 20])
                        text(nChPeak,MaxGCframedB(SwSndSrcWHIS, nSPL)+25, int2str(GCparamNH.Fr1(nChPeak)),'HorizontalAlignment','center');
                        text(nChPeak-10,MaxGCframedB(SwSndSrcWHIS, nSPL), int2str(MaxGCframedB(SwSndSrcWHIS, nSPL)),'HorizontalAlignment','right');
                        xlabel('Channel');
                        ylabel('Level (dB)');
                        axis([0 100 -60 80]);
                        drawnow
                        % nChPeak
                    end % for SwSndSrcWHIS = 1:2
                end % for nSPL = 1:length(Param.SPLdBlist)
                
                %% %%%%%%%%
                % Keep Rslt
                %%%%%%%%%%
                for SwSndSrcWHIS = 1:2
                    Rslt.GCIOfunc(SwSndSrcWHIS,nfc,nCmprsHlth,:) = MaxGCframedB(SwSndSrcWHIS,:);
                    % Rslt.HLxMaxGC(SwSndSrcWHIS,nfc,nCmprsHlth) = interp1(MaxGCframedB(SwSndSrcWHIS,:),Param.SPLdBlist,0);
                    Rslt.AbsThrVal(SwSndSrcWHIS,nfc,nCmprsHlth) = interp1(MaxGCframedB(SwSndSrcWHIS,:),Param.SPLdBlist,0);
                    
                    Rslt.HL0Cch(nfc)   = HL2PinCochlea(fc,0);
                    Rslt.HLxCch(nfc) = Rslt.HL0Cch(nfc) + WHISparam.HLoss.HearingLeveldB(nfc);
                    Rslt.DiffHLx(SwSndSrcWHIS,nfc,nCmprsHlth) = Rslt.HLxCch(nfc) - Rslt.AbsThrVal(SwSndSrcWHIS,nfc,nCmprsHlth);
                end
                
            end %  for CmprsHlth = Param.CmprsHlthList
        end % for nfc = 1:length(Param.fcList)
        Rslt.Param = Param;
        save(DirNameFig,'Rslt');
    end % if exist(NameFig)
    
    
    %% %%%%%%%%
    % Plot Rslt
    %%%%%%%%%%%
    figure(SwWHISversion+1);clf;
    ColorList1 = colororder('default');
    % ColorList = ColorList1([1 5 4 2],:);
    % StrLineList = {'-','-','--','-.'};
    ColorList = ColorList1([5 3 1 2],:);
    StrLineList = {'-','--','-','-.'};
    ColorList = ColorList1([5 1 3  2],:);
    StrLineList = {'-','--','-','-.'};
    for nfc = 1:length(Param.fcList)
        fc = Param.fcList(nfc);
        for nCmprsHlth = 1:length(Param.CmprsHlthList)
            CmprsHlth = Param.CmprsHlthList(nCmprsHlth);
            for SwSndSrcWHIS = 1:2
                subplot(4,2,nfc);
                if SwSndSrcWHIS  == 1 %NH
                    StrLine = char(StrLineList(1));
                    ValColor = ColorList(1,:);
                    if CmprsHlth < 1, continue; end  %同じ線を引いてもしかたないので。
                    n100dB = find(Param.SPLdBlist==100);
                    plot( [0 100],Rslt.GCIOfunc(SwSndSrcWHIS,nfc,nCmprsHlth,n100dB)-[100 0],'k:',[-10 110],[0 0],'k-')
                    hold on;
                else
                    StrLine = char(StrLineList(nCmprsHlth+1));
                    ValColor = ColorList(nCmprsHlth+1,:);
                end
                plot(Param.SPLdBlist,squeeze(Rslt.GCIOfunc(SwSndSrcWHIS,nfc,nCmprsHlth,:)), StrLine,'Color',ValColor)
                axis([-5 105 -20 60]);
                set(gca,'XTick', [0:10:100]);
                set(gca,'YTick', [-50:10:100]);
                grid on;
                hold on;
                xlabel(StrXlabel);
                ylabel('Output re. Abs. Thrsh. (dB)');
                % title([GCparamNH.HLoss.Type  ':  ' int2str(fc) ' (Hz) '],'interpreter','none');
                title([StrWHIS ' :  ' int2str(fc) ' (Hz) '],'interpreter','none');
                
                if CmprsHlth == 1  % 書くのは最初の一回で十分
                    plot(Rslt.HL0Cch(nfc), 0, 'k^');
                    plot(Rslt.HL0Cch(nfc)*[1 1], [-5 4], 'k:');
                    text(Rslt.HL0Cch(nfc),5,['HL 0 dB'],'Rotation',90); % ):  num2str(Rslt.HL0Cch(nfc))]
                    if mean(Rslt.HL0Cch(nfc)-Rslt.HLxCch(nfc)) ~= 0
                        plot(Rslt.HLxCch(nfc), 0, 'ko');
                        plot(Rslt.HLxCch(nfc)*[1 1], [-5 19], 'k:');
                        text(Rslt.HLxCch(nfc),21,['HL '  int2str(WHISparam.HLoss.HearingLeveldB(nfc)) ' dB'  ],'Rotation',90); % num2str(Rslt.HLxCch(nfc))
                    end
                end
            end    % for SwSndSrcWHIS = 1:2
        end %  for CmprsHlth = Param.CmprsHlthList
    end % for nfc = 1:length(Param.fcList)
    
    printi(3,0,[2,2,25,40]);
    print(DirNameFig,'-depsc','-tiff');
    
end  % for SwWHISversion = 1:3


%% %%%%%%
% Trash
%%%%%%%%%

%WHISparam.AllowDownSampling = 1 % たしかに時間的には早くなるが、いまいちか。。。　もう少し検討
% BatchではDown samplingする意味なし。
