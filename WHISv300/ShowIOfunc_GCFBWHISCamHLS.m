%
%   ShowIOfunction of GCFB-WHIS-CamHLS and compare AbsThr 
%    Irino, T.
%   Created:   13 Oct 21
%   Modified:  13 Oct 21
%   Modified:    9 Nov 21
%   Modified:  11 Nov 21
%
%
clear
clf

StartupWHIS
% startup directory setting
DirProg = fileparts(which(mfilename)); % このプログラムがあるところ
%DirFigWHIS = [DirProg '/Fig/'];
DirFigWHIS = [DirProg '/_Local/'];

% DirFigGCFB = [DirProg '/../../GCFB/GCFBv231/Fig/'];
DirFigGCFB = [DirProg '/../../GCFB/GCFBv231/_Local/'];
NameFileHdr = 'Fig_IOfunc_';
GCparam.HLoss.Type = 'HL2_Tsuiki2002_80yr';
[GCparam2] = GCFBv231_HearingLoss(GCparam); % GCparam.HLossの設定を取るだけ
WHISparam.HLoss.FaudgramList = GCparam2.HLoss.FaudgramList;
WHISparam.HLoss.HearingLeveldB = GCparam2.HLoss.HearingLeveldB;


ColorList1 = colororder('default');
% ColorList = ColorList1([5 3 1 2],:);
ColorList = ColorList1([1 5 4 3 ],:);
StrLineList = {'-','--','-.','--'};
StrXlabel = 'Cochlea input (dB)';
StrPanelList = {'a', 'b', 'c','d', 'e'};

cnt = 0;
cntP = 0;
for SwWHISversion = 0:4 % 0:2 4% 1:4  % 1:3
    if  SwWHISversion == 0
        StrWHIS = 'GCFBv231';
        DirFig = DirFigGCFB;
        NameFile = [NameFileHdr 'ExctPtn_' GCparam.HLoss.Type];
    else
        DirFig = DirFigWHIS;
        if SwWHISversion == 1,        StrWHIS = 'WHISv300dtvf'; % direct tv filter
       elseif SwWHISversion == 2,  StrWHIS = 'WHISv300fbas'; % FB ana/syn
        elseif SwWHISversion == 3, StrWHIS = 'WHISv225'; % direct tv filter
        elseif SwWHISversion == 4, StrWHIS = 'CamHLS';  % Cambridge Hearing Loss Simulator by MAS
        end
        StrGCFB = 'GCFB231'; % 'GCFBv231'; % GCFB -- Not WHIS
        NameFile = [NameFileHdr StrWHIS '_' StrGCFB  '_NH+' GCparam.HLoss.Type];
    end
    load([DirFig NameFile])
    Param = Rslt.Param;

    %%%%%%%
    %% Plot fig
    %%%%%%
    nfcPlot = 3:6;
    for np = 1:length(nfcPlot)
        cntP = (np-1)*5+SwWHISversion+1;
        nfc = nfcPlot(np);
        fc = Param.fcList(nfc);
        subplot(4,5,cntP)  % from ShowIOfunc
        for nCmprsHlth = 1:3
            %                 if SwWHISversion==0,
            %                     ValIO = squeeze(Rslt.GCIOfunc(SwWHISversion,nfc,nCmprsHlth,:));
            %                 else
            %                     ValIO = squeeze(Rslt.GCIOfunc(SwWHISversion,nfc,nCmprsHlth,:));
            %                 end
            for SwSndSrcWHIS = 1:2
                if SwSndSrcWHIS  == 1 %NH
                    StrLine = char(StrLineList(1));
                    ValColor = ColorList(1,:);
                    if nCmprsHlth > 1, continue; end  %同じ線を引いてもしかたないので。
                    n100dB = find(Param.SPLdBlist==100);
                    plot( [0 100],Rslt.GCIOfunc(SwSndSrcWHIS,nfc,nCmprsHlth,n100dB)-[100 0],'k:',[-10 110],[0 0],'k-')
                    hold on;
                else
                    StrLine = char(StrLineList(nCmprsHlth+1));
                    ValColor = ColorList(nCmprsHlth+1,:);
                end
                plot(Param.SPLdBlist,squeeze(Rslt.GCIOfunc(SwSndSrcWHIS,nfc,nCmprsHlth,:)), StrLine,'Color',ValColor)
                axis([-5 105 -20 60]);
                set(gca,'XTick', [0:20:100]);
                set(gca,'YTick', [-50:10:100]);
                grid on;
                hold on;
                xlabel(StrXlabel);
                ylabel('Output re. Abs. Thrsh. (dB)');
                % title([GCparam.HLoss.Type  ':  ' int2str(fc) ' (Hz) '],'interpreter','none');
                title([StrWHIS ' :  ' int2str(fc) ' (Hz) '],'interpreter','none');

                if nCmprsHlth == 1  && SwSndSrcWHIS == 1% 書くのは最初の一回で十分
                    plot(Rslt.HL0Cch(nfc), 0, 'k^');
                    plot(Rslt.HL0Cch(nfc)*[1 1], [-5 4], 'k:');
                    text(Rslt.HL0Cch(nfc),5,['HL 0 dB'],'Rotation',90); % ):  num2str(Rslt.HL0Cch(nfc))]
                    if mean(Rslt.HL0Cch(nfc)-Rslt.HLxCch(nfc)) ~= 0
                        plot(Rslt.HLxCch(nfc), 0, 'ko');
                        %plot(Rslt.HLxCch(nfc)*[1 1], [-5 19], 'k:');
                        plot(Rslt.HLxCch(nfc)*[1 1], [-5  4], 'k:');
                        % text(Rslt.HLxCch(nfc),21,['HL '  int2str(WHISparam.HLoss.HearingLeveldB(nfc)) ' dB'  ],'Rotation',90); % num2str(Rslt.HLxCch(nfc))
                        text(Rslt.HLxCch(nfc),5,['HL '  int2str(WHISparam.HLoss.HearingLeveldB(nfc)) ' dB'  ],'Rotation',90); % num2str(Rslt.HLxCch(nfc))
                    end
                end
            end    % for SwSndSrcWHIS = 1:2
        end % for nCmprsList

        text(0,55,['(' char(StrPanelList(SwWHISversion+1)) int2str(np) ') ' StrWHIS ',  ' int2str(fc) ' Hz'] )

    end % np
    
    %%%%%%%
    %% error calcualtion
    %%%%%%
    Rslt.HL0Cch
    Rslt.HLxCch
    Rslt.Param.CmprsHlthList
    cnt = cnt + 1;
    AbsThr_NH(cnt,:) = Rslt.AbsThrVal(1,:,1);
    Diff_AbsThr_NH(cnt,:) = Rslt.HL0Cch - Rslt.AbsThrVal(1,:,1);

    AbsThr_HL(cnt,:,1:3) =  squeeze(Rslt.AbsThrVal(2,:,1:3));
    Diff_AbsThr_HL1 = Rslt.HLxCch'*ones(1,3) - squeeze(Rslt.AbsThrVal(2,:,1:3));
    Diff_AbsThr_HL(cnt,:,1:3) = Diff_AbsThr_HL1;


end % SwWHISversion 

ReSubPlot(4,5,0)
NameFig = [DirFigWHIS 'Fig_IOfunc_GCFBWHISCamHLS_NH+' GCparam.HLoss.Type];
printi(3,0,2.2) %  [-6.6  -3.8  39.6  31.7]
printi(3,0,[-6.6  -3.8  39.6  25])
print(NameFig,'-depsc','-tiff');


Diff_AbsThr_NH
DiffFromGCFB_NH = Diff_AbsThr_NH - Diff_AbsThr_NH(1,:,:)
RMSerrorFromGCFB_NH = rms(DiffFromGCFB_NH,2)


Diff_AbsThr_HL
DiffFromGCFB_HL = Diff_AbsThr_HL - Diff_AbsThr_HL(1,:,:)
RMSerrorFromGCFB_HL = rms(DiffFromGCFB_HL,2)


%     if nnn == 0, load([DirFigGCFB 'Fig_IOfunc_ExctPtn_HL2_Tsuiki2002_80yr.mat']);
%     elseif nnn == 1, load([DirFig 'Fig_IOfunc_WHISv300dtvf_GCFB231_NH+HL2_Tsuiki2002_80yr.mat']);
%     elseif nnn == 2, load([DirFig 'Fig_IOfunc_WHISv300fbas_GCFB231_NH+HL2_Tsuiki2002_80yr.mat']);
%     elseif nnn == 3, load([DirFig 'Fig_IOfunc_WHISv225_GCFB231_NH+HL2_Tsuiki2002_80yr.mat']);
%     elseif nnn == 3, load([DirFig 'Fig_IOfunc_CamHLS_GCFB231_NH+HL2_Tsuiki2002_80yr.mat']);
%     end


