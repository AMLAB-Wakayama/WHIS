%
%       Show Auditory spectrogram by WHIS and GCFBv23
%       Irino, T.
%       Created:   1 Nov 2021 from renamed ShowIOfunc_WHISv300v225_GCFBv231
%       Modified:  1 Nov 2021
%       Modified:  3 Nov 2021
%       Modified:  4 Nov 2021 ShowIOfunc_WHISv300v226_GCFBv231
%       Modified:  5 Nov 2021 introducing HL3 for CamHLS 
%       Modified: 11 Nov 2021 
%       Modified:  28 Nov 2021 mod  WHISv226
%       Modified:   6  Mar 2022   WHISv300_func --> WHISv30_func, GCFBv231--> GCFBv232
%       Modified:  20 Mar 2022  v302  <--- GCFBv233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%
clear

% startup directory setting
StartupWHIS;
DirProg = fileparts(which(mfilename)); % このプログラムがあるところ
DirData = [getenv('HOME') '/Data/WHIS/'];
DirFig = [DirData '/Fig/Spec/'];
if exist(DirFig) == 0, mkdir(DirFig); end
DirSnd = [ DirData  '/Sound/'];
if exist(DirSnd) == 0, mkdir(DirSnd); end

addpath([DirProg  '/../WHISv226/']);  % WHISv225/226

DirGdrive = '/Volumes/GoogleDrive/マイドライブ/';
if exist(DirGdrive) == 0
    DirGdrive = [getenv('HOME')   '/Google ドライブ/'];
end
addpath([DirGdrive  '/YamasemiWork/m-file/WHIS_CamHLS/']); %CamHLS

%%%%%%%%%%%
%% Parameter settings
%%%%%%%%%

fs = 48000;
%%%% GCFB parameter setting %%%%
GCparam = []; % reset all
GCparam.fs = fs;              % 一応設定
% このプログラム中のNHのGCFBv233に必要なものもおく
GCparam.NumCh  = 100;
GCparam.FRange = [100, 12000];
% GCparam.OutMidCrct = 'No';  %cochlear inputを見るときは、ELCをいれないこと。
% IOを求めるので、ELCではない。GCparam.OutMidCrct = 'ELC';  %ELCは、通常の外界の音　ーーー　今回は入出力関係のみ
% Spec はFreeFieldで
GCparam.OutMidCrct ='FreeField'; % for spec

GCparam.Ctrl = 'dynamic'; % used to be 'time-varying'
GCparam.DynHPAF.StrPrc = 'frame-base';

WHISparam.fs = fs;
WHISparam.GCparam = GCparam;

Param.SPLdBlist = [50, 80];
Param.CmprsHlthList = [1, 0.5, 0];

%%%%
WHISparam.CalibTone.SPLdB = 65;
%WHISparam.SrcSnd.SPLdB = 65;
WHISparam.HLoss.Type = 'HL2_Tsuiki2002_80yr'; %かならずこれ。
%WHISparam.HLoss.Type = 'HL3'; 
GCparam.HLoss.Type = WHISparam.HLoss.Type; 
[GCparam2] = GCFBv23_HearingLoss(GCparam); % GCparam.HLossの設定を取るだけ
WHISparam.HLoss.FaudgramList = GCparam2.HLoss.FaudgramList;
WHISparam.HLoss.HearingLeveldB = GCparam2.HLoss.HearingLeveldB;
WHISparam.HLoss.SwType = GCparam2.HLoss.SwType;
WHISparam.HLoss.Type = GCparam2.HLoss.Type;
% 自動化した。もともとは：
% WHISparam.HLoss.HearingLeveldB = [ 23.5, 24.3, 26.8,  27.9,  32.9,  48.3,  68.5];
%書き下した。for WHISv225/226, CamHLS用　　ーーー　WHISv300の場合、同じもので上書きされる
WHISparam.AllowDownSampling = 0;

%%%%%%%%%%%
%% %%%%%%%%%%%%%%

NameFigAll = ['Fig_DistanceSpec_' WHISparam.HLoss.Type];
DirNameFigAll  = [DirFig '../' NameFigAll ];

if exist([DirNameFigAll '.mat']) > 0
    load(DirNameFigAll)
else
    % Calculation
    LenNumSnd = 1; % for debug
    LenNumSnd = 20; % main calculation
    if LenNumSnd == 20
        rng(12345);
        SpkList = ones(5,1)*[1:4];
        nRand = randperm(LenNumSnd);
        SpkList = SpkList(nRand);
        NumSndList = randperm(LenNumSnd);
    elseif LenNumSnd == 1 % for debug
        SpkList = 1;
        NumSndList = 1;
    end

    Rslt = [];
    for NumSnd = 1:LenNumSnd % 1:20
        disp(' ')
        disp('---------------------------------------------')
        for SwWHISversion = 0:7 %0:7
            if SwWHISversion == 0 || SwWHISversion >= 5
                StrWHIS = 'GCFBv233'; % GCFB -- Not WHIS
                if SwWHISversion == 5,       SNRdB = 3;
                elseif SwWHISversion == 6, SNRdB = 0;
                elseif SwWHISversion == 7, SNRdB = -3;
                end
            elseif SwWHISversion == 1
                StrWHIS = 'WHISv301dtvf'; % direct tv filter
            elseif SwWHISversion == 2
                StrWHIS = 'WHISv301fbas'; % FB ana/syn
            elseif SwWHISversion == 3
                StrWHIS = 'WHISv226'; % direct tv filter
            elseif SwWHISversion == 4
                StrWHIS = 'CamHLS';  % Cambridge Hearing Loss Simulator by MAS
            end

            %%  Load sound %%%%%%
            NumList = 1;   % 1-- 20
            % NumSnd = 1; % 1--20
            % random化：男性女性各２名ずつランダムに
            [SndOrig,fs1,NameSnd] = LoadFW07(SpkList(NumSnd),4,NumList,NumSndList(NumSnd));
            SndOrig = SndOrig(:)';
            LenSnd = length(SndOrig);
            Tsnd = LenSnd/fs;
            if fs1 ~= fs, error('fs inconsistent.'); end

            %%%%%%%%%%%
            %%  雑音 pinknoise 重畳 
            %%%%%%%%%%%
            if SwWHISversion >= 5 % GCFB pinknoise added
                StrWHIS = [StrWHIS '_SNR' int2str(SNRdB) 'dB'];
                pink1 = pinknoise(length(SndOrig));
                pink1 = pink1/rms(pink1)*rms(SndOrig)*10^(-SNRdB/20);
                SndOrigNoise = SndOrig +pink1(:)';
                %             ap = audioplayer(SndOrig,fs);
                %             playblocking(ap);
                %             ap2 = audioplayer(SndOrigNoise,fs);
                %             playblocking(ap2);
                figure(10);
                plot(1:LenSnd,SndOrig,1:LenSnd,SndOrigNoise+0.5);
                SndOrig = SndOrigNoise;
            end


            %%%%%%%%%%%
            %% WHIS processing 
            %%%%%%%%%%%
            NameFig = ['Fig_Spec_' StrWHIS '_' WHISparam.HLoss.Type '_' NameSnd];
            DirNameFig = [DirFig NameFig];
            clear Rslt

            if exist([DirNameFig '.mat']) == 2
                disp(['Loading : ' NameFig] )
                load(DirNameFig)
            else
                disp(['Calculating : ' NameFig] )

                cnt = 0;
                for nSPL = 1:length(Param.SPLdBlist)
                    SPLdB =  Param.SPLdBlist(nSPL);
                    WHISparam.SrcSnd.SPLdB = Param.SPLdBlist(nSPL);

                    for nCmprsHlth = 1:length(Param.CmprsHlthList)
                        cnt = cnt+1;
                        CmprsHlth = Param.CmprsHlthList(nCmprsHlth);
                        WHISparam.HLoss.CompressionHealth  = CmprsHlth;

                        %% %%%%%%%%%%%%%%%%
                        %  WHISによる模擬難聴音合成
                        %%%%%%%%%%%%%%%%%%
                        [CalibTone, WHISparam]  = WHISv30_MkCalibTone(WHISparam);
                        RecordedCalibTone =  CalibTone;
                        [SrcSnd4Check, WHISparam] = WHISv30_GetSrcSndNrmlz2CalibTone(SndOrig,RecordedCalibTone,WHISparam);
                        % SrcSnd4Check はチェック用

                        WHISparam.StrWHIS = StrWHIS;
                        if SwWHISversion == 0 || SwWHISversion >= 5
                            disp('Skip WHIS processing' );
                            SndWHIS = SrcSnd4Check;
                            SrcSnd    = SrcSnd4Check;
                        elseif SwWHISversion == 1 %  WHISv300dtvf direct tv filter
                            WHISparam.SynthMethod = 'DTVF';
                            [SndWHIS,SrcSnd,CalibTone,WHISparam] = WHISv30_Batch(SndOrig, WHISparam);
                        elseif SwWHISversion == 2 % WHISv300fbas FB ana/syn
                            WHISparam.SynthMethod = 'FBAnaSyn';
                            [SndWHIS,SrcSnd,CalibTone,WHISparam] = WHISv30_Batch(SndOrig, WHISparam);
                        elseif SwWHISversion == 3 % WHISv226 direct tv filter
                            ParamHI.fs = fs;
                             % ParamHI.AudiogramNum = str2num(WHISparam.HLoss.Type(3));  % WHISparam.HLoss.Type = 'HL2'; 80yr
                            ParamHI.AudiogramNum = WHISparam.HLoss.SwType;
                            ParamHI.OutMidCrct       = GCparam.OutMidCrct;
                            ParamHI.SPLdB_CalibTone = WHISparam.CalibTone.SPLdB;
                            ParamHI.SrcSndSPLdB    = WHISparam.SrcSnd.SPLdB;
                            ParamHI.getComp           = WHISparam.HLoss.CompressionHealth*100;
                            [SndWHIS,SrcSnd] = HIsimBatch(SndOrig, ParamHI) ;
                        elseif SwWHISversion == 4  % 'CamHLS'; % Cambridge Hearing Loss Simulator by MAR
                            % Our setting for CamHLS
                            ParamCamHLS.Type                = WHISparam.HLoss.Type;
                            ParamCamHLS.FaudgramList    = WHISparam.HLoss.FaudgramList;
                            ParamCamHLS.HearingLeveldB = WHISparam.HLoss.HearingLeveldB;
                            % 
                            ParamCamHLS.SRC_POSN        = GCparam.OutMidCrct;
                            % ParamCamHLS.CmpnstdBSrcSnd = HL0SPLdBatCch(nfc); IO function用：
                            % see testCamHLS_IOfunc.m
                            % to compensate cochlear input
                            %--->  ParamCamHLS.CmpnstdBSrcSnd = 0; % 調整必要
                            ParamCamHLS.CmpnstdBSrcSnd = -6.23; % FW07  話者が違ってもそれほど変わらない　このままでOK
                            ParamCamHLS.target_roots_SPL = Param.SPLdBlist(nSPL) - ParamCamHLS.CmpnstdBSrcSnd;
                            [SndWHIS, SrcSnd, ParamCamHLS] = CamHLS(SndOrig,fs,ParamCamHLS);
                            size(SrcSnd)
                        end

                        disp(['--- ' NameFig ' ---']);
                        LeveldBSrcSnd = 20*log10([rms(SrcSnd), rms(SrcSnd4Check)]); % 一致を確認
                        Rslt.LeveldBSrcSnd(nSPL,nCmprsHlth) =  LeveldBSrcSnd(1);
                        Rslt.LeveldBSrcSnd4Check(nSPL,nCmprsHlth) =  LeveldBSrcSnd(2);
                        Rslt.LeveldBSrcSndDiff(nSPL,nCmprsHlth) =  diff(LeveldBSrcSnd);
                        disp([LeveldBSrcSnd  diff(LeveldBSrcSnd)])
                        if abs(diff(LeveldBSrcSnd)) > eps*100
                            warning('Check level')
                        end


                        %% %%%%%%%%%%%%%%%%%%%%
                        %  GCFBの分析
                        %%%%%%%%%%%%%%%%%%
                        if nSPL == 1    % MeddisHCLevelに合わせるためのAmpdB算出. 1回だけ計算
                            OutLeveldB =  WHISparam.SrcSnd.SPLdB;
                            [SndEqM, AmpdB] = Eqlz2MeddisHCLevel(SrcSnd,OutLeveldB);
                            AmpdB4Meddis = AmpdB(2);
                        end

                        SndAna = 10^(AmpdB4Meddis/20)*SndWHIS;
                        %%%% GCFB exec %%%%
                        tic
                        if  SwWHISversion == 0 || SwWHISversion == 5
                            GCparam.HLoss.Type = WHISparam.HLoss.Type; %  = 'HL2_Tsuiki2002_80yr'; %
                            GCparam.HLoss.CompressionHealth = WHISparam.HLoss.CompressionHealth;
                        elseif  SwWHISversion >= 1  || SwWHISversion <= 4%  WHIS処理音は常にNHで分析
                            GCparam.HLoss.Type = 'NH';
                            GCparam.HLoss.CompressionHealth = 1; %
                        end
                        [cGCframe, scGCsmpl,GCparamOut,GCresp] = GCFBv233(SndAna,GCparam);
                        tm = toc;
                        disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' ...
                            num2str(tm/Tsnd,4) ' times RealTime.']);
                        disp(' ');

                        %% Save result
                        Rslt.StrCond(nSPL,nCmprsHlth) = {[int2str(SPLdB) 'dB_C' num2str(CmprsHlth)]};
                        Rslt.LabelSPL(nSPL,nCmprsHlth) = {[int2str(SPLdB) 'dB']};
                        Rslt.LabelCmprsHlth(nSPL,nCmprsHlth) = {['C' num2str(CmprsHlth)]};
                        Rslt.GCparam(nSPL,nCmprsHlth) = GCparam;
                        Rslt.GCparamOut(nSPL,nCmprsHlth) = GCparamOut;
                        Rslt.GCresp(nSPL,nCmprsHlth) = GCresp;
                        Rslt.WHISparam(nSPL,nCmprsHlth) = WHISparam;
                        Rslt.cGCframe(nSPL,nCmprsHlth,:,:) = cGCframe;

                        %% Plot
                        figure(SwWHISversion + 1);
                        NameTitle = [StrWHIS '_' WHISparam.HLoss.Type(1:3) ...
                            '_C' int2str(CmprsHlth*100) '_' int2str(SPLdB) 'dB_' NameSnd];
                        subplot(2,3,cnt)
                        [NumCh,LenFrame] = size(cGCframe);
                        tms = (0:LenFrame-1)/GCparamOut.DynHPAF.fs*1000;
                        image(tms,1:NumCh,cGCframe*200)
                        set(gca,'YDir','normal');
                        xlabel('Time (ms)')
                        ylabel('Channel')
                        title(NameTitle,'Interpreter','none');
                        drawnow;

                    end % for nCmprsHlth = 1:length(Param.CmprsHlthList)
                end % for nSPL = 1:length(Param.SPLdBlist)

                try
                    save(DirNameFig,'Rslt');
                    printi(3,0);
                    print(DirNameFig,'-depsc','-tiff');
                catch
                    disp('Save data later....')
                end

            end % if exist

            % Rslt.cGCframe
            % rms(Rslt.cGCframe,[3 4])

            %% %%%%%%%%%
            % Analysis
            %%%%%%%%%%%
            if SwWHISversion == 0
                cGCframeGCFB = Rslt.cGCframe;
                [LenSPL,LenCmprsHlth] = size(rms(cGCframeGCFB,[3 4]));
            else

                for nSPL = 1:length(Param.SPLdBlist)
                    for nCmprsHlth = 1:length(Param.CmprsHlthList)
                        Spec1 = squeeze(cGCframeGCFB(nSPL,nCmprsHlth,:,:));
                        Spec2 = squeeze(Rslt.cGCframe(nSPL,nCmprsHlth,:,:));
                        Dspec = DistanceSpecShift(Spec1,Spec2,30);
                        % cGCframeErrRMS= rms(Rslt.cGCframe - cGCframeGCFB,[3 4])./rms(cGCframeGCFB,[3 4]);
                        RsltAll.LeveldBSrcSnd(NumSnd, SwWHISversion, nSPL,nCmprsHlth)   = Rslt.LeveldBSrcSnd(nSPL,nCmprsHlth);
                        RsltAll.LeveldBSrcSnd4Check(NumSnd, SwWHISversion, nSPL,nCmprsHlth)   = Rslt.LeveldBSrcSnd4Check(nSPL,nCmprsHlth);
                        RsltAll.LeveldBSrcSndDiff(NumSnd, SwWHISversion, nSPL,nCmprsHlth)   = Rslt.LeveldBSrcSndDiff(nSPL,nCmprsHlth);
                        RsltAll.MinErrdB(NumSnd, SwWHISversion, nSPL,nCmprsHlth)   = Dspec.MinErrdB;
                        RsltAll.MinErrNshift(NumSnd, SwWHISversion, nSPL,nCmprsHlth)   = Dspec.MinErrNshift;
                        RsltAll.ErrdBNoShiftdB(NumSnd, SwWHISversion, nSPL,nCmprsHlth)   = Dspec.ErrNoShiftdB;
                        RsltAll.Label.Snd(NumSnd,SwWHISversion,nSPL,nCmprsHlth) = {NameSnd};
                        RsltAll.Label.WHIS(NumSnd,SwWHISversion,nSPL,nCmprsHlth)  = {StrWHIS};
                        RsltAll.Label.SPL(NumSnd,SwWHISversion,nSPL,nCmprsHlth) = Rslt.LabelSPL(nSPL,nCmprsHlth);
                        RsltAll.Label.CmprsHlth(NumSnd,SwWHISversion,nSPL,nCmprsHlth) = Rslt.LabelCmprsHlth(nSPL,nCmprsHlth);

                        disp([Param.SPLdBlist(nSPL), Param.CmprsHlthList(nCmprsHlth), Dspec.MinErrdB,  Dspec.MinErrNshift, Dspec.ErrNoShiftdB])

                    end
                end

            end
        end % for SwWHISversion = [0 1 2 4]
    end % for NumSnd

    save(DirNameFigAll,'RsltAll');
end %  if exist([DirNameFigAll '.mat']) > 0


%%%%%%%%%%%%
%% Plot 
%%%%%%%%%%%%
figure(10); clf
MeanMinErrdB = squeeze(mean(RsltAll.MinErrdB(:,:,:,:),1));
StdMinErrdB = squeeze(std(RsltAll.MinErrdB(:,:,:,:),[],1));
cnt = 0;
clf
nWHIS = [1:4];
nNoise = 5:7;
Marker = {'*','o','x'};
for nSPL = 1:length(Param.SPLdBlist)
    for nCmprsHlth = 1:length(Param.CmprsHlthList)
        cnt = cnt+1;
        subplot(2,3,cnt);
        y = MeanMinErrdB(nWHIS,nSPL,nCmprsHlth);
        for k = 1:length(y)
          hb = bar(k,y(k));
          %hb = bar(k,y(k),'Facecolor',char(Colorbar(k)));
          %hb.FaceColor= 'flat';
          %hb.CData = k;
          hold on
        end
        title([int2str(Param.SPLdBlist(nSPL)) 'dB SPL,  \alpha = ' num2str(Param.CmprsHlthList(nCmprsHlth))])
        hold on
        errorbar(MeanMinErrdB(nWHIS,nSPL,nCmprsHlth), StdMinErrdB(nWHIS,nSPL,nCmprsHlth),'k.');
        ax = axis;
        for nnn = 1:length(nNoise)
            plot(ax(2)-0.7+0.2*nnn,MeanMinErrdB(nNoise(nnn),nSPL,nCmprsHlth),'Marker',Marker(nnn),'Color','k')
            errorbar(ax(2)-0.7+0.2*nnn,MeanMinErrdB(nNoise(nnn),nSPL,nCmprsHlth),StdMinErrdB(nNoise(nnn),nSPL,nCmprsHlth),'k.')
        end
        % axis([ax(1)+0.2, ax(2)+0.3, -15, 0])
        axis([ax(1)+0.2, ax(2)+0.3, -11, 0])
        %xlabel('Method')
        ylabel('Normalized distance (dB)')
        set(gca,'xtick',[1:5])
        set(gca,'xticklabel',{'WHIS_{300}^{dtvf}','WHIS_{300}^{fbas}','WHIS_{226}','HLS_{Cam}','Noise'})
    end
end

% CamHLS 事前計算で、以下の計算をした結果、6.2297 dB  --
CmpnstdBSrcSnd1 = [RsltAll.LeveldBSrcSnd(:,4,1,1), RsltAll.LeveldBSrcSnd4Check(:,4,1,1), RsltAll.LeveldBSrcSndDiff(:,4,1,1)];
disp(CmpnstdBSrcSnd1)
disp(mean(CmpnstdBSrcSnd1))
disp(std(CmpnstdBSrcSnd1))

printi(3,0,1.5);
print(DirNameFigAll ,'-depsc','-tiff');


%%%%%%%%%%%%
%% Stat
%%%%%%%%%%%%
figure
[p,tbl,stats] = anovan(RsltAll.MinErrdB(:),...
    {RsltAll.Label.WHIS(:), RsltAll.Label.SPL(:), RsltAll.Label.CmprsHlth(:)}, ...
    'model','interaction','varnames',{'WHIS','SPL','CmprsHlth'});
results = multcompare(stats,'Dimension',[1 2 3])
results = multcompare(stats,'Dimension',[1])




%%%%%%%%%%%%%%%%%
%% Trash 
%%%%%%%%%%%%%%%%%
% 6 Nov 2021
% WHISv226で、ELCかFreeFieldかの違い
% HL3_70yr   --> たかだか0.3dB  --- 無視できる。
% ans(:,:,1,1) =    1.4280e-13
% ans(:,:,2,1) =    3.3381e-14
% ans(:,:,1,2) =     0.1045
% ans(:,:,2,2) =     0.3169
% ans(:,:,1,3) =     0.1039
% ans(:,:,2,3) =     0.3417

%
% 2021/11/3
% CamHLS 事前計算で、以下の計算をした結果、6.2297 dB  --
% 補正前後で、errorの差分は、0.0340    0.1930,      -0.1763   -0.2314
% すべて0.25 dB未満 --- 無視できるでしょう。
%
% ---- 6.3 dB 補正を行った場合
%
% >> MeanMinErrdB
%
% MeanMinErrdB(:,:,1) =
%
%    -7.7313   -4.9606
%    -7.5757   -4.4408
%    -3.6213   -1.9598
%
%
% MeanMinErrdB(:,:,2) =
%
%    -7.2035   -7.6570
%    -7.0822   -5.9191
%    -4.7232   -4.3468
%
%
% ---- 補正を行なわなかった場合
%
% MeanMinErrdB(:,:,1) =
%
%    -7.7313   -4.9606
%    -7.5757   -4.4408
%    -3.6553   -2.1528
%
%
% MeanMinErrdB(:,:,2) =
%
%    -7.2035   -7.6570
%    -7.0822   -5.9191
%    -4.5469   -4.1154




%% %%%%%%
% Trash
%%%%%%%%%
