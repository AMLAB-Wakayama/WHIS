%
%  Calculate Filterbank spectrogram & synthetic sounds
%  Toshio IRINO
%  Created:    2 Nov 2011 (from ShowGCFB_IOfunc.m)
%  Modified:   3 Nov 2011 (smoothSpec)
%  Modified:   4 Nov 2011 (GCparam.frat in InvCompression, [100,12000])
%  Modified:   6 Nov 2011 
%  Modified:  11 Nov 2011 
%  Modified:  16 Jan 2011 (compensation@100dB &'InvCompHIsim1')
%  Modified:  17 Jan 2012 (Control changed)
%  Modified:  19 Jan 2012 (CmpnstdBTable  changed)
%  Modified:  24 Jan 2012 ( CmpnstdB = CalCmpnst_Compression CmpnstdBTable  changed)
%  Modified:  25 Jan 2012 ( Frequency dependency & FBpwrSpec compenstation  )
%  Modified:  26 Jan 2012 ( Complete change overall. argument : FBparam)
%  Modified:  27 Jan 2012 ( Complete change overall. argument : FBparam)
%  Modified:  10 Feb 2012 ( clear heavy data)
%  Modified:  20 Feb 2012 ( FBpwrSpec --> FBspec.PwrSpec FBspec.AmpSpec)
%  Modified:  23 Feb 2012 ( debug InvCompHIsim1, SynSnddB_Cmpnst -> SynSnddB_CmpnstdB renamed)
%  Modified:    4 Nov 2021 (FreeField from GCFBv231 --- Currently error  return)
%
%  function [FBspec, SynSnd, GCparam] = CalFBspecSynSnd(Snd,StrFB,fs);
%  INPUT:  Snd  : sound data ( <--- Equalized by Meddis Hair Cell Level)
%          StrFB: FB selection
%               StrFBList = {NormalHearing', 'LinearFB', 'InvCompression', ...
%                           'HIsimulate1', 'InvCompHIsim1', 'Control_frat'};
%          fs : Sampling frequncy
%          CtrlParam: control param
%
%  OUTPUT: FBampSpec: Amplituce Smoothed Spectrogram
%          SynSnd: Synthetic sound from the FB
%          FBparam: FBparam
%
function [FBspec, SynSnd, FBparam] = CalFBspecSynSnd(Snd,StrFB,fs,CtrlParam)

    StrFBList = {'NormalHearing', 'LinearFB', 'InvCompression', ...
                 'HIsimulate1', 'InvCompHIsim1', 'Control_frat' };

    if nargin < 3, help(mfilename);  StrFB = 'Error'; end;

    
    %% default
    GCparam.fs     = fs;
    GCparam.NumCh  = 100;
    GCparam.FRange = [100, 12000];
    GCparam.OutMidCrct = 'ELC';  
    % %  Modified:    4 Nov 2021 (FreeField from GCFBv231 --- Currently error  return)
    error('FreeField was introduced. ---- Check the whole programs for consistency.')
    GCparam.Ctrl   = 'dynamic';
    GCparam.frat_NormalHearing = [ 0.4660, 0;   0.0109, 0];
    GCparam.WeightFBout = ones(GCparam.NumCh,1);
    GCparam.LvlEst.DecayHL_NH = 0.5;  % default value for NH
    GCparam.LvlEst.DecayHL_InvCompSyn = 10;  % For Synthesis of inverse compression
    GCparam.frat_LevelCenter = 60; % default for NH
    
    % Level setting
    FBparam.Level.FBspecAmp_ThrshdB = 50;         % Threshold level 50dBSPL--> amp =1
    FBparam.Level.FBspecAmp_RefLineardB   = 100;  % Ref Linearity Level  100 dB SPL
    FBparam.Level.FBspecAmp_DynamicRangedB ...    % = 316   @ NH 2kHz 100 dB
        = FBparam.Level.FBspecAmp_RefLineardB - FBparam.Level.FBspecAmp_ThrshdB;
    FBparam.Level.FBspecAmp_MaxAmp  = 10^(FBparam.Level.FBspecAmp_DynamicRangedB/20); 
    FBparam.Level.FBspecAmp_NH2kHz100dB = 168.2;  % <-- NH 2kHz 100 dB value

    FBparam.Level.ConductiveLossdB = 0;
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% selection of FB 
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(StrFB,char(StrFBList(1)))   %'NormalHearing'
       %% %%% GCFB for NH %%%%
       GCparam.frat = GCparam.frat_NormalHearing;
       FBparam.Level.SynSnddB_CmpnstdB = CalCmpnst_Compression(GCparam.frat(2,1), GCparam.frat_LevelCenter);
       FBparam.Level.FBspecAmp_CmpnstdB = 0; % This is the reference
       
    elseif strcmp(StrFB,char(StrFBList(2)))  %'LinearFB'
       %%  Linear GCFB
       GCparam.Ctrl   = 'static';
       GCparam.frat = GCparam.frat_NormalHearing;
        %  FBparam.Level.SynSnddB_CmpnstdB = -15.14;  % Hand Eqlz at 100dB sin-1kHz-100 ms (IT 11 Nov. 2011)
       FBparam.Level.SynSnddB_CmpnstdB  = -14; % equalized at 2000Hz 100dB
       FBparam.Level.FBspecAmp_CmpnstdB = -23.8;
       
    elseif strcmp(StrFB,char(StrFBList(3)))  %  'InvCompression'
       %% Complete Inverse Compression
       GCparam.frat_LevelCenter =  65;
       GCparam.frat_InvCompression = zeros(2,2);
       GCparam.frat_InvCompression(2,1) = -0.016;  % recommendation = -1.47*0.0109
       GCparam.frat_InvCompression(1,1) = ...
               GCparam.frat_NormalHearing(1,1)  ...
             +(GCparam.frat_NormalHearing(2,1) - GCparam.frat_InvCompression(2,1)) ...
              *GCparam.frat_LevelCenter;
          
       % set
       GCparam.frat = GCparam.frat_InvCompression;
       FBparam.Level.SynSnddB_CmpnstdB = CalCmpnst_Compression(GCparam.frat(2,1), GCparam.frat_LevelCenter);
       FBparam.Level.FBspecAmp_CmpnstdB = -65.5;
      
    elseif strcmp(StrFB,char(StrFBList(4)))  % 'HIsimulate1'
       %% Hearing Impaired Simulation #1
       GCparam.frat_HIsimulate1 = [0.4660, 0;  0.005, -0.002];
       
       % set
       GCparam.frat =  GCparam.frat_HIsimulate1;
        % FBparam.Level.SynSnddB_CmpnstdB = CalCmpnst_Compression(GCparam.frat(2,1), GCparam.frat_LevelCenter);
       FBparam.Level.SynSnddB_CmpnstdB  = -1.0;  % by hand
       FBparam.Level.FBspecAmp_CmpnstdB = -10.5;  
       
        
    elseif strcmp(StrFB,char(StrFBList(5)))  % 'InvCompHIsim1'
       %% Inverse of Hearing Impaired Simulation #1       
       GCparam.frat_LevelCenter =  60;
       GCparam.frat_InvCompHIsim1(2,1) = -0.005;  % By Sakaguchi Sotsuron 
       GCparam.frat_InvCompHIsim1(2,2) = -0.004;
       GCparam.frat_InvCompHIsim1(1,2) =  0; %
       GCparam.frat_InvCompHIsim1(1,1) = ...
               GCparam.frat_NormalHearing(1,1)  ...
             +(GCparam.frat_NormalHearing(2,1) - GCparam.frat_InvCompHIsim1(2,1)) ...
              *GCparam.frat_LevelCenter;
      
       % set
       GCparam.frat = GCparam.frat_InvCompHIsim1;
       % FBparam.Level.SynSnddB_CmpnstdB =  -31.2; % magic number for level compenstation
       % FBparam.Level.SynSnddB_CmpnstdB = CalCmpnst_Compression(GCparam.frat(2,1), GCparam.frat_LevelCenter);

       FBparam.Level.SynSnddB_CmpnstdB  = -36.5; % control by hand
       FBparam.Level.FBspecAmp_CmpnstdB = -46.7;

       
    elseif strcmp(StrFB,char(StrFBList(6))) % 'Control_frat' 
       %% controlling frat from main
       GCparam.frat_LevelCenter = CtrlParam.frat_LevelCenter; 
       GCparam.frat_Control     = CtrlParam.frat_Mtrx; % 2*2 matrix
       GCparam.frat_Control(1,1) = ...
              GCparam.frat_NormalHearing(1,1)  ...
            +(GCparam.frat_NormalHearing(2,1) - GCparam.frat_Control(2,1)) ...
             *GCparam.frat_LevelCenter;
         
         disp(GCparam.frat_Control)
          
       % set
       GCparam.frat = GCparam.frat_Control;
       FBparam.Level.SynSnddB_CmpnstdB = CalCmpnst_Compression(GCparam.frat(2,1), GCparam.frat_LevelCenter);
       FBparam.Level.FBspecAmp_CmpnstdB = 0; % it depends on the param
       
    else 

       help(mfilename);
       error(['*** Argument setting (StrFB) in "' mfilename '" ***']);
    end;

    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Filterbank (FB) calculation
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    disp(['*** Calculation of ' StrFB ' ***']);
       
    if GCparam.frat(2,1) > 0 % for Analysis filterbank. 
        GCparam.LvlEst.DecayHL = GCparam.LvlEst.DecayHL_NH; 
        FBparam.SwWeightFBout = 0; % No weight function when analysis
    else % for Synthesis filterbank
        GCparam.LvlEst.DecayHL = GCparam.LvlEst.DecayHL_InvCompSyn; 
        FBparam.SwWeightFBout = 1; % With weight function when analysis
    end;
    
    %% GC
    Tsnd = length(Snd)/fs;
    tic
    [cGCout, pGCout, GCparam, GCresp] = GCFBv207(Snd,GCparam);
    tm = toc;
    disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' ...
            num2str(tm/Tsnd,4) ' times RealTime.']);

    NumNaN = find(isnan(cGCout) == 1);
    if length(NumNaN) > 0
        warning('Something Wrong with SynSnd. NaN.');
        warning('Set cGCout(NumNaN) = zeros; ');
        cGCout(NumNaN) = zeros(size(NumNaN)); 
    end;
    
    
    %% Power Spectrogram
    FBparam.fs = fs;
    cGCpwr = cGCout.^2 / 10^(FBparam.Level.ConductiveLossdB/10);
    [FBpwrSpec, FBparam] = CalSmoothSpec(cGCpwr, FBparam); 
    

    amp1 = 10^(FBparam.Level.FBspecAmp_CmpnstdB/20) / FBparam.Level.FBspecAmp_NH2kHz100dB*FBparam.Level.FBspecAmp_MaxAmp;
    FBspec.AmpSpec = amp1 * sqrt(FBpwrSpec);
    FBspec.AmpCompensation = amp1;
    
    
    subplot(3,1,1)
    image(FBparam.temporalPositions,1:GCparam.NumCh,FBspec.AmpSpec/4);
    set(gca,'YDir','normal');
    xlabel('Time');
    ylabel('Channel');
    

    %% Synth Sound
    PhsAlgnGCout  =  CmpnstERBFilt(cGCout,GCresp.Fr1*0.9,fs);  % phase alignment Fp2/Fr1 = 0.85~0.9
    if  FBparam.SwWeightFBout == 1; % Lift up low and high freq. component
        disp('--- Freq. Weight function applied.');
        FBparam.WeightFBout = SetWeightGCout(GCparam,GCresp); % Lift up low and high freq. component
        PhsAlgnGCout  = (FBparam.WeightFBout * ones(1,length(PhsAlgnGCout))).* PhsAlgnGCout;
    end;
    SynSnd = sum(PhsAlgnGCout) * 10^(FBparam.Level.SynSnddB_CmpnstdB/20); % level compensation here
    
    
    %% Inverse filter of ELC
    InvCmpnOutMid = OutMidCrctFilt(GCparam.OutMidCrct,fs,0,1); % 1) inverse filter of ELC
    LenCmpn = (length(InvCmpnOutMid)-1)/2;
    SynSnd1 = [SynSnd, zeros(1,LenCmpn)]; % compenstaion of delay
    SynSnd1 = filter(InvCmpnOutMid,1,SynSnd1);
    SynSnd  = SynSnd1(LenCmpn+1:end);
    % length(SynSnd), length(SynSnd1)


    %% plot
    subplot(3,1,2)
    ts = [0:(length(Snd)-1)]/fs;
    plot(ts,Snd)
    ax = axis;
    axis([0 max(ts) ax(3:4)]);
    subplot(3,1,3)
    plot(ts,SynSnd);
    ax = axis;
    axis([0 max(ts) ax(3:4)]);
        
    %% Level in dB

    FBparam.Level.BiasdBMdsHCL= -20*log10(Eqlz2MeddisHCLevel(1,0));
    FBparam.Level.InSnddB     =  10*log10(mean(Snd.^2))          + FBparam.Level.BiasdBMdsHCL;
    FBparam.Level.SynSnddB    =  10*log10(mean(SynSnd.^2))       + FBparam.Level.BiasdBMdsHCL;
    % No use : Reference is uncertain in this case
    % FBparam.Level.FBspecdB    =  10*log10(mean(mean(FBspec.PwrSpec))) + FBparam.Level.BiasdBMdsHCL;
    % FBparam.Level.cGCoutdB    =  10*log10(mean(mean(cGCout.^2))) + FBparam.Level.BiasdBMdsHCL + FBparam.Level.FBspecdB_Cmpnst;
    FBparam.Level.FBspecPeakAmpdB =  20*log10(max(max(FBspec.AmpSpec))); % independent from FBparam.Level.BiasdBMdsHCL
    FBparam.Level.FBspecTotalPwrdB   =  10*log10(mean(mean(FBspec.AmpSpec.^2)));

    %% param set
    FBparam.GCparam = GCparam;
    FBparam.GCresp  = GCresp;
    FBparam.GCresp.Fr2  = []; % clear the heavy data
    FBparam.GCresp.fratVal  = []; % clear the heavy data
    FBparam.GCresp.LvldB  = []; % clear the heavy data

    %%
    
return;




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions for Compensation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compensation value derived from 1000Hz 100dB  
%    
function CmpnstdB = CalCmpnst_Compression(frat_Coef21, frat_LevelCenter)

xIn = frat_Coef21;
yIn = frat_LevelCenter;

%% Table 

frat_Coef21TableList = [0.020:-0.002:-0.020];  % negative: inverse compression
LevelCenterTableList = [50:5:90]; 

x = frat_Coef21TableList;
y = LevelCenterTableList;
%Rw = GCparam.frat_CenterLevel;

% table by Irino 26 Jan 2011 from Check_CmpnstVal_Param 
% 1000Hz 100dB
% --> 2000 Hz 100 dB
CmpnstdBTable01 = [
    6.4974    6.3759    6.1530    5.7453    5.0308    3.8714    2.1118   -0.5153   -4.3573   -9.4221  -15.1410
    9.1329    8.4461    7.6296    6.6157    5.3217    3.6559    1.5160   -1.3011   -5.1111  -10.0470  -15.7779
   11.6411   10.4394    9.0683    7.4739    5.6085    3.4374    0.8887   -2.1754   -6.0105  -10.8118  -16.4456
   13.9441   12.3152   10.4433    8.3085    5.8932    3.2161    0.2353   -3.1207   -7.0229  -11.6581  -17.0265
   16.0831   14.0397   11.7429    9.1129    6.1762    2.9923   -0.4410   -4.1178   -8.1046  -12.5224  -17.4219
   17.9741   15.6482   12.9365    9.8854    6.4567    2.7660   -1.1347   -5.1450   -9.2055  -13.3305  -17.5896
   19.6274   17.0808   14.0549   10.6241    6.7340    2.5373   -1.8413   -6.1783  -10.2748  -14.0371  -17.6222
   20.9635   18.3067   15.0914   11.3153    7.0073    2.3065   -2.5561   -7.1957  -11.2481  -14.6596  -17.6376
   21.9942   19.3311   16.0093   11.9610    7.2755    2.0740   -3.2739   -8.1809  -12.1382  -15.2033  -17.6746
];
% valQ = -464.36; % original data from calculation
valQ = -45.00;  % arbitray value 
CmpnstdBTable02 = [
  -21.2070  -26.3816  -30.5742  -33.9425  -36.6558  -38.8649  -40.7717  -43.4133  -44.1802   valQ
  -22.1956  -28.0162  -32.9683  -37.1160  -40.6031  -43.5596  -46.1045  -48.4187  -51.3307  -54.6508
  -23.0132  -29.2958  -34.8605  -39.6260  -43.6693  -47.1002  -50.0344  -52.5696  -54.8611  -56.6005
  -23.4177  -29.7543  -35.5370  -40.5576  -44.7776  -48.3388  -51.3604  -53.8988  -56.0600  -57.9704
  -23.2200  -29.1510  -34.7619  -39.7686  -44.0413  -47.6463  -50.7043  -53.2895  -55.4750  -57.3420
  -22.5325  -27.6841  -32.8047  -37.6078  -41.8933  -45.5793  -48.7180  -51.3923  -53.6863  -55.6534
  -21.6162  -25.7840  -30.1302  -34.4701  -38.5933  -42.3275  -45.6064  -48.4415  -50.8764  -52.9754
  -20.7364  -23.9261  -27.2816  -30.8213  -34.4464  -37.9940  -41.3087  -44.2970  -46.9359  -49.2455
  -20.0908  -22.4091  -24.7995  -27.3532  -30.0873  -32.9712  -35.9196  -38.8227  -41.5685  -44.0863
];  

CmpnstdBTable = [CmpnstdBTable01, CmpnstdBTable02];


%% Table lookup
CmpnstdB = interp2(x,y,CmpnstdBTable,xIn,yIn);
   
if isnan(CmpnstdB) == 0,  % if it is within the range of table
  return;
end;
    
    
%% interporation
disp('-- Calculation of Least Squared function in CalCmpnst_Compression -- ')
CmpnstdB0 = CmpnstdB;

[xMsh, yMsh] = meshgrid(x, y); 
xVct = xMsh(:);
yVct = yMsh(:); 
LevelVct = CmpnstdBTable(:);

% Vandermonde matrix
% A1 = [ones(size(yVct)), yVct,  xVct,yVct.*xVct];
A = [ones(size(xVct)), xVct, xVct.^2, yVct, yVct.^2, xVct.*yVct];
%...
% Least mean squared
Coef = A\LevelVct;

%DiffInOutList(:,1:length(frat21B))
ErrorRMS = sqrt(mean(mean((A*Coef - LevelVct).^2)));

CmpnstdB = [ 1, xIn, xIn^2, yIn, yIn^2, xIn*yIn] * Coef;

[CmpnstdB CmpnstdB0 (CmpnstdB-CmpnstdB0) ErrorRMS]

return;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions for Compensation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function WeightVal = SetWeightGCout(GCparam,GCresp)
    %  FreqCmpnWeigh
    %  Irino T.
    %  Created:  25 Jan 2012
    %  Modified: 25 Jan 2012
    
  % result on frat = -0.016, LevelCenter = 65; from Sakaguchi 24 Jan 2012
  Fc = 125*2.^(0:0.5:7);
  valP = 42.3000; %orignal value --> it is exception.
  valP = -40;  % my guess
  SynSndCmpsntDiff = [ ...
  -30.6200  -41.9300  -47.3700  -51.4600  -52.2800  -53.1900  -52.2700  -52.6200  -51.2800  -51.8100 ...
  -52.0100  -48.4100  -44.8500  -41.2400   valP];
  
  SynSndCmpnstVal = 52 - SynSndCmpsntDiff;
  
  [bzBPF apBPF] = butter(1,[300 6000]/(GCparam.fs/2)); % simulated by 1st order BPF 
           % 1st order seems better for Mild inverse compression.
  [frsp freq] = freqz(bzBPF,apBPF,1024,GCparam.fs);
  FrspdB = 20*log10(abs(frsp));
  subplot(2,1,1)
  semilogx(Fc, SynSndCmpnstVal,'o-',freq,FrspdB,'r')
  grid on

  % p = polyfit(Fc,SynSndCmpsntDiff,4);
  %  WeightdB = polyval(p,freq2);
  subplot(2,1,2)
  freq2 = GCresp.Fr1*0.9; % simulated GCresp.Fp2'
  WeightdB = interp1(freq,-FrspdB,freq2,'linear'); %simulation of -FrspdB for weight
  WeightdB_Fc = interp1(freq,-FrspdB,Fc,'linear');
    
  semilogx(Fc,SynSndCmpnstVal,'o-',freq2,WeightdB,'r',Fc,SynSndCmpnstVal+WeightdB_Fc,'c')
  grid on
  drawnow
 
  WeightVal = 10.^(WeightdB/20);
  
return;
  
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% version history

    %% selection of FB
    %if strcmp(StrFB,char(StrFBList(1)))
       % %%% GCFB for NH %%%%
       %GCparam.frat = GCparam.frat_NormalHearing;
       %Level.SynSnddB_Cmpnst = 4.24 % Eqlz at 100dB sin-1kHz-200 ms (IT 11 Nov. 2011)
       %
       % Gparam.frat_LevelCenter = 50;
       % CalCmpnst_Compression(GCparam.frat_NormalHearing(2,1), Gparam.frat_LevelCenter)
       % it was about 5.5. +1.3 dB difference   (24 Jan 2012)
       %
      %Level.FBspecdB_Cmpnst = 37;   % magic number for level compenstation
        
    %elseif strcmp(StrFB,char(StrFBList(2)))
       % Linear GCFB
       %GCparam.Ctrl   = 'static';
       %Level.SynSnddB_Cmpnst = -14.3546; % OK 1kHz-sin-100ms (IT 11 Nov. 2011)
       %GCparam.frat = GCparam.frat_NormalHearing;
       %Level.SynSnddB_Cmpnst = -14.360;  % OK 1kHz-sin-200ms (IT 11 Nov. 2011)
       %Level.FBspecdB_Cmpnst = 18.7; % magic number for level compenstation
       
    %elseif strcmp(StrFB,char(StrFBList(3)))
       % Complete Inverse Compression
       % Original Values
       %  GCparam.GainRefdB = 50;
       %  GCparam.frat = [ 0.4660, 0;   0.0109, 0]
       %  frat = frat11+frat21*Lvl = frat11+frat21*50 + frat21*(Lvl-50)
       %  flip frat21 --> fratInv21 (= -frat21) for inverse
       %  fratInv = (frat11+frat21*50) + fratInv21*(Lvl-50)
       %          = (frat11+(frat21-fratInv21)*50) + fratInv21*Lvl
       %
       %  GCparam.LvlEst.DecayHL = 0.5;
       %
       % GCparam.frat = [ 1.011, 0;  -0.0109, 0]; NG
       % GCparam.frat = [ 1.556, 0;  -0.0109, 0]; % OK

       %GCparam.frat_InvComp21   = -0.016;  % recommendation = -1.47*0.0109
       %GCparam.frat_LevelCenter =  65;
       %NG GCparam.frat_InvComp21   = -0.014;
       % GCparam.frat_LevelCenter =  50;
       %GCparam.frat_InvComp11   = ...
       %           GCparam.frat_NormalHearing(1,1)  ...
       %         +(GCparam.frat_NormalHearing(2,1) - GCparam.frat_InvComp21) ...
       %         *GCparam.frat_LevelCenter;
       %GCparam.frat_InvCompression ...
       %    = [GCparam.frat_InvComp11 0;  GCparam.frat_InvComp21 0];
       %GCparam.frat = GCparam.frat_InvCompression;
%
       %GCparam.LvlEst.DecayHL = 10; 

       % Level.SynSnddB_Cmpnst = -36.11; % Eqlz at 100dB 1kHz-sin-200ms (IT 11 Nov. 2011)

       %Level.SynSnddB_Cmpnst = CalCmpnst_Compression(GCparam.frat_InvComp21, GCparam.frat_LevelCenter);
       %Level.FBspecdB_Cmpnst =  -22.8; % magic number for FBspec level compenstation
     
        
    %elseif strcmp(StrFB,char(StrFBList(4)))
     %  GCparam.frat_HIsimulate1 = [0.4660, 0;  0.005, -0.002];
     %  GCparam.frat =  GCparam.frat_HIsimulate1;
       
     %  Level.SynSnddB_Cmpnst =  -1.0; % magic number for level compenstation
     %  Level.FBspecdB_Cmpnst =  32.4; % magic number for level compenstation

       
       
       % Vector represenation would be necessary! --> GCFBv210
        % HIsimulate #1
       % Ef = Freq2ERB([100 500 1000 2000 4000 6000  8000])/Freq2ERB(1000) 
       % Ef = [0.2157 0.6892 1.0000 1.3542 1.7353 1.9657 2.1313]
       % 
       %  GCparam.frat_NormalHearing = [ 0.4660, 0;   0.0109, 0];
       %  0.0120 - Ef*0.003 = 
       %  [0.0114    0.0099    0.0090    0.0079    0.0068    0.0061  0.0056]
       % GCparam.frat_HIsimulate1 = [0.4660, 0;  0.012, -0.006];
       % GCparam.frat =  GCparam.frat_HIsimulate1;
       %Level.SynSnddB_Cmpnst =  3.5; % magic number for level compenstation
       %Level.FBspecdB_Cmpnst =  35.0; % magic number for level compenstation
       
    
       %GCparam.frat_HIsimulate1 = [0.4660, 0;  0.003,  0];
       %GCparam.frat = GCparam.frat_HIsimulate1;
       %Level.SynSnddB_Cmpnst =  4.2; % magic number for level compenstation
       %Level.FBspecdB_Cmpnst =  37; % magic number for level compenstation

       % HIsimulate #1
       % Ef = Freq2ERB([100 500 1000 2000 4000 6000  8000])/Freq2ERB(1000) 
       %    = [0.2157 0.6892 1.0000 1.3542 1.7353 1.9657 2.1313]
       % c2 = [2.2  0]
       % c2 = c11+ c12*Ef = 2.2 + c12*1 + c12(Ef-1)
       % 
       %GCparam.c2 = [ 2.2,  -1];
       % Vector represenation would be necessary! --> GCFBv210
       % Level.SynSnddB_Cmpnst =   0; % magic number for level compenstation
       % Level.FBspecdB_Cmpnst =  30; % magic number for level compenstation
       
    %elseif strcmp(StrFB,char(StrFBList(5)))
     %  GCparam.frat_InvComp21 = -0.005;
     %  GCparam.frat_InvComp22 =  0.002;
%       GCparam.frat_InvComp21 = -0.013;
%       GCparam.frat_InvComp22 =  0.005;
       %GCparam.frat_InvComp21 = -0.003*1.5;
       %GCparam.frat_InvComp22 =  0;      
     %  GCparam.frat_LevelCenter =  65;
     %  GCparam.frat_InvComp11 = GCparam.frat_NormalHearing(1,1)  ...
     %          +(GCparam.frat_NormalHearing(2,1) - GCparam.frat_InvComp21) ...
     %           *GCparam.frat_LevelCenter;
     % GCparam.frat_InvComp12 =  0;  % ???
      
     %  GCparam.frat_LevelCenter =  65;
     %  GCparam.frat_InvCompHIsim1 ...
     %      = [GCparam.frat_InvComp11 GCparam.frat_InvComp12;   ...
      %        GCparam.frat_InvComp21 GCparam.frat_InvComp22];

      % GCparam.frat = GCparam.frat_InvCompHIsim1;


     %  GCparam.LvlEst.DecayHL = 10; 

     %  Level.SynSnddB_Cmpnst =  -31.2; % magic number for level compenstation
     %  Level.FBspecdB_Cmpnst =  0.5; % magic number for level compenstation

       %Level.SynSnddB_Cmpnst =  -46.5; % magic number for level compenstation
       %Level.FBspecdB_Cmpnst =  -18.1; % magic number for level compenstation
       %Level.SynSnddB_Cmpnst =  5.2; % magic number for level compenstation
       %Level.FBspecdB_Cmpnst =  38.6; % magic number for level compenstation

   % else
   %    help(mfilename);
   %    error(['*** Argument setting (StrFB) in "' mfilename '" ***']);
   % end;
 
    
    
    
%%%%
%    elseif strcmp(StrFB,char(StrFBList(4)))
%        error('Not prepared yet');
        
       % Midium Inverse Compression
       % GCparam.frat = [ 1.261, 0;  -0.0050, 0]; 
       %        (frat11+(frat21+frat21b)*50 - frat21b *Lvl
       %GCparam.frat_MidInvCompression21 = 0.005;     
       %fratInv11 = GCparam.frat_NormalHearing(1,1) + ...
       %    GCparam.frat_NormalHearing(2,1) *GCparam.frat_CenterLevel + ...
       %    GCparam.frat_MidInvCompression21*GCparam.frat_CenterLevel;
       %GCparam.frat_MidInvCompression = [fratInv11 0;  -GCparam.frat_MidInvCompression21 0];

       % GCparam.LvlEst.DecayHL = 10; 

       %Level.SynSnddB_Cmpnst =   5.47; % magic number for level compenstation
       %Level.FBspecdB_Cmpnst =  10; % magic number for level compenstation

%%
       
%frat_InvComp21List  = [0:-0.002:-0.020];
%LevelCenterList = [50:5:90]; 
%CmpnstdBTable = [ ...
% -14.36 -20.06 -25.04 -29.12 -32.41 -35.08 -37.27 -39.26 -42.92 -43.20  val11;
% -15.20 -21.19 -26.77 -31.58 -35.63 -39.04 -41.95 -44.46 -46.84 -50.74 -54.70;
% -16.08 -22.21 -28.18 -33.57 -38.21 -42.17 -45.53 -48.40 -50.90 -53.21 -55.36;
% -16.87 -22.84 -28.83 -34.37 -39.25 -43.36 -46.84 -49.79 -52.27 -54.38 -56.27;
% -17.43 -22.89 -28.47 -33.79 -38.60 -42.74 -46.24 -49.23 -51.74 -53.87 -55.68;
% -17.70 -22.42 -27.27 -32.09 -36.64 -40.75 -44.31 -47.36 -49.96 -52.19 -54.10;
% -17.76 -21.64 -25.62 -29.72 -33.80 -37.69 -41.25 -44.41 -47.15 -49.51 -51.55;
% -17.74 -20.81 -23.92 -27.13 -30.48 -33.88 -37.22 -40.36 -43.21 -45.75 -47.98;
% -17.70 -20.13 -22.45 -24.80 -27.27 -29.87 -32.58 -35.35 -38.07 -40.66 -43.05];

% original data on  16 Jan 2012
%frat_InvComp21List  = [-0.01:-0.002:-0.018];
%CmpnstdBTable = [ ...
  %-35.08 -37.2700  -39.2600  -42.9200  -43.2000
  %-39.0400  -41.9500  -44.4600  -46.8400  -50.7400
  %-42.1700  -45.5300  -48.4000  -50.9000  -53.2100
  %-43.3600  -46.8400  -49.7900  -52.2700  -54.3800
  %-42.7400  -46.2400  -49.2300  -51.7400  -53.8700
 % -40.7500  -44.3100  -47.3600  -49.9600  -52.1900
  %-37.6900  -41.2500  -44.4100  -47.1500  -49.5100
  %-33.8800  -37.2200  -40.3600  -43.2100  -45.7500
  %-29.8700  -32.5800  -35.3500  -38.0700  -40.6600];

  
%CmpnstdBTable01 = [
%   7.42   7.34   7.14   6.75   6.05   4.87   3.02   0.27  -3.61  -8.63 -14.36; ...
%   10.32   9.57   8.71   7.66   6.35   4.65   2.41  -0.56  -4.48  -9.44 -15.20; ...
%   13.07  11.73  10.23   8.55   6.64   4.43   1.78  -1.46  -5.47 -10.37 -16.08; ...
%   15.56  13.71  11.68   9.42   6.94   4.20   1.11  -2.42  -6.54 -11.35 -16.87; ...
%   17.81  15.52  13.02  10.25   7.23   3.97   0.43  -3.42  -7.65 -12.31 -17.43; ...
%   19.74  17.16  14.25  11.05   7.52   3.74  -0.27  -4.45  -8.76 -13.16 -17.70; ...
%   21.32  18.58  15.39  11.81   7.80   3.51  -0.98  -5.48  -9.82 -13.88 -17.76; ...
%   22.53  19.77  16.43  12.52   8.08   3.27  -1.70  -6.50 -10.79 -14.48 -17.74; ...
%   23.39  20.74  17.35  13.18   8.36   3.03  -2.43  -7.50 -11.68 -14.98 -17.70; ...
%];

%valQ = -888.83; % original data from Sakaguchi
%valQ = -45.00; % compensated manually by Irino (19 Jan 12)
%CmpnstdBTable02 = [
 % -20.06  -25.04  -29.12  -32.41  -35.08  -37.27  -39.26  -42.92  -43.20   valQ ; ...
%  -21.19  -26.77  -31.58  -35.63  -39.04  -41.95  -44.46  -46.84  -50.74  -54.70; ...
%  -22.21  -28.18  -33.57  -38.21  -42.17  -45.53  -48.40  -50.90  -53.21  -55.36; ...
%  -22.84  -28.83  -34.37  -39.25  -43.36  -46.84  -49.79  -52.27  -54.38  -56.27; ...
%  -22.89  -28.47  -33.79  -38.60  -42.74  -46.24  -49.23  -51.74  -53.87  -55.68; ...
%  -22.42  -27.27  -32.09  -36.64  -40.75  -44.31  -47.36  -49.96  -52.19  -54.10; ...
%  -21.64  -25.62  -29.72  -33.80  -37.69  -41.25  -44.41  -47.15  -49.51  -51.55; ...
%  -20.81  -23.92  -27.13  -30.48  -33.88  -37.22  -40.36  -43.21  -45.75  -47.98; ...
%  -20.13  -22.45  -24.80  -27.27  -29.87  -32.58  -35.35  -38.07  -40.66  -43.05; ...
%];  
        %       FBparam.Level.SynSnddB_CmpnstdB = -15.14;  % Hand Eqlz at 100dB sin-1kHz-100 ms (IT 11 Nov. 2011)

