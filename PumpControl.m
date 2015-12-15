function varargout = PumpControl(varargin)
% PUMPCONTROL MATLAB code for PumpControl.fig
%      PUMPCONTROL, by itself, creates a new PUMPCONTROL or raises the
%       existing singleton*.
%
%      H = PUMPCONTROL returns the handle to a new PUMPCONTROL or the
%       handle to the existing singleton*.
%
%      PUMPCONTROL('CALLBACK',hObject,eventData,handles,...) calls the
%       local function named CALLBACK in PUMPCONTROL.M with the given
%       input arguments.
%
%      PUMPCONTROL('Property','Value',...) creates a new PUMPCONTROL or 
%       raises the existing singleton*.  Starting from the left, property 
%       value pairs are applied to the GUI before PumpControl_OpeningFcn 
%       gets called.  An unrecognized property name or invalid value makes 
%       property application stop.  All inputs are passed to 
%       PumpControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only 
%       one instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 31-Oct-2012 16:33:52

%%%%%%%% Begin initialization code - DO NOT EDIT %%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PumpControl_OpeningFcn, ...
                   'gui_OutputFcn',  @PumpControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%%%%%%%% End initialization code - DO NOT EDIT %%%%%%%%%%%%%%%%%%%%%%%%%%%

end

% --- Executes just before PumpControl is made visible.
function PumpControl_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PumpControl (see VARARGIN)

% Choose default command line output for PumpControl
handles.output = hObject;

% INITIALIZE THE PUMP
[handles.c handles.s] = initializePump;

% CREATE A TIMER OBJECT THAT TRIGGERS AT 1 SECOND INTERVALS
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', 1, ...                        % Initial period is 1 sec.
    'TimerFcn', {@pumpCheck,hObject});      % Specify callback function

% UPDATE HANDLES STRUCTURE
guidata(hObject, handles);

end

% --- Outputs from this function are returned to the command line.
function varargout = PumpControl_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end

% --- Executes on button press in initializeButton.
function initializeButton_Callback(hObject, ~, handles) %#ok<*DEFNU>
% hObject    handle to initializeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% REMOVE THE INITIALIZE BUTTON, MAKE REST OF GUI VISIBLE
set(handles.pumpLight,'Visible','on');
set(handles.infuseButton,'Visible','on');
set(handles.stopButton,'Visible','on');
set(handles.reverseButton,'Visible','on');
set(handles.rateTitle,'Visible','on');
set(handles.pumpRate,'Visible','on');
set(handles.rateSlider,'Visible','on');
set(handles.bolusButton,'Visible','on');
set(handles.syringeLow,'Visible','on');
set(handles.resetButton,'Visible','on');
set(handles.volumeDispensed,'Visible','on');
set(handles.initializeButton,'Visible','off');

scatter(handles.pumpLight,.5,.5,1200,'o',...                                % SET UP PUMP INDICATOR
    'MarkerEdgeColor','k','MarkerFaceColor',[.5 .5 .5]);
axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);

scatter(handles.syringeLow,.5,.5,1200,'^',...                               % SET UP LOW WARNING
    'MarkerEdgeColor','k','MarkerFaceColor',[.5 .5 .5]);
axis(handles.syringeLow,[0 1 0 1]); bkgd = [.931 .931 .931];
set(handles.syringeLow,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);

if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % START THE TIMER

guidata(hObject, handles);                                                  % UPDATE HANDLES

end

% --- Executes on button press in infuseButton.
function infuseButton_Callback(~, ~, handles)
% hObject    handle to infuseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

cmd = sprintf('%s STP',handles.c.a);                                        % STOP THE PUMP
fprintf(handles.s,cmd); pause(.05);
cmd = sprintf('%s DIR INF',handles.c.a);                                    % SET PUMP TO INFUSE
fprintf(handles.s,cmd); pause(.05);
if str2double(get(handles.pumpRate,'String')) > 0                           % IF PUMP RATE > ZERO
    cmd = sprintf('%s RUN',handles.c.a);                                    % START THE PUMP
    fprintf(handles.s,cmd); pause(.05);
    
    scatter(handles.pumpLight,.5,.5,1200,'o',...                            % GREEN PUMP INDICATOR
        'MarkerEdgeColor','k','MarkerFaceColor',[0 1 0]);
    axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
    set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);
end

if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER

end

% --- Executes on button press in stopButton.
function stopButton_Callback(~, ~, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

cmd = sprintf('%s STP',handles.c.a);                                        % STOP THE PUMP
fprintf(handles.s,cmd); pause(.05);
cmd = sprintf('%s DIR INF',handles.c.a);                                    % SET PUMP TO INFUSE
fprintf(handles.s,cmd); pause(.05);

scatter(handles.pumpLight,.5,.5,1200,'o',...                                % GRAY PUMP INDICATOR
    'MarkerEdgeColor','k','MarkerFaceColor',[.5 .5 .5]);
axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);

if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER

end

% --- Executes on button press in reverseButton.
function reverseButton_Callback(~, ~, handles)
% hObject    handle to reverseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

cmd = sprintf('%s STP',handles.c.a);                                        % STOP THE PUMP
fprintf(handles.s,cmd); pause(.05);
cmd = sprintf('%s DIR WDR',handles.c.a);                                    % SET PUMP TO REVERSE
fprintf(handles.s,cmd); pause(.05);
cmd = sprintf('%s RUN',handles.c.a);                                        % START THE PUMP
fprintf(handles.s,cmd); pause(.05);
if str2double(get(handles.pumpRate,'String')) > 0                           % IF PUMP RATE > ZERO
    cmd = sprintf('%s RUN',handles.c.a);                                    % START THE PUMP
    fprintf(handles.s,cmd); pause(.05);
    
    scatter(handles.pumpLight,.5,.5,1200,'o',...                            % RED PUMP INDICATOR
        'MarkerEdgeColor','k','MarkerFaceColor',[1 0 .1]);
    axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
    set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);
end

if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER

end

% --- Executes on slider movement.
function rateSlider_Callback(hObject, ~, handles)
% hObject    handle to rateSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

pumpRate = num2str(round(get(hObject,'Value')*handles.c.maxRate));          % GET PUMP RATE
set(handles.pumpRate,'String',pumpRate);                                    % UPDATE RATE TEXT

while handles.s.BytesAvailable > 0                                          % CLEAR PUMP BUFFER
    fscanf(handles.s,'%s',handles.s.BytesAvailable);
end
cmd = sprintf('%s',handles.c.a);                                            % QUERY THE PUMP
fprintf(handles.s,cmd); pause(.05);
str = fscanf(handles.s,'%s',handles.s.BytesAvailable);
if any(strcmp(str(4),{'I' 'W'}))                                            % IF PUMP WAS RUNNING
    cmd = sprintf('%s STP',handles.c.a);                                    % STOP IT
    fprintf(handles.s,cmd); pause(.05);
end
cmd = sprintf('%s RAT %s MH',handles.c.a,pumpRate);                         % UPDATE PUMP RATE
fprintf(handles.s,cmd); pause(.05);
if any(strcmp(str(4),{'I' 'W'}))                                            % IF PUMP WAS RUNNING
    if ~strcmp(pumpRate,'0')                                                % AND PUMP RATE > ZERO
        cmd = sprintf('%s RUN',handles.c.a);                                % RESTART IT
        fprintf(handles.s,cmd); pause(.05);
    else                                                                    % ELSE
        scatter(handles.pumpLight,.5,.5,1200,'o',...                        % GRAY PUMP INDICATOR
            'MarkerEdgeColor','k','MarkerFaceColor',[.5 .5 .5]);
        axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
        set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);
    end
end

if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER

end

% --- Executes during object creation, after setting all properties.
function rateSlider_CreateFcn(hObject, ~, ~)
% hObject    handle to rateSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

function pumpRate_Callback(hObject, ~, handles)
% hObject    handle to pumpRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pumpRate as text
%        str2double(get(hObject,'String')) returns contents of pumpRate as a double

if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

pumpRate = abs(round(real(str2double(get(hObject,'String')))));             % GET PUMP RATE
if isnan(pumpRate); pumpRate = 0; end;
pumpRate = num2str(min(pumpRate,handles.c.maxRate));
set(hObject,'String',pumpRate);                                             % UPDATE RATE TEXT

while handles.s.BytesAvailable > 0                                          % CLEAR PUMP BUFFER
    fscanf(handles.s,'%s',handles.s.BytesAvailable);
end
cmd = sprintf('%s',handles.c.a);                                            % QUERY THE PUMP
fprintf(handles.s,cmd); pause(.05);
str = fscanf(handles.s,'%s',handles.s.BytesAvailable);
if any(strcmp(str(4),{'I' 'W'}))                                            % IF PUMP WAS RUNNING
    cmd = sprintf('%s STP',handles.c.a);                                    % STOP IT
    fprintf(handles.s,cmd); pause(.05);
end
cmd = sprintf('%s RAT %s MH',handles.c.a,pumpRate);                         % UPDATE PUMP RATE
fprintf(handles.s,cmd); pause(.05);
if any(strcmp(str(4),{'I' 'W'}))                                            % IF PUMP WAS RUNNING
    if ~strcmp(pumpRate,'0')                                                % AND PUMP RATE > ZERO
        cmd = sprintf('%s RUN',handles.c.a);                                % RESTART IT
        fprintf(handles.s,cmd); pause(.05);
    else                                                                    % ELSE
        scatter(handles.pumpLight,.5,.5,1200,'o',...                        % GRAY PUMP INDICATOR
            'MarkerEdgeColor','k','MarkerFaceColor',[.5 .5 .5]);
        axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
        set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);
    end
end

if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER

end

% --- Executes during object creation, after setting all properties.
function pumpRate_CreateFcn(hObject, ~, ~)
% hObject    handle to pumpRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% SET RATE TEXT
set(hObject,'String','0');

end

% --- Executes on button press in bolusButton.
function bolusButton_Callback(~, ~, handles)
% hObject    handle to bolusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

scatter(handles.pumpLight,.5,.5,1200,'o',...                                % WHITE PUMP INDICATOR
    'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1]);
axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);

while handles.s.BytesAvailable > 0                                          % CLEAR PUMP BUFFER
    fscanf(handles.s,'%s',handles.s.BytesAvailable);
end
cmd = sprintf('%s RAT',handles.c.a);                                        % QUERY THE PUMP
fprintf(handles.s,cmd); pause(.05);
rateString = fscanf(handles.s,'%s',handles.s.BytesAvailable);
if any(strcmp(rateString(4),{'I' 'W'}))                                     % IF PUMP WAS RUNNING
    cmd = sprintf('%s STP',handles.c.a);                                    % STOP IT
    fprintf(handles.s,cmd); pause(.05);
end
cmd = sprintf('%s RAT 2100 MH',handles.c.a);                                % PUMP RATE AT MAX
fprintf(handles.s,cmd); pause(.05);
set(handles.pumpRate,'String','2100');
cmd = sprintf('%s DIR INF',handles.c.a);                                    % SET PUMP TO INFUSE
fprintf(handles.s,cmd); pause(.05);
cmd = sprintf('%s RUN',handles.c.a);                                        % RUN PUMP FOR 1.75s
fprintf(handles.s,cmd); pause(1.75);
cmd = sprintf('%s STP',handles.c.a);                                        % STOP THE PUMP
fprintf(handles.s,cmd); pause(.05);
pumpRate = num2str(str2double(rateString(5:9)));                            % RESTORE PUMP RATE
cmd = sprintf('%s RAT %s %s',handles.c.a,pumpRate,rateString(10:11));
fprintf(handles.s,cmd); pause(.05);
set(handles.pumpRate,'String',pumpRate);
if any(strcmp(rateString(4),{'I' 'W'}))                                     % IF PUMP WAS RUNNING
    cmd = sprintf('%s RUN',handles.c.a);                                    % RESTART IT
    fprintf(handles.s,cmd); pause(.05);
    
    switch rateString(4)                                                    % RESTORE PUMP INDICATOR
        case 'I'
            scatter(handles.pumpLight,.5,.5,1200,'o',...
                'MarkerEdgeColor','k','MarkerFaceColor',[0 1 0]);
        case 'W'
            scatter(handles.pumpLight,.5,.5,1200,'o',...
                'MarkerEdgeColor','k','MarkerFaceColor',[1 0 .1]);
    end
    axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
    set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);
else                                                                        % ELSE
    scatter(handles.pumpLight,.5,.5,1200,'o',...                            % GRAY PUMP INDICATOR
        'MarkerEdgeColor','k','MarkerFaceColor',[.5 .5 .5]);
    axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
    set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);
end

if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER

end

% --- Executes on button press in resetButton.
function resetButton_Callback(~, ~, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

cmd = sprintf('%s CLD INF',handles.c.a);                                    % CLEAR DISPENSED VOLUMES
fprintf(handles.s,cmd); pause(.05);
cmd = sprintf('%s CLD WDR',handles.c.a);
fprintf(handles.s,cmd); pause(.05);

scatter(handles.syringeLow,.5,.5,1200,'^',...                               % RESET SYRINGE WARNING
    'MarkerEdgeColor','k','MarkerFaceColor',[.5 .5 .5]);
axis(handles.syringeLow,[0 1 0 1]); bkgd = [.931 .931 .931];
set(handles.syringeLow,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);

if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER

end

% --- Executes on button press in exitButton.
function exitButton_Callback(~, ~, handles)
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
delete(handles.timer);                                                      % REMOVE THE TIMER

cmd = sprintf('%s STP',handles.c.a);                                        % STOP THE PUMP
fprintf(handles.s,cmd); pause(.05);
cmd = sprintf('%s DIR INF',handles.c.a);                                    % SET PUMP TO INFUSE
fprintf(handles.s,cmd); pause(.05);

fclose(handles.s); delete(handles.s);                                       % REMOVE THE PUMP

close PumpControl;                                                          % REMOVE THE GUI

end

% --- Called upon GUI creation
function [c s] = initializePump

% THIS FUNCTION CONTAINS SETTINGS FOR THE PUMP AND SYRINGE.
% THESE VALUES MAY NEED TO BE UPDATED FOR ANY CHANGES TO THE SYRINGE, 
% THE PUMP, OR THE CONNECTION TO THE COMPUER!

% SYRINGE PARAMETERS
c.volume = 60;              % ml
c.diameter = 29.7;          % mm
c.maxRate = 2100;           % ml/hour
% PUMP PARAMETERS
c.comPort = 'COM4';         % This should be checked on the computer
c.baudRate = 19200;         % Baudrate, check with the pump settings
c.terminator = 'CR/LF';     % carriage return / line feed
c.address = 0;              % Address, check with the pump settings
c.a = '0';                  % Shorter address, as string for quick reference

s = serial(c.comPort,'BaudRate',c.baudRate,'Terminator',c.terminator);      % OPEN THE PUMP
fopen(s);

cmd = sprintf('%s STP',c.a);                                                % STOP THE PUMP
fprintf(s,cmd); pause(.05);
cmd = sprintf('%s CLD INF',c.a);                                            % CLEAR DISPENSED VOLUMES
fprintf(s,cmd); pause(.05);
cmd = sprintf('%s CLD WDR',c.a);
fprintf(s,cmd); pause(.05);
cmd = sprintf('%s DIA %s *',c.a,num2str(c.diameter));                       % ASSIGN SYRINGE DIAMETER
fprintf(s,cmd); pause(.05);
cmd = sprintf('%s VOL %s',c.a,num2str(c.volume));                           % ASSIGN SYRINGE VOLUME
fprintf(s,cmd); pause(.05);
cmd = sprintf('%s VOL ML',c.a);
fprintf(s,cmd); pause(.05);
cmd = sprintf('%s DIR INF',c.a);                                            % SET PUMP TO INFUSE
fprintf(s,cmd); pause(.05);
cmd = sprintf('%s RAT 0 MH',c.a);                                           % SET ZERO PUMP RATE
fprintf(s,cmd); pause(.05);

disp('Pump is initialized!');

end

% --- Executes on timer process
function pumpCheck(~, ~, hfigure)

handles = guidata(hfigure);                                                 % GET HANDLES STRUCTURE

while handles.s.BytesAvailable > 0                                          % CLEAR PUMP BUFFER
    fscanf(handles.s,'%s',handles.s.BytesAvailable);
end
cmd = sprintf('%s DIS',handles.c.a);                                        % QUERY THE PUMP
fprintf(handles.s,cmd); pause(.05);
str = fscanf(handles.s,'%s',handles.s.BytesAvailable);

if strcmp(str(4),'W')                                                       % IF PUMP IS IN REVERSE
    cmd = sprintf('%s STP',handles.c.a);                                    % STOP THE PUMP
    fprintf(handles.s,cmd); pause(.05);
    cmd = sprintf('%s DIR INF',handles.c.a);                                % SET PUMP TO INFUSE
    fprintf(handles.s,cmd); pause(.05);
    
    scatter(handles.pumpLight,.5,.5,1200,'o',...                            % RED PUMP INDICATOR
        'MarkerEdgeColor','k','MarkerFaceColor',[1 0 .1]);
    axis(handles.pumpLight,[0 1 0 1]); bkgd = [.931 .931 .931];
    set(handles.pumpLight,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);
    
    sound(repmat([sin(1:2000) zeros(1,2000)],1,3),3000);                    % TRIPLE BEEP WARNING
end

volumeDispensed = str2double(str(6:10));                                    % UPDATE VOLUME DISPENSED
volumeString = sprintf('%s mL dispensed',num2str(volumeDispensed));
set(handles.volumeDispensed,'String',volumeString);

if volumeDispensed > .9*handles.c.volume                                    % IF SYRINGE IS 90+% DONE
    scatter(handles.syringeLow,.5,.5,1200,'^',...                           % BLUE SYRINGE WARNING
        'MarkerEdgeColor','k','MarkerFaceColor','b');
    axis(handles.syringeLow,[0 1 0 1]); bkgd = [.931 .931 .931];
    set(handles.syringeLow,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);
    
    sound(sin(1:2000),3000);                                                % SINGLE BEEP WARNING
end

end
