%
%  Exec CalFBspecSynSnd
%  Toshio IRINO
%  Created:    3 Nov 2011 (from ShowGCFB_IOfunc.m)
%  Modified:   3 Nov 2011 (smoothSpec)
%  Modified:   6 Nov 2011 (Stage1 & Stage 2)
%  Modified:  11 Nov 2011 (Stage1 & Stage 2)
%  Modified:  16 Jan 2012 
%  Modified:  17 Jan 2012 (Control changed)
%  Modified:  26 Jan 2012 (FBparam)
%  Modified:  27 Jan 2012 (nFc, nSPL)
%  Modified:  21 Feb 2012 (nFc, nSPL)
%  Modified:  22 Feb 2012 (nFc, nSPL)
%  Modified:  22 Feb 2012 (Rslt.Level.FcList , SndSPLLst)
%
%
clear
DirData = [getenv('HOME') '/Data/HIsimulator/'];
NameHeadSnd  = ['SynSnd_'];
NameHeadIO   = ['RsltIO_'];
  
SwSaveSynSnd = 0;

StrSnd = 'mis_4a02'; SpVct = [1 4 1 2];
StrSnd = 'Sin';
if strcmp(StrSnd,'Sin')
    FcList = [250 500 1000 2000 4000 8000];
else
    FcList = [1]; % dummy value
    SwSaveSynSnd = 1;
end;

%SndSPLList = [100: -10: 30];
SndSPLList = [100: -10: 10];
StrFBList = {'NormalHearing', 'LinearFB', 'InvCompression', ...
                 'HIsimulate1', 'InvCompHIsim1' };

SwFBProcessList = [ 1 0; 2 0; 3 0; 3 1;   4 0; 5 0; 5 1];
nPrList = [1:7];
%nPrList = [1 2 3 4 6];
%nPrList = [5 7];
%nPrList = [2];

StrSfx = [];
% Calibration setting by sin
SwCalib = 0;
if SwCalib==1 % when calibration at 2000Hz 100dB  (used to be 1000Hz 100 dB)
    StrSnd = 'Sin';
    SndSPLList = [100]; % for Equalization of Snd/SynSnd Level using sin.
    %FcList = [1000];  % It is better to compenstate at 2000 Hz
    FcList = [2000];   % ELC = -0.9dB
    nPrList = [1:7]; %[4 5 7]; %
    StrSfx = '_Calib';
end;

Rslt.Level.FcList = FcList(:);
Rslt.Level.SndSPLList = SndSPLList;

%% Start 
tic;
for nPr = nPrList
    figure(1);clf; figure(2);clf; 
    SwFBProcess = SwFBProcessList(nPr,:);
    SwFBProcess = SwFBProcess(SwFBProcess>0);
    StrFBProcess = char(StrFBList(SwFBProcess(1)));
    if length(SwFBProcess) == 2,
        StrFBProcess = [StrFBProcess '-' char(StrFBList(SwFBProcess(2)))];
    end;
    NameIO = [NameHeadIO StrSnd '_' StrFBProcess StrSfx];
    NameFullIO = [DirData NameIO];
    disp(['******** '  NameIO ' **********']);
  
    if exist([NameFullIO '.mat']) > 0 & ~(length(FcList) == 1  & FcList > 1)       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp(['Loading data']);
        load([NameFullIO '.mat']);
    else
        
      for nFc = 1:length(FcList)
        for nSPL = 1:length(SndSPLList)
           figure(1); clf;

            if strcmp(StrSnd,'Sin') 
                fs = 48000;
                % Tsnd = 0.2; % 200ms
                Tsnd = 0.1; % 200ms
                LenSnd = Tsnd*fs;
                ts = [0:(LenSnd-1)]/fs;
                Snd = sin(2*pi*FcList(nFc)*ts);

                LenTaper = 0.005*fs; % 5 ms Taper
                Win = TaperWindow(LenSnd,'han',LenTaper);
                Snd = Win.*Snd;
                StrFL = [int2str(FcList(nFc)) 'Hz_' int2str(SndSPLList(nSPL)) 'dB'];

            elseif strcmp(StrSnd(1:3),'mis') 
                [Snd,   fs, NameFile]  = LoadFW03(SpVct(1),SpVct(2),SpVct(3),SpVct(4)); 
                Snd = Snd(:)';
                %sound(Snd,fs);
                StrSnd = NameFile;
                LenSnd = length(Snd);
                StrFL = [int2str(SndSPLList(nSPL)) 'dB'];
            else
                 error('Specify StrSnd');
            end;
    
            InSnd = Eqlz2MeddisHCLevel(Snd,SndSPLList(nSPL));

            for nst = 1: length(SwFBProcess)  %%%%%%%
                 StrFB = char(StrFBList(SwFBProcess(nst)));
                 disp(['*********** '  StrFBProcess ' ******************']);
                 disp(['* Stage ' int2str(nst) ' : ' StrFB]);
        
                 [FBspec, SynSnd, FBparam]  = CalFBspecSynSnd(InSnd,StrFB,fs);

                if nst == 1,
                    Rslt.Level.InSnddB(nFc,nSPL)  = FBparam.Level.InSnddB; % input level
                    InSnd = SynSnd; %change the input sound for SwFBProcess==2
                end;
                
                if nst == length(SwFBProcess) % 1 or 2
                    % FBparam
                    Rslt.Level.SynSnddB(nFc,nSPL)         = FBparam.Level.SynSnddB;
                    Rslt.Level.FBspecPeakAmpdB(nFc,nSPL)  = FBparam.Level.FBspecPeakAmpdB;
                    Rslt.Level.FBspecTotalPwrdB(nFc,nSPL) = FBparam.Level.FBspecTotalPwrdB;
                    Rslt.Param(nFc,nSPL).FBparam          = FBparam;                    
                      
                    if nFc == 1 & nSPL == 1,
                        [NumCh LenSpec] = size(FBspec.AmpSpec); 
                        Rslt.FBampSpec = zeros(NumCh,LenSpec,length(FcList),length(SndSPLList));
                    end;
                    Rslt.FBampSpec(1:NumCh,1:LenSpec,nFc,nSPL) = FBspec.AmpSpec;

                end;
                
            end; % for nst = 1: length(SwFBProcess) %%%%%%%

            %% SaveSound
            if SwSaveSynSnd == 1,
              if nSPL == 1, MaxSynSnd = max(abs(SynSnd)); end;
              SynSnd = 0.8/MaxSynSnd * SynSnd;
              wavwrite(SynSnd, fs, 24, [DirData  NameHeadSnd StrSnd '_' StrFBProcess '_' StrFL ]);
            end;
            %sound(SynSnd,fs);
    
        end;    %   for nSPL = 1:length(SndSPLList)

  
        % for equalization 11 Nov. 2011
        Rslt.Level.DiffInOut_SynSnddB = FBparam.Level.SynSnddB-FBparam.Level.InSnddB;
        Rslt.Level.DiffInOut_FBspecPeakAmpdB  ...
              = FBparam.Level.FBspecPeakAmpdB + FBparam.Level.FBspecAmp_ThrshdB ...
              - FBparam.Level.InSnddB;
        Rslt.Level.DiffInOut_FBspecTotalPwrdB ...
              = FBparam.Level.FBspecTotalPwrdB + FBparam.Level.FBspecAmp_ThrshdB ...
              - FBparam.Level.InSnddB;
        Rslt.Level
        
        if SwCalib == 1,
            disp('Calibration : Return to continue > ');
            pause
        end;

        figure(2); 
        if length(FcList) > 1
            subplot(3,2,nFc);
        end;
        bias = FBparam.Level.FBspecAmp_ThrshdB;
        h = plot(Rslt.Level.InSnddB(nFc,:), Rslt.Level.FBspecPeakAmpdB(nFc,:)+bias, 'x-', ...
                 Rslt.Level.InSnddB(nFc,:), Rslt.Level.SynSnddB(nFc,:), 'o-', ...
                [0 110], [0 110],'g--');
        legend('FBSpec','SynSnd','Location','Best');
        axis([10 105 10 105]);
        xlabel('Input Level (dB)');
        ylabel('Output Level (dB)');
       title(['IO function for "' StrFBProcess '" [' int2str(FcList(nFc)) ' Hz]']);

      end; %for nFc = 1:length(FcList)

      printi(3,0,0.8);
      str = ['print -depsc ' NameFullIO ];
      eval(str);
      save(NameFullIO,'Rslt');
    end; %  if exist(NameFullIOMat) > 0,  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    [LenFreqList LenSPLList] = size(Rslt.Level.SynSnddB);
     for PltType = 1:2   
      figure(2+PltType); clf
      if PltType == 1 StrPltType = 'SynSnd'; 
      else StrPltType = 'FBSpec'; 
      end;
        
      for nFc = 1:LenFreqList
        subplot(3,2,nFc);
        if PltType == 1,
            h = plot(Rslt.Level.InSnddB(nFc,:), Rslt.Level.SynSnddB(nFc,:), 'o-', ...
                   [0 110], [0 110],'g--');
        else
            bias = Rslt.Param(1,1).FBparam.Level.FBspecAmp_ThrshdB;
            h = plot(Rslt.Level.InSnddB(nFc,:), Rslt.Level.FBspecPeakAmpdB(nFc,:)+bias, 'o-', ...
                   [0 110], [0 110],'g--');
        end;   
        axis([min(SndSPLList)-5 max(SndSPLList)+5  min(SndSPLList)-5 max(SndSPLList)+5]);
        set(gca,'XTick',[10:10:100]);
        set(gca,'YTick',[10:10:100]);
        text(80,35,[ int2str(FcList(nFc)) ' Hz']);
        xlabel('Input Level (dB)');
        ylabel('Output Level (dB)');
        title(['IO function for "' StrFBProcess '" [' int2str(FcList(nFc)) ' Hz]']);
      end;
    
      ReSubPlot(3,2,0);
      printi(3,0,0.8);
      str = ['print -depsc ' NameFullIO '_' StrPltType];
      eval(str);
    end;
     disp(' ');
     toc
     disp(' ');
     disp(' ');
          
end; % for nPr = nPrList
  
return


%% for modification
%cmpnVal1 = 3;
%set(h(1),'YData', PlotFBspecdB(nFc,:) + cmpnVal1);
%cmpnVal2 = 0;
%set(h(2),'YData', PlotSynSnddB(nFc,:) + cmpnVal2);


