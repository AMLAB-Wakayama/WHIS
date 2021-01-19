%
%      Calculate IO function of GCFB with and without Fast Hearing Impairment Simulator 
%      IRINO T.
%      Created:    23 Dec 2013 from CalIO_HIsimFastGC.m
%      Modified:   23 Dec 2013
%      Modified:   26 Dec 2013  (HISparam.frat_LevelCenter =  65 etc.)
%      Modified:   26 Dec 2013b  (SPL2HL)
%      Modified:   29 Dec 2013   (Graph)
%      Modified:   10 Jan 2014  (Graph line color)
%
%
clear
close all

fs = 48000;
Tsnd = 0.1;

fcList = 250*2.^(0:5);
%fcList = 1000;
LeveldB_InternalThrsh = 50;

for nfc = 1:length(fcList);
 fc = fcList(nfc);
 
 NameRslt = ['~/tmp/IOfunc_GCFBwHIsim_' int2str(fc) 'Hz'];
 
 if exist([NameRslt '.mat']) ~= 0,
     disp(['*** Load ' NameRslt ' ***']);
     load(NameRslt);
      
 
 else %%% Calculate all %%%
     
 SndSrc = sin(2*pi*fc*(0:Tsnd*fs-1)/fs);
 SndSrc = 0.9*TaperWindow(Tsnd*fs,'han',0.01*fs).*SndSrc;  % the same results with 5ms taper
 %sound(SndSrc,fs)

 [TestVal, AmpdB] = Eqlz2MeddisHCLevel(1,0);
 LeveldB_MHC = AmpdB(3);
 %% 

 SPLlist = [100:-10:0];
  

 
 for nSPL = 1:length(SPLlist)
    LeveldB = SPLlist(nSPL);
    [SndEqM, AmpdB] = Eqlz2MeddisHCLevel(SndSrc,LeveldB);
    SndIn = SndEqM(:)';    
    
    %%%%%%%% HIsim %%%%%%%%
    figure(1)
    HISparam.fs = fs;
    HISparam.RatioInvCompression = 1; % default
    % HISparam.RatioInvCompression = 0.7;
    % HISparam.RatioInvCompression = 1/3;
    % HISparam.RatioInvCompression = 0;
    %HISparam.frat_LevelCenter =  65; % check 25 Dec 2013 --> default
    % HISparam.TVFparam.Twin =  0.020; % sec --> default

    HISparam.DegreeOfHelthyCompression = 1-HISparam.RatioInvCompression; % alpha
    
    [SndHIS, HISparam] = HIsimFastGC(SndIn, HISparam);


    for SwSndIn = [1 2];
        
        if SwSndIn == 1, % NH (without HI simulator)
            SndCal = SndIn;
            LeveldB_SndIn(nSPL) = 10*log10(mean(SndIn.^2))+ LeveldB_MHC;
        elseif SwSndIn == 2, % Simulated HI (with HI simulator)
            SndCal = SndHIS;
            LeveldB_SndHIS(nSPL) = 10*log10(mean(SndHIS.^2))+ LeveldB_MHC;
        end;  

        
        %%%%%%%% GCFB %%%%%%%%%
        GCparam = HISparam.GCparam;
        GCparam.Ctrl = 'dynamic'; % dcGC-FB
        tic
        disp('##### GCFB for level estimation (Excitation Pattern) #####');
        [cGCout, pGCout, GCparam, GCresp] = GCFBv209(SndCal,GCparam);
        tElpsGC = toc
        ExcitPatternRmsPwr =  mean(cGCout.^2,2)'; % row vector
        ExcitPatterndB1 =  10*log10(ExcitPatternRmsPwr)+ LeveldB_MHC;

        [valMax,numMax] = max(ExcitPatterndB1);
        
        %%%%%%%% Level %%%%%%%%%
        if LeveldB == SPLlist(1), 
            ExcitPatternBiasdB(SwSndIn) = SPLlist(1) - valMax;
        end;
        if SwSndIn == 1, 
            ExcitPatterndB_NH(nSPL,1:GCparam.NumCh) =  ...
                     ExcitPatterndB1 + ExcitPatternBiasdB(SwSndIn);
            ExcitPatternMaxdB_NH(nSPL) = valMax + ExcitPatternBiasdB(SwSndIn);
            ExcitPatternNumMaxdB_NH(nSPL) = numMax;
        else
            ExcitPatterndB_simHI(nSPL,1:GCparam.NumCh) =  ...
                     ExcitPatterndB1 + ExcitPatternBiasdB(SwSndIn);
            ExcitPatternMaxdB_simHI(nSPL) = valMax + ExcitPatternBiasdB(SwSndIn);
            ExcitPatternNumMaxdB_simHI(nSPL) = numMax;
        end;

    end;
    
    [LeveldB_SndIn; ExcitPatternMaxdB_NH;  ...
     LeveldB_SndHIS; ExcitPatternMaxdB_simHI]
    plot(1:GCparam.NumCh,ExcitPatterndB_NH(nSPL,:),'-', ...
         1:GCparam.NumCh,ExcitPatterndB_simHI(nSPL,:),'--');
    xlabel('Number of Channel');
    ylabel('Exictation Pattern (dB)');
    grid on;
    drawnow
 end;

 %% calculate SPL&HL at Threshold level %%
    nRangeLine = 5:12
    [pp_NH]    = polyfit(LeveldB_SndIn(8:end), ExcitPatternMaxdB_NH(8:end),1);
    LeveldB_AbsThresh_NH(nfc) = (LeveldB_InternalThrsh - pp_NH(2))/pp_NH(1);
    HLdB_AbsThresh_NH(nfc) = SPL2HL(fc,LeveldB_AbsThresh_NH(nfc));
    [pp_simHI] = polyfit(LeveldB_SndIn(4:8),ExcitPatternMaxdB_simHI(4:8),1);
    LeveldB_AbsThresh_simHI(nfc) = (LeveldB_InternalThrsh - pp_simHI(2))/pp_simHI(1);
    HLdB_AbsThresh_simHI(nfc) = SPL2HL(fc,LeveldB_AbsThresh_simHI(nfc));
 
    save(NameRslt);
 end; % if exist(NameRslt) == 1,
 
 
 %%%%%  Plot %%%% see ShowIO_NHHIInv_Scheme.m %%%
  figure(2)
    RangePlot = [0 105];
    plot(LeveldB_SndIn, LeveldB_SndHIS,'ks-.',...
         LeveldB_SndIn, ExcitPatternMaxdB_NH, 'bo-', ...
         LeveldB_SndIn, ExcitPatternMaxdB_simHI, 'r*-', ...
         RangePlot,LeveldB_InternalThrsh*[1 1],'k:', ...
         RangePlot,RangePlot,'k:');
    hold on;
    hp = plot(LeveldB_AbsThresh_NH(nfc),    LeveldB_InternalThrsh,'mv', ...
              LeveldB_AbsThresh_simHI(nfc), LeveldB_InternalThrsh,'mv');
    set(hp,'MarkerSize',10);
    % from ShowIO_NHHIInv_Scheme.m
    axis([RangePlot RangePlot]);
    hold on;
    set(gca,'XTick',[0:10:100]);
    set(gca,'YTick',[0:10:100]);
    set(gca,'YTickLabel',[0:10:100]);
    xlabel('Input Level (SPL, dB)');
    ylabel('Output Level (SPL, dB)');

    for valSPL = [0:10:100]
        text(106,valSPL, int2str(valSPL-50));
    end;
    ht = text(115,53,'Internal Level re. Threshold (dB)');
    set(ht,'Rotation',90);
    set(ht,'HorizontalAlignment','center');
    title(['IO function : ' int2str(fcList(nfc)) 'Hz']);

    
    % Labels
    % legend('Inverse compression','NH compression','HI simulation','Location','southeast');

    ht = text(30,72,'Normal Hearing'); 
    set(ht,'Rotation',20)
    text(79,47,'Threshold');
    ht = text(LeveldB_AbsThresh_NH(nfc), LeveldB_InternalThrsh-4, ...
        ['HL ' int2str(HLdB_AbsThresh_NH(nfc)) 'dB']);
    set(ht,'Rotation',-90)
    
    ht = text(40,48,'Simulated HI');
    set(ht,'Rotation',42)
    
    ht = text(LeveldB_AbsThresh_simHI(nfc), LeveldB_InternalThrsh-4, ...
        ['HL ' int2str(HLdB_AbsThresh_simHI(nfc)) 'dB']);
    set(ht,'Rotation',-90)
  
    ht = text(45,16,'Inverse Compression');
    set(ht,'Rotation',50);
    
    hold off;
    
  
  
  printi(3,0,0.8);
  print('-depsc', NameRslt);

  drawnow;
  


end; % for nfc = 1:length(fcList);

%%
figure(1); clf;
plot(1:length(fcList), -HLdB_AbsThresh_NH,'bo-',...
     1:length(fcList), -HLdB_AbsThresh_simHI,'r*-', ...
     [0 length(fcList)+1], [0 0], 'k-');
xlabel('Frequency (Hz)');
ylabel('Hearing Level (dB)');
set(gca,'XTick',1:length(fcList));
set(gca,'XTickLabel',num2str(fcList(:)));
Ytick1 = -80:10:10;
set(gca,'YTick',Ytick1);
set(gca,'YTickLabel',num2str(-Ytick1(:)));
axis([0.5, length(fcList)+0.5, -80, 15]);
title('Audiogram');
text(3,-10,'Normal Hearing');
text(3,-35,'Simulated HI');
grid on;

NameRsltAGM = ['~/tmp/IOfunc_GCFBwHIsim_AudioGram'];
 printi(3,0,0.8);
 print('-depsc', NameRsltAGM);
  save(NameRsltAGM);


    
    
%%%% Return %%%
return



