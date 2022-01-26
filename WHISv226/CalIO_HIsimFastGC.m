%
%      Calculate IO function of Fast Hearing Impairment Simulator using GCFBv209
%      IRINO T.
%      Created:    17 Dec 2013 from testHIsimFastGC.m
%      Modified:   17 Dec 2013
%      Modified:   22 Dec 2013 (GCFBv209 renamed)
%      Modified:   26 Dec 2013 (renamed to 'CmpnstAt100dB' from 'Offset')
%      Modified:    5 Feb 2014 (fcList 250*2.^(0:5) --> FaudgramList  125 250 ...)
%
%
clear
close all

fs = 48000;
Tsnd = 0.1;

FaudgramList = 125*2.^(0:6);

for nFag = 1:length(FaudgramList);
 Fag   = FaudgramList(nFag);
 SndIn = sin(2*pi*Fag*(0:Tsnd*fs-1)/fs);
 SndIn = 0.9*TaperWindow(Tsnd*fs,'han',0.01*fs).*SndIn;  % the same results with 5ms taper
 %sound(SndIn,fs)

 [TestVal, AmpdB] = Eqlz2MeddisHCLevel(1,0);
 LeveldB_MHC = AmpdB(3)
 %% 

 SPLlist = [100:-10:10];
  
 for nSPL = 1:length(SPLlist)
    LeveldB = SPLlist(nSPL);
    [SndEqM, AmpdB] = Eqlz2MeddisHCLevel(SndIn,LeveldB);
    Snd = SndEqM(:)';

    LeveldB_SndIn(nFag,nSPL)  = 10*log10(mean(Snd.^2)) + LeveldB_MHC;
    
    %%%%%%%% Main %%%%%%%%
    figure(1)
    HISparam.fs = fs;
    HISparam.DegreeCompression = 0; % default NO compression
    %HISparam.DegreeCompression = 1; % full compression
    [SndMod, HISparam] = HIsimFastGC(Snd, HISparam);

    % Do not specify RatioInvCompression for control.
    %HISparam.RatioInvCompression = 1; % default
    %HISparam.RatioInvCompression = 0.7;
    %HISparam.RatioInvCompression = 0.5;
    %HISparam.RatioInvCompression = 1/3;
    %HISparam.RatioInvCompression = 0;
    %%%%%%%%%%%%%%%%%%%%%%%

    val1 = 10*log10(mean(SndMod.^2)) + LeveldB_MHC;
    if nSPL == 1, CmpnstAt100dB(nFag) = LeveldB_SndIn(nFag,nSPL)-val1;  end;
    CmpnstAt100dB
    LeveldB_SndMod0(nFag,nSPL) = val1;
    LeveldB_SndMod1(nFag,nSPL) = val1 + CmpnstAt100dB(nFag);
    LeveldB_SndMod2(nFag,nSPL) = val1 + CmpnstAt100dB(1);
 end;

 figure(2)
 plot(LeveldB_SndIn(nFag,:), LeveldB_SndMod1(nFag,:),0:105,0:105,':')
 hold on;
 grid on;
 axis([0 115 0 115]);
 

end;
 
%%
figure(3)
 subplot(3,1,1)
 plot(LeveldB_SndIn', LeveldB_SndMod2',0:115,0:115,':')
 grid on;
 axis([0 115 0 115]);
 legend(num2str(FaudgramList'),'location','best');
 xlabel('Input level (dB)');
 ylabel('Output level (dB)');
 
 subplot(3,1,2)
 plot(LeveldB_SndIn', LeveldB_SndMod0',0:115,0:115,':')
 grid on;
 axis([0 115 0 115]);
 legend(num2str(FaudgramList'),'location','best');
 xlabel('Input level (dB)');
 ylabel('Output level (dB)');
 
 subplot(3,1,3)
 plot(1:length(FaudgramList),CmpnstAt100dB,'*-'); 
 set(gca,'XTick', [1:length(FaudgramList)])
 set(gca,'XTickLabel', num2str(FaudgramList'))
 grid on;
 xlabel('frequency (Hz)');
 ylabel('Offset (dB)');


 printi(2,0);
 str = 'print -depsc ~/tmp/IOfunc_HIsimFastGC';
 str = 'print -dpng -r300 ~/tmp/IOfunc_HIsimFastGC_InvFull';
 eval(str);
 
% for nFag = 1:length(FaudgramList);
% Fag = FaudgramList(nFag);
% [pwr frq CrctdB] = OutMidCrct('ELC',1000);
% [dummy nf] = min(abs(frq-Fag));
% ELCcrctdB(nFag) = CrctdB(nf);
% end;
% grid on;
% ,1:length(FaudgramList),ELCcrctdB-25,'--')
 
