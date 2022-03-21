function demoai_acoustic(varargin)
%DEMOAI_ACOUSTIC FFT/3rd octave display of an incoming analog input signal.
%
%    DEMOAI_ACOUSTIC creates an analog input object associated with the 
%    winsound adaptor with device identification 0.  The incoming 
%    signal and the fft of the incoming signal of the created analog 
%    input object are plotted.
%
%    DEMOAI_ACOUSTIC('ADAPTORNAME', ID, CHANID) creates an analog input object
%    associated with adaptor, ADAPTORNAME, with device identification,
%    ID.  A channel is assigned to the hardware channels specified in 
%    scalar CHANID.  The incoming signal from the created analog input
%    object and the fft of the incoming signal are both plotted.
%
%    The plot is continuously updated by programming the TimerFcn
%    property to plot the results from either GETDATA or PEEKDATA every 
%    0.1 seconds (GETDATA is called for the initial plot).
%
%    Examples:
%      demoai_acoustic
%      demoai_acoustic('winsound', 0, 1);
%       

% Copyright 1998 - 2002 The MathWorks, Inc
%    MP 11-23-98
%    $Revision: 1.4 $  $Date: 2000/03/17 19:37:54 $
%
%    SMH 10-15-00
%    $Revision: 1.5 $  $Date: ~2000/10/15.
%       Add 3rd-octave analysis


% Error if an output argument is supplied.
if nargout > 0
   error('Too many output arguments.');
end

% Based on the number of input arguments call the appropriate 
% local function.
switch nargin
case 0
   % Create the analog input object.
   data = localInitAI;

   % Create the  figure.
   data = localInitFig(data);
   hFig = data.handle.figure;
   
case 1
   error('The ADAPTORNAME, ID and CHANID must be specified.');
case 2
   % Initialize variables.
   data = [];
   action=varargin{1};
   hFig=varargin{2};
   
   % This may fail if only the ADAPTORNAME and ID were input.  However,
   % if the ID was 0, this will work.
   try
      data=get(hFig,'UserData');
   end      
   
   % DATA will be empty if CHANID was not specified or if ID = 0.
   if isempty(data)
      error('The CHANID must be specified.');
   end
   
   % Based on the action, call the appropriate local function.
   switch action
   case 'close'
      localClose(data);
   case 'stop'
      data = localStop(data);
   end
case 3
   % TimerFcn called.
   if isa(varargin{1}, 'daqdevice')
      obj = varargin{1};
      event = varargin{2};
      localfftShowData(obj, event);
      return;
   else
      % User specified the input - adaptor, id, chanNum.
      % Create the analog input object.
      [data, errflag] = localInitAI(varargin{:});
      if errflag
         error(lasterr)
      end
      
      % Create the  figure.
      data = localInitFig(data);
      hFig = data.handle.figure;
   end
end

% Update the figure's UserData.
if ~isempty(hFig)&ishandle(hFig),
   set(hFig,'UserData',data);
end

% Update the analog input object's UserData.
if isvalid(data.ai)
   set(data.ai, 'UserData', data);
end

% ***********************************************************************   
% Create the object and get the first fft.
function [data, errflag] = localInitAI(varargin)

% Initialize variables.
errflag = 0;
data = [];

% Either no input arguments or all three - ADAPTORNAME, ID and CHANNELID.
switch nargin
case 0
   adaptor = 'winsound';
   id = 0;
   chan = 1;
case 3
   adaptor = varargin{1};
   id = varargin{2};
   chan = varargin{3};
otherwise
   lasterr('The ADAPTORNAME, ID and CHANID must be specified.');
   errflag = 1;
   return;
end

% Error if more than one channel was specified.
if length(chan) > 1
   lasterr('Only a single channel can be created.');
   errflag = 1;
   return
end

% Channel 2 for sound card is not allowed.
if strcmp(lower(adaptor), 'winsound') & chan == 2
   warning('Channel 1 must be used for device Winsound.');
   chan = 1;
end

% Object Configuration.
% Create an analog input object with one channel.
ai = analoginput(adaptor, id);
addchannel(ai, chan);

% Configure the analog input object.
set(ai, 'SampleRate', 44100);

% Configure the analog input object to trigger manually twice.
set(ai, 'SamplesPerTrigger', 1024);
set(ai, 'TriggerRepeat', 1);
set(ai, 'TriggerType', 'manual');

% Initialize callback parameters.  The TimerFcn is initialized 
% after figure has been created.
set(ai, 'TimerPeriod',.05);  

% Object Execution.
% Start the analog input object.
start(ai);
trigger(ai);

% Obtain the available time and data.
[d,time] = getdata(ai, ai.SamplesPerTrigger);

% Calculate the fft.
Fs = get(ai, 'SampleRate');
blockSize = get(ai, 'SamplesPerTrigger');
[f,mag] = localDaqfft(d,Fs,blockSize);

% Compute third octave
[B,A] = oct3bank;			%Generate filters
[P,F] = oct3filt(B,A,d); 	%Implement filters
%Filter the signal


% Update the data structure.
data.ai = ai;
data.getdata = [d time];
data.daqfft = [f mag];
data.handle = [];
data.octave.B = B;
data.octave.A = A;
data.octave.P = P + 94;     %Reference to 20 muV instead of 1 V
data.octave.F = F;

% Set the object's UserData to data.
set(data.ai, 'UserData', data);

% ***********************************************************************   
% Create the display.
function data = localInitFig(data)

% Initialize variables.
btnColor=get(0,'DefaultUIControlBackgroundColor');

% Position the GUI in the middle of the screen
screenUnits=get(0,'Units');
set(0,'Units','pixels');
screenSize=get(0,'ScreenSize');
set(0,'Units',screenUnits);
figWidth=600;
figHeight=500;
figPos=[(screenSize(3)-figWidth)/2 (screenSize(4)-figHeight)/2  ...
      figWidth                    figHeight];
% Create the figure window.
hFig=figure(...                    
   'Color'             ,btnColor                 ,...
   'IntegerHandle'     ,'off'                    ,...
   'DoubleBuffer'      ,'on'                     ,...
   'DeleteFcn'         ,'demoai_acoustic(''close'',gcbf)',...
   'MenuBar'           ,'none'                   ,...
   'HandleVisibility'  ,'on'                     ,...
   'Name'              ,'Analog Input FFT and 3rd Octave demo'  ,...
   'Tag'               ,'Analog Input FFT demo'  ,...
   'NumberTitle'       ,'off'                    ,...
   'Units'             ,'pixels'                 ,...
   'Position'          ,figPos                   ,...
   'UserData'          ,[]                       ,...
   'Colormap'          ,[]                       ,...
   'Pointer'           ,'arrow'                  ,...
   'Visible'           ,'off'                     ...
   );

% Create Data subplot.
hAxes(1) = axes(...
   'Position'          , [0.1300 0.75 0.7750 0.2],...
   'Parent'            , hFig,...
   'XLim'              , [0 get(data.ai, 'SamplesPerTrigger')],...
   'YLim'              , [-0.5 0.5]...
   );

% Plot the data.
hLine(1) = plot(data.getdata(:,1));
set(hAxes(1), 'XLim', [0 get(data.ai, 'SamplesPerTrigger')]);

% Label the plot.
xlabel('Sample');
ylabel('Analog Input (Volts)');
title('Analog Data Acquisition');

% Create the FFT subplot.
hAxes(2) = axes(...
   'Position'          , [0.1300 0.4400 0.7750 0.20],...
   'Parent'            , hFig,...
   'XLim'              , [0 max(data.daqfft(:,1))]...
   );

% Plot the data.
hLine(2) = plot(data.daqfft(:,1),data.daqfft(:,2));
set(hAxes(2), 'XLim', [0 max(data.daqfft(:,1))]);

% Label the plot.
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');



% Create the Octave subplot.
hAxes(3) = axes(...
   'Position'          , [0.1300 0.1100 0.7750 0.20],...
   'Parent'            , hFig,...
   'XLim'              , [0 length(data.octave.F)+1]...
   );

% Plot the data.
colorselect = 'k' ;
hLine(3) = bar(data.octave.P,colorselect);
set(hLine(3),'FaceColor','b');

%hLine(3) = plot(data.octave.P);
set(hAxes(3), 'XLim', [0 length(data.octave.F)+1]);
	set(hAxes(3),'XTick',[2:3:18]); 		% Label frequency axis on octaves. 
	set(hAxes(3),'XTickLabel',data.octave.F(2:3:length(data.octave.F)));

	% Label the plot.
	xlabel('Frequency band [Hz]'); ylabel('Power [dB re 20muV]');
%	title('One-third-octave spectrum')



% Create a start/stop pushbutton.
htoggle = uicontrol(...
   'Parent'          , hFig,...
   'Style'           , 'pushbutton',...
   'Units'           , 'normalized',...
   'Position'        , [0.0150 0.0111 0.1 0.0556],...
   'Value'           , 1,...
   'String'          , 'Stop',...
   'Callback'        , 'demoai_acoustic(''stop'', gcbf);');

hmenu(1) = uimenu('Parent', hFig,...
   'Label', 'File');
hmenu(2) = uimenu(hmenu(1),...
   'Label', 'Close demoai_acoustic',...
   'Callback', 'demoai_acoustic(''close'',gcbf)');
hmenu(3) = uimenu('Parent', hFig,...
   'Label', 'Help');
hmenu(4) = uimenu(hmenu(3),...
   'Label', 'Data Acquisition Toolbox',...
   'Callback', 'helpwin(''daq'')');
hmenu(5) = uimenu(hmenu(3),...
   'Label', 'demoai_acoustic',...
   'Callback', 'helpwin(''demoai_acoustic'')');

% Store the handles in the data matrix.
data.handle.figure = hFig;
data.handle.axes = hAxes;
data.handle.line = hLine;
data.handle.toggle = htoggle;
data.state = 0;

% Set the axes handlevisibility to off.
%set(hAxes, 'HandleVisibility', 'off');
set(hAxes, 'HandleVisibility', 'callback');

% Store the data matrix and display figure.
%set(hFig,'Visible','on','UserData',data,'HandleVisibility', 'off');
set(hFig,'Visible','on','UserData',data,'HandleVisibility', 'callback');

% Configure the callback to update the display.
set(data.ai, 'TimerFcn', {'demoai_acoustic', 'fftshowdata'});

% ***********************************************************************  
% Close the figure window.
function localClose(data)

% Stop the device if it is running and delete the object.
if isvalid(data.ai)
   if strcmp(get(data.ai, 'Running'), 'On')
      stop(data.ai);
   end
   delete(data.ai);
end

% Close the figure window.
delete(data.handle.figure);

% ***********************************************************************  
% Stop or start the device.
function data = localStop(data)

% Based on the state either stop or start.
if data.state == 0
   % Stop the device.
   stop(data.ai);
   set(data.handle.toggle, 'String', 'Start');
   
   % Store the new state.
   data.state = 1;
else
   % Toggle the Start/Stop string.
   set(data.handle.toggle, 'String', 'Stop');
   
   % Store the new state.
   data.state = 0;
   
   % Start the device.
   start(data.ai);
end

% ***********************************************************************  
% Calculate the fft of the data.
function [f, mag] = localDaqfft(data,Fs,blockSize)

% Calculate the fft of the data.
xFFT = fft(data);
xfft = abs(xFFT);

% Avoid taking the log of 0.
index = find(xfft == 0);
xfft(index) = 1e-17;

mag = 20*log10(xfft);
mag = mag(1:blockSize/2);

f = (0:length(mag)-1)*Fs/blockSize;
f = f(:);

% ***********************************************************************  
% Update the plot.
function localfftShowData(obj,event)

% Get the handles.
data = obj.UserData;

hFig = data.handle.figure;
hAxes = data.handle.axes;
hLine = data.handle.line;

% Execute a peekdata.
x = peekdata(obj, obj.SamplesPerTrigger);

% FFT calculation.
Fs = obj.SampleRate;
blockSize = obj.SamplesPerTrigger;
[f,mag] = localDaqfft(x,Fs,blockSize);

%Third octave calculation
[P,F] = oct3filt(data.octave.B,data.octave.A,x); 	%Implement filters

P=P+94;     %Reference to 20 muV instead of 1 V

% Dynamically modify Analog axis as we go.
maxX=max(x);
minX=min(x);
yax1=get(hAxes(1),'YLim');
if minX<yax1(1),
   yax1(1)=minX;
end
if maxX>yax1(2),
   yax1(2)=maxX;
end
set(hAxes(1),'YLim',yax1)

% Dynamically modify Frequency axis as we go.
maxF=max(f);
minF=min(f);
xax=get(hAxes(2),'XLim');
if minF<xax(1),
   xax(1)=minF;
end
if maxF>xax(2),
   xax(2)=maxF;
end
set(hAxes(2),'XLim',xax)

% Dynamically modify Magnitude axis as we go.
maxM=max(mag);
minM=min(mag);
yax2=get(hAxes(2),'YLim');
if minM<yax2(1),
   yax2(1)=minM;
end
if maxM>yax2(2),
   yax2(2)=maxM;
end
set(hAxes(2),'YLim',yax2)


% Dynamically modify 3rd Octave RMS axis as we go.
maxP=max(P);
minP=min(P);
yax3=get(hAxes(3),'YLim');
if minP<yax3(1),
   yax3(1)=minP;
end
if maxP>yax3(2),
   yax3(2)=maxP;
end
set(hAxes(3),'YLim',yax3)

% set(hAxes(3),'YLim',yax3,'HandleVisibility','on')
% set(hFig,'HandleVisibility','on');
% axes(hAxes(3));bar(P)
% set(hAxes(3), 'XLim', [0 length(data.octave.F)+1]);
% 	set(hAxes(3),'XTick',[2:3:18]); 		% Label frequency axis on octaves. 
% 	set(hAxes(3),'XTickLabel',data.octave.F(2:3:length(data.octave.F)));
% 
% 	% Label the plot.
% 	xlabel('Frequency band [Hz]'); ylabel('Power [dB]');
% set(hAxes(3),'HandleVisibility','off')
% set(hFig,'HandleVisibility','off');

% Update the plots.
set(hLine(1), 'YData', x(:,1));
set(hLine(2), 'XData', f(:,1), 'YData', mag(:,1));


%Build YData vector for bar plot
yd=kron(P(:),ones(5,1));
np=length(P)*5;
ind=[3:5:np 4:5:np 5:5:np]';
yd(ind)=0;
yd=[0;0;yd(1:end-1)];
%colors = 'rgbymckw';
%colorselect = randperm(length(colors));
set(hLine(3), 'YData', yd);%, ...
%     'FaceColor',colors(colorselect(1)), ...
%     'EdgeColor',colors(colorselect(2)));

drawnow;

function textstring = frequencystring(xv,yv);
textstring = {['Ampl: ' num2str(yv,'%2g') ' dB']
    ['f: ' num2str(xv,'%2g') ' Hz'];};
