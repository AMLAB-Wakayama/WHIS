%
%      Fast Hearing Impairment Simulator using GCFB
%      IRINO T.
%      Created:    16 Dec 2013 from testFastHIsim_6Dec13b.m
%      Modified:   16 Dec 2013
%      Modified:   17 Dec 2013 (Level compensation)
%      Modified:   22 Dec 2013 (GCFBv209 renamed)
%      Modified:   26 Dec 2013 ( HISparam.frat_LevelCenter =  65;)
%      Modified:    4 Jan 2014 ( TVFparam.Win --> TVFparam.WinAna)
%      Modified:    4 Feb 2014 (introduction of HLdB_LossLinear && vector frat etc.)
%      Modified:    5 Feb 2014
%      Modified:    4 Jul 2014 (checked warning)
%      Modified:    9 Nov 2014 (error for range HISparam.DegreeCompression);
%      Modified:   14 Nov 2014 (double filtering for wider dynamic);
%      Modified:   24 Nov 2014 (with STFT modified amp + original phase,HISparam.SwMethodModSpec == 2)
%      Modified:    8 May 2015 (downsampling for 48kHz, 44.1kHz --> half)
%      Modified:   26 Jun 2016 (adding help mfilename)
%      Modified:    11 Jul 2018 (SndIn0)
%      Modified:     6  Dec 2018 (GCFBv211  it is the exactly same as GCFBv210 but for new package.)
%      Modified:   12  Dec 2018 (introduction of HISparam.SwAmpCmpnst, HIsimFastGC_MkTableGain.m)
%      Modified:   14  Dec 2018 (名称変更。HIsimFastGC_MkCmpnstGain.m。)
%      Modified:    27 Dec 18  (IT, バグfix)
%      Modified:    16 Jan  19  (IT, HIsimFastGC_CmpnstGain.matのdirctory指定 ~/Data/HIsim/ )
%      Modified:    17 Jan  19  (IT, HIsimFastGC_CmpnstGain.matのdirctory指定 ~/Data/HIsim/ )
%      Modified:      8 Dec 19  (IT, matが無い場合、HIsimFastGC_CmpnstGain.mを読み込む。 )
%      Modified:      7 Feb  20 (IT, HIsimFastGC_CmpnstGain.mを明示的に読み込む。ーーそうしないとコンパイルが通らない。 )
%      Modified:    21 Feb  20 (IT, 7 Feb 20のコードを整理 )
%
%
%   function [SndOut, HISparam] = HIsimFastGC(SndIn, HISparam);
%   INPUT:  SndIn : input sound
%           HISparam: parameters
%   OUTPUT: SndOut: processed sound
%           HISparam: parameters
%
%
%
% NOTE: 15 Nov 2014   SwDoubleFilter = 1
%     Double filtering is introduce to keep the dynamic range.
%     The IO function for sin is completely the same as the power filter.
%     But the effectiveness for speech sounds is not clear.
%
% NOTE: 24 Nov 2014   HISparam.SwMethodModSpec == 2
%     Introducing STFT Amp mod + original phase for comparison.
%     It should be used solely for comparison.
%
% NOTE: 8 May 2015
%      For speed up, when fs_{SndIn} >= 44100 Hz,
%      fs_{internal signal processing} is the half of fs_{SndIn}.
%      fs_{SndOut} == fs_{SndIn}.
%
% NOTE: 17 Jun 2019
% Gain file :  HIsimFastGC_CmpnstGain.mat
% この場所は、m-fileから計算する時は、m-fileのDirectoryの下にあるため問題ない。
% しかし、Compile版では、それが認識できない。Directoryの構造を理解できないため。
% あらかじめ、$User/Data/HIsim/ （Working directory)にインストールしてもらって使う。
% そのために、TableGain.Dir = HISparam.GUI.DirSoundというのを入れている。
%
% NOTE:   7 Feb  20
% IT, HIsimFastGC_CmpnstGain.mを明示的に読み込む。ーーそうしないとコンパイルが通らない。
%
%
function [SndOut, HISparam] = HIsimFastGC(SndIn0, HISparam);

if nargin < 1,
    str = ['help ' mfilename];
    eval(str);
end;

if nargin < 2, HISparam = []; end;


if length(HISparam) == 0, HISparam.fs = 48000; end;
if isfield(HISparam,'AllowDownSampling') == 0,
    HISparam.AllowDownSampling = 0;
end;

if HISparam.AllowDownSampling == 1 && HISparam.fs >= 44000,
    HISparam.RateDownSampling = 2;
    HISparam.fsKeep = HISparam.fs;
    HISparam.fs = HISparam.fsKeep/HISparam.RateDownSampling;
    SndIn = decimate(SndIn0,HISparam.RateDownSampling);
    disp(['DownSampling for calculation: ' int2str(HISparam.fsKeep) ...
        ' --> ' int2str(HISparam.fs) ' Hz']) ;
else
    SndIn = SndIn0;
    HISparam.AllowDownSampling = 0;
    warning('No DownSampling allowed when fs < 44000');
end;

%

fs = HISparam.fs;

%% input level setting:  Noramized by Eqlz2MeddisHCLevel
if isfield(HISparam,'SrcSndSPLdB') == 0,
    HISparam.SrcSndSPLdB = 90;
    warning('Specify HISparam.SrcSndSPLdB or set to 90 dB');
end;
[SrcSnd, AmpdB] = Eqlz2MeddisHCLevel(SndIn,HISparam.SrcSndSPLdB);
HISparam.Eqlz2MeddisHCLevel_AmpdB = AmpdB;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Level Estimation: GCFB                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GCparam.fs     = fs;
GCparam.NumCh  = 100;
%GCparam.FRange = [100, 8000];  % NG for 8kHz tone processing (3dB diff).
%GCparam.FRange = [100, 10000]; % OK for 8kHz tone
GCparam.FRange = [100, 12000];
if HISparam.AllowDownSampling == 1, % quality may be degraded
    GCparam.FRange = [100, 10000];
end;
GCparam.OutMidCrct = 'ELC';

GCparam.Ctrl = 'level'; % level estimation only

tic
disp('##### GCFB for level estimation (Excitation Pattern) #####');
[cGCout, pGCout, GCparam, GCresp] = GCFBv211(SrcSnd,GCparam);
tElps(1) = toc;
Tsnd = length(SrcSnd)/fs;

disp(['Elapsed time is ' num2str(tElps(1),4) ' (sec) = ' ...
    num2str(tElps(1)/Tsnd,4) ' times RealTime.']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set HISparam                                     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HISparam.NumERBFr1  = Freq2ERB(GCresp.Fr1);

if isfield(HISparam,'HISparam.FaudgramList') == 0,
    HISparam.FaudgramList = 125*2.^(0:6);
end;
HISparam.NumERBaudgramList = Freq2ERB(HISparam.FaudgramList);

if isfield(HISparam,'RatioInvCompression') == 1,
    if length(HISparam.RatioInvCompression) == 1, % when direct control.
        error('Specify HISparam.DegreeCompression. Internal param: HISparam.RatioInvCompression');
    end;
end;

SwPlot = 0;
if isfield(HISparam,'DegreeCompression') == 0,
    SwPlot = 1; % simple case
    HISparam.DegreeCompression   = 0;
    HISparam.RatioInvCompression = 1 - HISparam.DegreeCompression;
end;

if length(HISparam.DegreeCompression) == 1, % vectorize
    HISparam.DegreeCompression = ...
        HISparam.DegreeCompression*ones(size(HISparam.FaudgramList));
    warning('Specify HISparam.DegreeCompression vector or set to "Full compression loss"');
else
    if length(HISparam.DegreeCompression) ~= length(HISparam.FaudgramList)
        error('length(HISparam.DegreeCompression) ~= length(HISparam.FaudgramList)');
    end;
end;

if mean(HISparam.DegreeCompression) < 0 ||  mean(HISparam.DegreeCompression) > 1
    error('HISparam.DegreeCompression should be between 0 and 1');
end;
HISparam.RatioInvCompression = 1 - HISparam.DegreeCompression;


if isfield(HISparam,'HLdB_LossLinear') == 0,
    % no linear loss (unlikely. But as a default)
    HISparam.HLdB_LossLinear = zeros(size(HISparam.FaudgramList));
    warning('Specify HISparam.HLdB_LossLinear vector. --> Current setting "NO linear loss"');
end;

if isfield(HISparam,'SwMethodModSpec') == 0, % 24 Nov 14
    HISparam.SwMethodModSpec = 1; % default double filtering
end;

%% %%%%%%%%%%%%%%%%%%%%%%%%
% Amplitude compensation
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%default はgain補正なし。
HISparam.AmpCmpnst = 1;  % default無効に。1倍。
HISparam.Gain4CmpnstdB =  zeros(size(HISparam.FaudgramList)); % default無効に。0dB。

if HISparam.SwAmpCmpnst == 1,
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Gain control  旧来の方法 2014
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % For amplitude final compensation
    % This value may be changed since using mean(HISparam.RatioInvCompression)
    % 4 Feb 2014
    PolyCoef_AmpCmpnst = [26.2841  -52.9619   26.8630];
    val1 = polyval(PolyCoef_AmpCmpnst,mean(HISparam.RatioInvCompression));
    HISparam.AmpCmpnst = 10^(val1/20);
    
elseif HISparam.SwAmpCmpnst ==2,
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Gain control 補正 sin波で、HLに合わせる。　12 Dec 2018
    % このTableを作る関数は、HIsimFastGC_MkCmpnstGain.m
    %
    % 2019/1/17 Note
    % Gain file :  HIsimFastGC_CmpnstGain.mat
    % この場所は、m-fileから計算する時は、m-fileのDirectoryの下にあるため問題ない。
    % しかし、Compile版では、それが認識できない。Directoryの構造を理解できないため。
    % あらかじめ、$User/Data/HIsim/ （Working directory)にインストールしてもらって使う。
    % そのために、TableGain.Dir = HISparam.GUI.DirSoundというのを入れている。
    %
    % 2019/12/9 m-fileも用意
    %  mat file が読み込めない場合、m-fileを読み込む。上記の機能は停止した。
    %
    % 7 Feb  20
    % HIsimFastGC_CmpnstGain.mを明示的に読み込む。ーーそうしないとコンパイルが通らない。
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    HIsimFastGC_CmpnstGain;   % 直接m-fileを名指しで呼ぶ形に。
    
    
    for nfc= 1:length(TableGain.FaudgramList) %各周波数ごとに、Gain4CmpnstdBを出す。あとで補正。
        fc = TableGain.FaudgramList(nfc);
        GainMtrx = squeeze(TableGain.HIsimSndLeveldB_DiffHL(:,:,nfc));
        X = squeeze(TableGain.HLdBMeshgrid(:,:,nfc));
        Y = squeeze(TableGain.CmprsMeshgrid(:,:,nfc));
        qHLdB  =  HISparam.HearingLevelVal(nfc);                  % query for this specific value
        qCmprs = HISparam.DegreeCompression(nfc)*100;   % query for this specific value
        HISparam.Gain4CmpnstdB(nfc) = interp2(X,Y,GainMtrx,qHLdB,qCmprs);
    end;
    
else
    error('Specify HISparam.SwAmpCmpnst');
end;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set frat     vector 4 Feb 2014                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HISparam.frat_LevelCenter =  60; % NG:  sound noisy,  good IO
% HISparam.frat_LevelCenter =  55; % sound noisy
% HISparam.frat_LevelCenter =  50; % small compression 25 Dec 2013
% HISparam.frat_LevelCenter 　=  65; % better IO -- no noise with Twin == 0.020
HISparam.frat_LevelCenter   =  65 * ones(1,GCparam.NumCh);
HISparam.frat_NormalHearing =  GCparam.frat(1:2,1) * ones(1,GCparam.NumCh);
%HISparam.frat_InvCompression = zeros(2,2);
% HISparam.frat_InvCompression(2,1) = -0.016;  % recommendation = -1.47*0.0109
% HISparam.frat_InvCompression(2,1) = -0.0109; % inversion 17 Dec 2013
%HISparam.frat_InvCompression(2,1) = -0.0109*HISparam.RatioInvCompression; % half inversion 17 Dec 2013
%HISparam.frat_InvCompression(1,1) = ...
%            HISparam.frat_NormalHearing(1,1)  ...
%          +(HISparam.frat_NormalHearing(2,1) - HISparam.frat_InvCompression(2,1)) ...
%           *HISparam.frat_LevelCenter;

HISparam.RatioInvCompression_NchFB = interp1(HISparam.NumERBaudgramList, ...
    HISparam.RatioInvCompression,HISparam.NumERBFr1,'linear','extrap');
HISparam.frat_InvCompression = zeros(2,GCparam.NumCh);
NchAll = 1:GCparam.NumCh;
HISparam.frat_InvCompression(2,NchAll) = -0.0109*HISparam.RatioInvCompression_NchFB;
HISparam.frat_InvCompression(1,NchAll) = ...
    HISparam.frat_NormalHearing(1,NchAll)  ...
    +(HISparam.frat_NormalHearing(2,NchAll) - HISparam.frat_InvCompression(2,NchAll)) ...
    .*HISparam.frat_LevelCenter(NchAll);


%if isfield(HISparam,'frat_LevelCenter') == 0,
%end;
% if isfield(HISparam,'frat_InvCompression') == 0,    % you cannot specify in advance
% end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SimTVFilter                                      %%
%% Analysis                                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(HISparam,'TVFparam') == 1, TVFparam = HISparam.TVFparam; end;
TVFparam.fs   = fs;
TVFparam.Ctrl = 'ana';

[SndMod WinFrame TVFparam ] = SimTimeVaryFilter_AnaSyn(SrcSnd,[],TVFparam); % default ana
%TVFparam

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Gain calculation                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('##### Gain Calculation #####');
% compensation factor from IO function : adhoc   17 Dec 2013
%%% CmpnstFchkList = 250*2.^(0:5);      %%  <--- why there is no 125 Hz ? 4 Feb14
% HISparam.CmpnstAt100dB = [-3, -7.2, -8.4, -9.6, -10.6, -7.3]+12;
% HISparam.CmpnstAt100dB = [ 8.9783    4.7260    3.6065    2.3958    1.3683    4.7111]; % 17 Dec 2013
% for  HISparam.frat_InvCompression(2,1) = -0.0109
% HISparam.frat_LevelCenter =  50;
%%HISparam.CmpnstAt100dB = [ 16.6353   12.3121   10.0377    7.5650    5.1409   16.5161]; % 25 Dec 2013
% 'offset' calculated from CalIO_HIsimFastGC.m
%
% modified for 125-8000, 4 Feb 14. value@125 should be checked.
%CmpnstFchkList = 125*2.^(0:6);
% HISparam.FaudgramList = 125*2.^(0:6); % F_AudioGram it is defined above
%

% 100 dBで入出力が一致するように補正するためのmagic number
HISparam.CmpnstAt100dB = [ 19.7 16.6353   12.3121   10.0377    7.5650    5.1409   16.5161]; % 4 Feb 2014

HISparam.CmpnstLineardB = HISparam.CmpnstAt100dB - HISparam.HLdB_LossLinear;
%disp(HISparam.CmpnstLineardB) % OK?
disp([sprintf('%6.2f, ',HISparam.FaudgramList/100); ...
    sprintf('%6.2f, ',HISparam.DegreeCompression); ...
    sprintf('%6.2f, ',HISparam.HLdB_LossLinear); ...
    sprintf('%6.2f, ',HISparam.CmpnstAt100dB); ...
    sprintf('%6.2f, ',HISparam.CmpnstLineardB);]);
% OK?

% Faudgram --> FB Fr1
HISparam.CmpnstFBgaindB  = interp1(HISparam.NumERBaudgramList,HISparam.CmpnstLineardB, ...
    HISparam.NumERBFr1,'linear','extrap');
HISparam.CmpnstFBampNorm = 10.^(HISparam.CmpnstFBgaindB/20);
%HISparam.CmpnstFBgaindB  = interp1(HISparam.NumERBaudgramList,HISparam.CmpnstAt100dB, ...
%                            HISparam.NumERBFr1,'linear','extrap');
%plot(HISparam.NumERBaudgramList,HISparam.CmpnstAt100dB,HISparam.NumERBFr1,HISparam.CmpnstFBgain)
%pause

% cal gain at filerbank channel
[NumCh, LenSnd] = size(cGCout);
LvlFramedB = zeros(NumCh,TVFparam.NumFrame);
for nch=1:GCparam.NumCh
    if nch == 1 | rem(nch,20)==0
        disp(['LvlEst  ch #' num2str(nch) ' / #' num2str(NumCh)]);
    end;
    % Level Estimation
    LvlLin1 = sqrt(pGCout(GCparam.LvlEst.NchLvlEst(nch),:).^2); % RMS value difference < 2 dB  when no decay
    LvlLin2 = sqrt(cGCout(GCparam.LvlEst.NchLvlEst(nch),:).^2); % 1.96dB = 20*log10(sqrt(mean(sin.^2))/sqrt(mean(max(sin,0)))
    LvlLinTtl = GCparam.LvlEst.Weight * ...
        GCparam.LvlEst.LvlLinRef*(LvlLin1/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(1) ...
        + (1 - GCparam.LvlEst.Weight) * ...
        GCparam.LvlEst.LvlLinRef*(LvlLin2/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(2);
    
    % Level dB for each Frame
    [dummy LvlLinTtlMtrx TVFparam ] = SimTimeVaryFilter_AnaSyn(LvlLinTtl,[],TVFparam);
    LvlLinFrame  = sum(LvlLinTtlMtrx)/sum(TVFparam.WinAna);
    
    LvlFramedB(nch,1:TVFparam.NumFrame) = 20*log10( max(LvlLinFrame,GCparam.LvlEst.LvlLinMinLim) ) ...
        + GCparam.LvlEst.RMStoSPLdB;
    
    % LvldB --> frat
    HISparam.frat_Ctrl = HISparam.frat_InvCompression;
    %disp(HISparam.frat_Ctrl)
    %pause
    %HISparam.frat_Ctrl = HISparam.frat_NormalHearing;
    fratFrame(nch,1:TVFparam.NumFrame) = HISparam.frat_Ctrl(1,nch) ...
        + HISparam.frat_Ctrl(2,nch) * LvlFramedB(nch,1:TVFparam.NumFrame);
    
    % frat --> Gain   50dB RefdB
    forigin = GCresp.Fr1(nch); % center -- closest
    fshift  = fratFrame(nch,:) * forigin; % NH
    b_val   = GCparam.b2(1,1);
    c_val   = GCparam.c2(1,1);   %%     %%c_val   = GCparam.c2(1,1)*1.2;
    [dummy ERBw] = Freq2ERB(fshift);
    
    
    %AmpNormAFG = HISparam.CmpnstFBampNorm(nch)/exp(signShift*c_val*pi/2); % Normalization factor 17 Dec 2013
    AmpNormAFG = HISparam.CmpnstFBampNorm(nch)/exp(c_val*pi/2); % Normalization factor 17 Dec 2013
    AsymFuncGain(nch,1:TVFparam.NumFrame) = ...
        AmpNormAFG*exp(c_val*atan2(forigin - fshift,b_val*ERBw));  % normalized
    
    AsymFuncGain = min(AsymFuncGain,4);
    
end;
tElps(2) = toc;

Fr_Lvl = [GCresp.Fr1(:)'/1000; GCresp.Fp1(:)'/1000;  GCresp.Fp1(GCparam.LvlEst.NchLvlEst)'/1000;...
    mean(LvlFramedB'); mean(fratFrame');   mean(AsymFuncGain') ];
%disp(Fr_Lvl)
disp(['Elapsed time is ' num2str(tElps(2),4) ' (sec) = ' ...
    num2str(tElps(2)/Tsnd,4) ' times RealTime.']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filter control                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HISparam.TresponseLength  = 0.004; % Nishi : koNnichiwaの場合0.004s(responseLength)までで十分？？
% HISparam.TresponseLength  = 0.008; %NG 長いとかえって雑音が入る。Irino, 26Dec13
HISparam.Nfft   = 1024;  % with truncation it works.
freqBin = linspace(0,fs/2,HISparam.Nfft/2+1); %  for linear power & minimum phase filter

disp('##### Minimum phase filtering #####');
if SwPlot == 1,
    subplot(3,1,1)
    plot(AsymFuncGain(1:10:100,:)')
end;
% dfB = mean(diff(freqBin))
% dERB   =  mean(diff(Freq2ERB(GCresp.Fr1)));
% Fr1Ext = linspace(max(GCresp.Fr1)+300,fs/2,40);
pwrAFG1 = AsymFuncGain.^2;
Fr1ExtL = [0:20:80]';
pwrExtL = 2.^(Fr1ExtL(:)/max(Fr1ExtL)-1)*pwrAFG1(1,:); % +3dB/oct
Fr1ExtU = ((max(GCresp.Fr1)+500):500:fs/2)';
if isempty(Fr1ExtU)
    pwrExtU = [];
else
    pwrExtU = 2.^(-Fr1ExtU(:)/min(Fr1ExtU)+1)*pwrAFG1(end,:);  % -3dB/oct
end;
FrAll  = [Fr1ExtL(:); GCresp.Fr1; Fr1ExtU(:)];
pwrAFG = [pwrExtL; pwrAFG1; pwrExtU];


if HISparam.SwAmpCmpnst == 1,
    CmpnstPwr = ones(size(HISparam.FaudgramList));
elseif HISparam.SwAmpCmpnst == 2,
    %% Gain の補正　Gain4Cmpnst   12 Dec 2018 %%%%%%%%%%%
    LogFag         = log10(HISparam.FaudgramList); %対数上で線形補間。
    LogfreqBin   = log10(max(freqBin,10));  % 0を避けるためmax(freqBin,10)
    CmpnstPwr  = 10.^(interp1(LogFag, -HISparam.Gain4CmpnstdB/10, LogfreqBin,'linear','extrap'));
    % for check
    %CmpnstPwr = 0.01*ones(size(CmpnstPwr));  %ちゃんと-20dB落ちる。Linear領域で掛けている
    %%%  ここまで 12 Dec 2018  %%%%%%%%%%%
end;

%% %%%%%%%%%
% filtering の実行
%%%%%%%%%%%
%SwDoubleFilter = 0; %２重にかけるのはdynamic rangeを広げるため。計算上、あまり小さい係数は使えないため。
%SwDoubleFilter = 1; --> replaced to HISparam.SwMethodModSpec 24 Nov 14

WinFrameMod = zeros(size(WinFrame));
for nf = 1:TVFparam.NumFrame
    
    % Gain(Fr1) --> Gain(FFT bin)
    pwrSpec1 = exp(interp1(FrAll, log(pwrAFG(:,nf)),freqBin,'linear','extrap'));
    pwrSpec  = CmpnstPwr.*pwrSpec1;   %%  ここで補正。12 Dec 2018 %%%%
    
    if HISparam.SwMethodModSpec == 0, % single power filter
        if nf== 1, disp('--- Original PwrSpec Minimum phase filtering ---'); end;
        mpResponse1 = powerSpectrum2minimumPhase(pwrSpec(:),fs)';
        mpResponse = mpResponse1(1:ceil(HISparam.TresponseLength*fs));
        WinFrameMod(:,nf) = filter(mpResponse,1,WinFrame(:,nf));  % sufficiently fast ~= fftfilt
        
    elseif HISparam.SwMethodModSpec == 1     || HISparam.SwMethodModSpec == 2
        % double filtering with rms amp filter
        if nf==1, disp('--- Double AmpSpec Minimum phase filtering (default) ---');end;
        AmpSpec = sqrt(pwrSpec(:));
        mpResponse1 = powerSpectrum2minimumPhase(AmpSpec,fs)';
        mpResponseHalf  = mpResponse1(1:ceil(HISparam.TresponseLength*fs));
        tmpRsp = filter(mpResponseHalf,1,WinFrame(:,nf));         % sufficiently fast ~= fftfilt
        WinFrameMod(:,nf) = filter(mpResponseHalf,1,tmpRsp);
        % disp('OK double filtering');
    end;
    
    if HISparam.SwMethodModSpec == 2,
        if nf==1, warning('--- STFT modified amplitude + original phase [for comparion] --'); end;
        FFTSpec      = fft(WinFrame(:,nf),HISparam.Nfft);
        AmpModSpec1  = abs(FFTSpec(1:HISparam.Nfft/2+1)).*sqrt(pwrSpec(:)); % Signal x Filter
        %NG: pwrSpec(:)/sqrt(mean(pwrSpec(:).^2))*sqrt(mean(AmpFFTSpec.^2));
        AmpModSpec = [AmpModSpec1; flipud(AmpModSpec1(2:end-1))];
        Rsp1 = ifft(AmpModSpec.*exp(j*angle(FFTSpec)));
        if sqrt(mean(imag(Rsp1).^2))/sqrt(mean(real(Rsp1).^2)) > 100*eps,
            error('Something wrong with FFT/IFFT');
        end;
        Rsp2 = real(Rsp1(1:length(WinFrame(:,nf))));
        % compenate the level and override the results
        AmpCmpnst = sqrt(mean(WinFrameMod(:,nf).^2))/sqrt(mean(Rsp2.^2));
        WinFrameMod(:,nf) = AmpCmpnst*Rsp2;
    end;
    % filtering
    %WinFrameMod(:,nf) = fftfilt(mpResponse,WinFrame(:,nf));
    
    if SwPlot == 1,
        subplot(3,1,2)
        plot(mpResponse);
        grid on;
        [frsp1, freq1] = freqz(mpResponse,1,HISparam.Nfft/2,fs);
        
        subplot(3,1,3)
        semilogx(freqBin,10*log10(pwrSpec),freq1,20*log10(abs(frsp1)));
        grid on;
        %axis([50 20000 -30 20]);
        %pause(1)
    end;
    
    if nf == 1 | rem(nf,50)==0
        disp(['Frame #' num2str(nf) ' / #' num2str(TVFparam.NumFrame)]);
        drawnow
    end;
end;
tElps(3) = toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Synthesis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TVFparam.Ctrl = 'syn';
[SndOut WinFrame TVFparam ] = SimTimeVaryFilter_AnaSyn([],WinFrameMod,TVFparam);

% compensate back to original level
AmpMHCL = 10^(-HISparam.Eqlz2MeddisHCLevel_AmpdB(2)/20);
SndOut = HISparam.AmpCmpnst*AmpMHCL*SndOut;


if HISparam.AllowDownSampling == 1
    SndOut = interp(SndOut,HISparam.RateDownSampling);
    disp(['UpSampling for recover: ' int2str(HISparam.fs) ...
        ' --> ' int2str(HISparam.fsKeep) ' Hz']) ;
    HISparam.fs = HISparam.fsKeep;
end;

tElps(4) = toc;

disp(['Elapsed time is ' num2str(tElps(4),4) ' (sec) = ' ...
    num2str(tElps(4)/Tsnd,4) ' times RealTime.']);

%rinji
%csvwrite('jikan.txt', tElps(4));

HISparam.ElapsedTime      = tElps;
HISparam.ElapsedTimePerRealTime    = tElps/Tsnd;
%HISparam.ElapsedTimeStage = diff(tElps);
HISparam.TVFparam = TVFparam;
HISparam.GCparam  = GCparam;

%HISparam

return;


%% %%%%%%%%%%% trash %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%imagesc(abs(LvlFramedB))
%Nfft =  1024; Long Nfft results in clicky sounds. but necessary
%Nfft =  64; % 64 OK << LenWin = 481  ... 128 slight noise   256 NG


%signShift = sign(HISparam.frat_Ctrl(2,1));
%AsymFuncGain = AsymFuncGain/exp(signShift);
%%% original Asymmetric Function without shift centering
% fd = (ones(NumCh,1)*freq - Frs*ones(1,NfrqRsl));
% be = (b.*ERBw)*ones(1,NfrqRsl);
% cc = (c.*ones(NumCh,1))*ones(1,NfrqRsl); % in case when c is scalar
% AsymFunc = exp(cc.*atan2(fd,be));

%   TresponseLength  = 0.004; % Nishi : koNnichiwaの場合0.004s(responseLength)までで十分？？


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Level Estimation: Calculating approximated Pc(t) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  in GCFBv209     %%%
% NchShift       = round(GCparam.LvlEst.LctERB/ERBspace1);
% NchLvlEst      = min(max(1, (1:NumCh)'+NchShift),NumCh);
%
% LvlLin(1:NumCh,1) = ...
%   max([max(pGCout(NchLvlEst,nsmpl),0), LvlLinPrev(:,1)*ExpDecayVal]')';
% LvlLin(1:NumCh,2) = ...
%    max([max(cGCoutLvlEst(NchLvlEst,nsmpl),0), LvlLinPrev(:,2)*ExpDecayVal]')';
% LvlLinPrev = LvlLin;
%
%%%%%% Modified: 14 July 05
% LvlLinTtl = GCparam.LvlEst.Weight * ...
%     LvlLinRef.*(LvlLin(:,1)/LvlLinRef).^GCparam.LvlEst.Pwr(1) ...
%  + ( 1 - GCparam.LvlEst.Weight ) * ...
%     LvlLinRef.*(LvlLin(:,2)/LvlLinRef).^GCparam.LvlEst.Pwr(2);
%
% LvldB(:,nsmpl) = 20*log10( max(LvlLinTtl,LvlLinMinLim) ) ...
%                             + GCparam.LvlEst.RMStoSPLdB;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%
% HIsimFastGC_MkCmpnstGain
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       TableGain = HIsimFastGC_MkCmpnstGain(1); %名前だけとってくる。
%        DirNameGain = [TableGain.Dir TableGain.Name];
%        DirNameGainRoot = strrep(TableGain.Name,'.mat','');

%         % 失敗したら、m-fileを呼び出しする形式に変更　　8 Dec 2019
%
%         if exist(DirNameGain) == 0,
%             warning(['No file: ' DirNameGain ]);
%             % 無い場合は、~/Data/HIsimからとってくる。
%             TableGain.Dir = HISparam.GUI.DirSound;
%             DirNameGain = [TableGain.Dir TableGain.Name];
%             warning(['Alternative file: ' DirNameGain ]);
%         end;
%
%         % if exist(DirNameGain) == 0
%             % HIsimFastGC_MkTableGainで作っている最中もここを通る。
%             % 無い場合、基本的にはerrorで停止。
%             % TableGainを、先に作るためには：
%             % Step1 : errorの行をコメントアウト
%             % Step2 : HIsimFastGC_MkCmpnstGainを実行。
%             % Step3 : errorの行をコメントアウトを解除
%             %
%             % disp(['First, you need to produce ' TableGain.Name '!']);
%             % disp(['Step 1: Comment out the following "error" line']);
%             % disp(['Step 2: Execute  HIsimFastGC_MkCmpnstGain']);
%             % disp(['Step 3: Recover the "error" line']);
%             % error(['No Gain Compensation file:  ' TableGain.Dir TableGain.Name ]);
%         % end;

%   これでも、コンパイル版が通らないとのこと。
%   もう直接ファイルを呼ぶしかない。
%         try
%             disp(['try loading mat : ' DirNameGain]);
%             load(DirNameGain); % matファイルをload
%         catch
%             disp(['try failed --> read m-file : ' DirNameGainRoot]);
%             cwd1 = pwd;
%             cd(TableGain.Dir);
%             eval(DirNameGainRoot);  % m-fileを呼び出し　　8 Dec 2019
%             cd(cwd1)
%         end;
%



