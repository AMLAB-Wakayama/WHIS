%
%  Check_HIsim_IOfuction.m
%  Irino, T.
%  Created:  9 Dec 18 (from testHIsimBatch_forSinCheck.m)
%  Modified: 9 Dec  18
%  Modified: 11 Dec  18
%  Modified: 12 Dec  18  詳細検討用
%
%  Sin波のIO functionのチェック
%
clear
close all

% DirFig = [getenv('HOME') '/Desktop/'];
Mfn = which(eval('mfilename')); % directory of this m-file
DirFig= [ fileparts(Mfn) '/Fig/'];

%% 
ParamHI.SPLdB_CalibTone = 80;
ParamHI.SrcSndSPLdB = 65; % 仮に置く。defalt(InitParamHIでのデフォルト値)。このmファイルでは後で変更される
ParamHI.SwGUIbatch = 'Batch';
[ParamHI] = HIsimFastGC_InitParamHI(ParamHI); % ParamHIのload

%%%%%%%%%%%%%%%%%%%
% 難聴型(オージオグラム)
ParamHI.AudiogramNum = 2; % 80yrs
ParamHI.AudiogramNum = 3; % 70yrs male
%ParamHI.AudiogramNum = 4; % 70yrs female
ParamHI.AudiogramNum = NaN; % 手動設定

if isnan(ParamHI.AudiogramNum) == 1,
    HLtestdB = 50;
    HLtestdB = 70;
    %HLtestdB = 0;
    %HLtestdB = 50;
    ParamHI.HearingLevelVal =  HLtestdB*ones(1,7);     %max(ParamHI.Table_HLdB_DegreeCompressionPreSet)の値より大きくなるように。
    NameFig = ['HIsimIOfunc_HL' int2str(HLtestdB) 'dB_allFaud'];
else
    NameFig = ['HIsimIOfunc_' char(ParamHI.Table_AudiogramName(ParamHI.AudiogramNum))];
end;

%%%%%%%%%%%%%%%%%%%
% サイン波の音圧レベル・周波数ほか
fs = 48000;  
Tdur = 0.2;% in sec

SPLdBList = [0:20:100];
%SPLdBList = 0;
CmprsList = [100 50 0];
%CmprsList = [100];

SrcSndLeveldB = [];
HIsimSndLeveldB = [];
FaudgramList =  ParamHI.FaudgramList;
%FaudgramList = 1000;
nfc = 0;
for fc= FaudgramList
    nfc = nfc +1;
    NumFaud = find(fc == ParamHI.FaudgramList);

    SndIn = sin(2*pi*fc*(0:Tdur*fs-1)/fs);
    SndIn = SndIn(:)'; 
    
    StrLegend(1) = {'Linear (1:1)'};
    for Cmprs = CmprsList
        ParamHI.getComp = Cmprs;
        nCmprs = find(Cmprs == CmprsList);
        StrLegend(nCmprs+1) = {['Cmprs: ' int2str(ParamHI.getComp) '%']};
        
        for nSPLdB = 1:length(SPLdBList)           
            ParamHI.SrcSndSPLdB = SPLdBList(nSPLdB);  % 音圧の変更
            
            [HIsimSnd,SrcSnd, ParamHIbatch] = HIsimBatch(SndIn, ParamHI) ;
             
            SrcSndLeveldB(nfc,nCmprs,nSPLdB) = 20*log10(sqrt(mean(SrcSnd.^2))); %
            HIsimSndLeveldB(nfc,nCmprs, nSPLdB) ...
                = 20*log10(sqrt(mean(HIsimSnd.^2)));

            % 違いがあるかを確認
            if (ParamHIbatch.SPLdB_CalibTone -  ParamHI.SPLdB_CalibTone) ~= 0 || ...
                    (ParamHIbatch.SrcSndSPLdB - ParamHI.SrcSndSPLdB) ~=0
                error('Something wrong');
            end;
        end;
        
    end;
    
    %% %%%%%%%%%
    % Plot
    %%%%%%%%%%%%
    npanelList = nfc;
    if nfc == 7,  npanelList = [7 8]; end;
    
    for npanel = npanelList  % nfc == 7なら、同じ図を２回描く。２度目にlegendを入れるため
        subplot(4,2,npanel);
        BiasVal1 = ParamHI.SPLdB_CalibTone - ParamHIbatch.CalibTone.RMSDigitalLeveldB;
        hp = plot(SPLdBList,squeeze(SrcSndLeveldB(nfc,1,:))+BiasVal1,'--', ...
            SPLdBList,squeeze(HIsimSndLeveldB(nfc,:,:))+BiasVal1,'o-');
        set(hp(1),'Color','c');
        set(hp(2),'Color','m');
        set(hp(3),'Color','g');
        set(hp(4),'Color','b');
        xlabel('Input Level (dB)')
        ylabel('Output Level (dB)')
        text(10,80,[ int2str(fc) ' Hz']);
        axis([0,100, -100,100])
        %title(['Frequency = '  int2str(fc) ' Hz']);
        hold on;
        % Loss Linear の分を表示
        plot(SPLdBList, SPLdBList-ParamHIbatch.HLdB_LossLinear(NumFaud),'*:');
        
        if npanel == 1,  title(NameFig,'interpreter','none'); end;
        if npanel == 2,  title('Sin wave I/O func','interpreter','none'); end;

        if npanel == 8
            StrLegend(nCmprs+2) = {['Linear Loss']};
            legend(StrLegend,'Location', 'SouthEast');
        end;
    end;
    %squeeze(SrcSndLeveldB(nfc,1,:))+BiasVal1
    %squeeze(HIsimSndLeveldB(nfc,:,:))+BiasVal1
    
end;

%%
printi(2,0);
print([DirFig NameFig],'-dpdf','-fillpage')


%% %%%%%%%%%%%%%%%%%%%%%%
%   レベルチェック　13 Dec 2018 
%%%%%%%%%%%%%%%%%%%%%%%%

for nSPLdB = [1 3 6]
    DiffRMSdB = SrcSndLeveldB(:,:,nSPLdB)-HIsimSndLeveldB(:,:,nSPLdB)
    DiffRMSdB_meanFaud = mean(DiffRMSdB)
    pwrDiff = 10.^(DiffRMSdB_meanFaud/10)
end;

% 結果：
% HLtestdB = 0; (HL = 0 dBの時)
% DiffRMSdB_meanFaud = [0.0620    0.0620    0.0620]  <<  0.1 dB未満
% pwrDiff = [    1.0144    1.0144    1.0144] -->  1.4%の誤差。
% Cmprs, SPLdBの値にかかわらず、0.0620 dBとなる。--> OK 計算どおり。

return;

%%

