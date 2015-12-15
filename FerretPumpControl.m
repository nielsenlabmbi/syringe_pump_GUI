function varargout = FerretPumpControl(varargin)
% FERRETPUMPCONTROL MATLAB code for FerretPumpControl.fig
%      FERRETPUMPCONTROL, by itself, creates a new FERRETPUMPCONTROL or raises the
%       existing singleton*.
%
%      H = FERRETPUMPCONTROL returns the handle to a new FERRETPUMPCONTROL or the
%       handle to the existing singleton*.
%
%      FERRETPUMPCONTROL('CALLBACK',hObject,eventData,handles,...) calls the
%       local function named CALLBACK in FERRETPUMPCONTROL.M with the given
%       input arguments.
%
%      FERRETPUMPCONTROL('Property','Value',...) creates a new FERRETPUMPCONTROL or 
%       raises the existing singleton*.  Starting from the left, property 
%       value pairs are applied to the GUI before FerretPumpControl_OpeningFcn 
%       gets called.  An unrecognized property name or invalid value makes 
%       property application stop.  All inputs are passed to 
%       FerretPumpControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only 
%       one instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 28-Apr-2014 14:26:17

%%%%%%%% Begin initialization code - DO NOT EDIT %%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FerretPumpControl_OpeningFcn, ...
                   'gui_OutputFcn',  @FerretPumpControl_OutputFcn, ...
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

%%%%%%%% THIS FUNCTION SETS DRUG AND PUMP PARAMETERS! %%%%%%%%%%%%%%%%%%%%
% --- Called upon GUI creation -------------------------------------------
function [c1,c2,s] = initializePump

% THIS FUNCTION CONTAINS SETTINGS FOR THE PUMP AND SYRINGE.
% THESE VALUES MAY NEED TO BE UPDATED FOR ANY CHANGES TO THE SYRINGE, 
% THE PUMP, OR THE CONNECTION TO THE COMPUER!

% SUBJECT INFORMATION
c1.subject.name =   input('subject name: ','s');
c1.subject.weight = round(100*input('weight (in kg): '))/100;

c2.subject = c1.subject;

% DRUG INFORMATION

c1.drug.name = 'Sufentanil';
c1.drug.concentration = 8.33';
c1.drug.units = 'mcg/mL';
c1.drug.doseUnits = 'mcg/kg/hr';
c1.drug.instructions = '10mL Sufenta (50mcg/mL) + 50mL Ringer';
c1.drug.doseFactor = c1.subject.weight/c1.drug.concentration;
c1.drug.doseMax = 30;
c1.drug.doseStep = 0.5;
c1.drug.doseInitial = 6;

c2.drug.name = 'LRS / Vencuronium';
c2.drug.concentration = 0.08;
c2.drug.units = 'mg/mL';
c2.drug.doseUnits = 'mg/kg/hr';
c2.drug.instructions = '5mL drug (1mg/mL) + 57.5mL Ringer';
c2.drug.doseFactor = c2.subject.weight/c2.drug.concentration;
c2.drug.doseMax = 1;
c2.drug.doseStep = 0.05;
c2.drug.doseInitial = 0.2;

% SYRINGE PARAMETERS
c1.syringe.volume = 60;         % in mL
c1.syringe.diameter = 29.7;     % in mm
c1.syringe.rateMax = 2100;      % in mL/hour

c2.syringe = c1.syringe;

% PUMP PARAMETERS, EVERYTHING EXCEPT ADDRESS SHOULD BE IDENTICAL
c1.pump.comPort = 'COM3';       % check this port on computer before running
c1.pump.baudRate = 19200;       % Baudrate, check with the pump settings
c1.pump.terminator = 'CR/LF';   % carriage return / line feed
c1.pump.address = 0;            % Address, check with the pump settings
c1.a = '0';                     % String address, for quick reference

c2.pump = c1.pump;
c2.pump.address = 1;
c2.a = '1';

alreadyOpen = instrfind('Type','serial');                                   % CLOSE ANY EXISTING SERIAL PORTS
if ~isempty(alreadyOpen); fclose(alreadyOpen); delete(alreadyOpen); end;

s = serial(c1.pump.comPort,'BaudRate',c1.pump.baudRate,...                  % OPEN THE PUMPS
    'Terminator',c1.pump.terminator);    fopen(s);

cmd = sprintf('%s STP',c1.a);                           sendCmd(s,cmd);     % STOP THE PUMPS
cmd = sprintf('%s STP',c2.a);                           sendCmd(s,cmd);
cmd = sprintf('%s CLD INF',c1.a);                       sendCmd(s,cmd);     % CLEAR DISPENSED VOLUMES
cmd = sprintf('%s CLD INF',c2.a);                       sendCmd(s,cmd);
cmd = sprintf('%s CLD WDR',c1.a);                       sendCmd(s,cmd);
cmd = sprintf('%s CLD WDR',c2.a);                       sendCmd(s,cmd);
cmd = sprintf('%s DIA %g',c1.a,c1.syringe.diameter);    sendCmd(s,cmd);     % ASSIGN SYRINGE DIAMETER
cmd = sprintf('%s DIA %g',c2.a,c2.syringe.diameter);    sendCmd(s,cmd);
cmd = sprintf('%s VOL %g',c1.a,c1.syringe.volume);      sendCmd(s,cmd);     % ASSIGN SYRINGE VOLUME
cmd = sprintf('%s VOL %g',c2.a,c2.syringe.volume);      sendCmd(s,cmd);
cmd = sprintf('%s VOL ML',c1.a);                        sendCmd(s,cmd);
cmd = sprintf('%s VOL ML',c2.a);                        sendCmd(s,cmd);
cmd = sprintf('%s DIR INF',c1.a);                       sendCmd(s,cmd);     % SET PUMP TO INFUSE
cmd = sprintf('%s DIR INF',c2.a);                       sendCmd(s,cmd);
cmd = sprintf('%s RAT 0 MH',c1.a);                      sendCmd(s,cmd);     % SET ZERO PUMP RATE
cmd = sprintf('%s RAT 0 MH',c2.a);                      sendCmd(s,cmd);

disp('Pumps are ready!');
end

% --- Executes just before FerretPumpControl is made visible. ------------
function FerretPumpControl_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FerretPumpControl (see VARARGIN)

% Choose default command line output for FerretPumpControl
handles.output = hObject;

%%%%%%%%%%%%%%%%%%%% ADDITIONAL INITIALIZATION CODE %%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE THE PUMP
[handles.c1,handles.c2,handles.s] = initializePump;

% GET DEFAULT PUMP DOSES
set(handles.doseTitle1,'String',['Dose (' handles.c1.drug.doseUnits ')']);
handles.c1.pumpDose = handles.c1.drug.doseInitial;
set(handles.pumpDose1,'String',num2str(handles.c1.pumpDose));
pumpRate = num2str(handles.c1.pumpDose*handles.c1.drug.doseFactor,3);
updateRate(handles.s,handles.c1.a,pumpRate,handles.pumpLight1);
set(handles.pumpRate1,'String',pumpRate);

%%%%%%%%%%%%%%%%% THIS ACTUALLY STARTS AS LRS, BUT CAN BE SWITCHED OVER TO VENC %%%%%%%%%%%%%%%%%%%%
changeLight(handles.VencLight,'o','w',0);
set(handles.doseTitle2,'String','Dose ( LRS )');
set(handles.drugInstructions2,'String','LRS + Dextrose, Comes Prepared');
% set(handles.doseTitle2,'String',['Dose (' handles.c2.drug.doseUnits ')']);
handles.c2.pumpDose = handles.c2.drug.doseInitial;
set(handles.pumpDose2,'String',num2str(handles.c2.pumpDose));
pumpRate = num2str(handles.c2.pumpDose*handles.c2.drug.doseFactor,3);
updateRate(handles.s,handles.c2.a,pumpRate,handles.pumpLight2);
set(handles.pumpRate2,'String',pumpRate);

% UPDATE SUBJECT INFORMATION
set(handles.subjectName,'String',handles.c1.subject.name);
set(handles.subjectWeight,'String',strcat(num2str(handles.c1.subject.weight),' kg'));

% MAKE THE EXIT BUTTON INVISIBLE UNTIL INITIATED
set(handles.exitButton,'Visible','off');

% CREATE A TIMER OBJECT THAT TRIGGERS AT 5 SECOND INTERVALS
handles.timer = timer(...
    'UserData', 0, ...                      % Indicates timer execution
    'ExecutionMode', 'fixedSpacing', ...    % Run timer repeatedly
    'Period', 5, ...                        % Initial period is 10 sec.
    'TimerFcn', {@pumpCheck,hObject});      % Specify callback function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% UPDATE HANDLES STRUCTURE
guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = FerretPumpControl_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes during object creation, after setting all properties.
function pumpDose1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function pumpDose2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in initializeButton.
function initializeButton_Callback(hObject, ~, handles) %#ok<*DEFNU>
% hObject    handle to initializeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% SET UP A DATA FILE
handles.fn = lower(strcat(handles.c1.subject.name,'.pd0'));
handles.fid = fopen(handles.fn,'a');
set(handles.fileName,'String',handles.fn);  % SET FILENAME TEXT
set(handles.editSave,'String',handles.fn);
set(handles.fileName,'UserData',1);         % SET GUI TO SAVE DATA TO FILE
% Text strings to write to the file!
c = fix(clock);
tempString = sprintf('%g-%g-%g, (DMY), %g:%g:%g, (HMS), %s, %g kg\n',c(3:-1:1),c(4:6),handles.c1.subject.name,handles.c1.subject.weight);
fprintf(handles.fid,tempString); disp(tempString);
tempString = sprintf('Pump 1 delivers %s at %g %s\n',handles.c1.drug.name,handles.c1.drug.concentration,handles.c1.drug.units);
fprintf(handles.fid,tempString); disp(tempString);
tempString = sprintf('Pump 1 default dose is %g %s\n',handles.c1.pumpDose,handles.c1.drug.units);
fprintf(handles.fid,tempString); disp(tempString);
tempString = sprintf('Pump 2 delivers %s at %g %s\n',handles.c2.drug.name,handles.c2.drug.concentration,handles.c2.drug.units);
fprintf(handles.fid,tempString); disp(tempString);
tempString = sprintf('Pump 2 default dose is %g %s\n',handles.c2.pumpDose,handles.c2.drug.units);
fprintf(handles.fid,tempString); disp(tempString);

% SET UP PUMP PANELS
set(handles.initializeButton,'Visible','off');                              % REMOVE INITIALIZE BUTTON
set(handles.exitButton,'Visible','on');                                     % ADD AN EXIT BUTTON
set(handles.pumpPanel1,'Title',handles.c1.drug.name);                       % SHOW PUMP PANEL 1
set(handles.drugInstructions1,'String',handles.c1.drug.instructions);
set(handles.pumpPanel1,'Visible','on');
set(handles.pumpPanel2,'Title',handles.c2.drug.name);                       % SHOW PUMP PANEL 2
% set(handles.drugInstructions2,'String',handles.c2.drug.instructions);
set(handles.pumpPanel2,'Visible','on');
changeLight(handles.pumpLight1,'o',[.5 .5 .5],0);                           % SET UP PUMP INDICATORS
changeLight(handles.pumpLight2,'o',[.5 .5 .5],0);
changeLight(handles.syringeLight1,'^',[.5 .5 .5],0);                        % SET UP SYRINGE INDICATORS
changeLight(handles.syringeLight2,'^',[.5 .5 .5],0);
set(handles.editSave,'Visible','on');

guidata(hObject, handles);                                                  % UPDATE HANDLES

if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % START THE TIMER

end

% --- Executes on button press in infuseButton1.
function infuseButton1_Callback(hObject, ~, handles)
% hObject    handle to infuseButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON
goFlag = changeLight(handles.pumpLight1);                                   % CHECK IF PUMP IS INFUSING
if ~goFlag && handles.c1.pumpDose > 0                                       % IF PUMP CAN BUT ISN'T INFUSING
    cmd = sprintf('%s RUN',handles.c1.a); sendCmd(handles.s,cmd);           % START THE PUMP
    changeLight(handles.pumpLight1,'o',[0 1 0],1);                          % GREEN PUMP INDICATOR
end
writeData(get(handles.fileName,'UserData'),handles.fid,'P1','RUN');         % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in infuseButton2.
function infuseButton2_Callback(hObject, ~, handles)
% hObject    handle to infuseButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

set(hObject,'Enable','off');                                                % DISABLE BUTTON
goFlag = changeLight(handles.pumpLight2);                                   % CHECK IF PUMP IS INFUSING
if ~goFlag && handles.c2.pumpDose > 0                                       % IF PUMP CAN BUT ISN'T INFUSING
    cmd = sprintf('%s RUN',handles.c2.a); sendCmd(handles.s,cmd);           % START IT
    changeLight(handles.pumpLight2,'o',[0 1 0],1);                          % GREEN PUMP INDICATOR
end
writeData(get(handles.fileName,'UserData'),handles.fid,'P2','RUN');         % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in stopButton1.
function stopButton1_Callback(hObject, ~, handles)
% hObject    handle to stopButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON
goFlag = changeLight(handles.pumpLight1);                                   % CHECK IF PUMP IS INFUSING
if goFlag                                                                   % IF PUMP IS INFUSING
    cmd = sprintf('%s STP',handles.c1.a); sendCmd(handles.s,cmd);           % STOP IT
    changeLight(handles.pumpLight1,'o',[.5 .5 .5],0);                       % GRAY PUMP INDICATOR
end
writeData(get(handles.fileName,'UserData'),handles.fid,'P1','STOP');        % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in stopButton2.
function stopButton2_Callback(hObject, ~, handles)
% hObject    handle to stopButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON
goFlag = changeLight(handles.pumpLight2);                                   % CHECK IF PUMP IS INFUSING
if goFlag                                                                   % IF PUMP IS INFUSING
    cmd = sprintf('%s STP',handles.c2.a); sendCmd(handles.s,cmd);           % STOP IT
    changeLight(handles.pumpLight2,'o',[.5 .5 .5],0);                       % GRAY PUMP INDICATOR
end
writeData(get(handles.fileName,'UserData'),handles.fid,'P2','STOP');        % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

function pumpDose1_Callback(hObject, ~, handles)
% hObject    handle to pumpDose1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

N = 1/handles.c1.drug.doseStep;                                             % FOR ROUNDING
pumpDose = round(N*abs(real(str2double(get(hObject,'String')))))/N;         % GET DOSE TO NEAREST DOSE STEP
if isnan(pumpDose); pumpDose = handles.c1.pumpDose; end;                    %   MUST BE A NUMBER
pumpDose = min(pumpDose,handles.c1.drug.doseMax);                           %   AND UNDER MAX DOSE
handles.c1.pumpDose = pumpDose; guidata(hObject, handles);                  % PLACE THE PUMP DOSE IN HANDLES
set(hObject,'String',num2str(handles.c1.pumpDose,4));                       % UPDATE DOSE TEXT

pumpRate = num2str(pumpDose*handles.c1.drug.doseFactor,3);                  % CONVERT DOSE TO RATE
updateRate(handles.s,handles.c1.a,pumpRate,handles.pumpLight1);             % UPDATE PUMP RATE
set(handles.pumpRate1,'String',pumpRate);                                   % UPDATE RATE TEXT

doseData = sprintf('DOSE TO %s',num2str(handles.c1.pumpDose,4));
writeData(get(handles.fileName,'UserData'),handles.fid,'P1',doseData);      % WRITE TO A FILE
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

function pumpDose2_Callback(hObject, ~, handles)
% hObject    handle to pumpDose2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER

N = 1/handles.c2.drug.doseStep;                                             % FOR ROUNDING
pumpDose = round(N*abs(real(str2double(get(hObject,'String')))))/N;         % GET DOSE TO NEAREST DOSE STEP
if isnan(pumpDose); pumpDose = handles.c2.pumpDose; end;                    %   MUST BE A NUMBER
pumpDose = min(pumpDose,handles.c2.drug.doseMax);                           %   AND UNDER MAX DOSE
handles.c2.pumpDose = pumpDose; guidata(hObject, handles);                  % PLACE THE PUMP DOSE IN HANDLES
set(hObject,'String',num2str(handles.c2.pumpDose,4));                       % UPDATE DOSE TEXT

pumpRate = num2str(pumpDose*handles.c2.drug.doseFactor,3);                  % CONVERT DOSE TO RATE
updateRate(handles.s,handles.c2.a,pumpRate,handles.pumpLight2);             % UPDATE PUMP RATE
set(handles.pumpRate2,'String',pumpRate);                                   % UPDATE RATE TEXT

doseData = sprintf('DOSE TO %s',num2str(handles.c2.pumpDose,4));
writeData(get(handles.fileName,'UserData'),handles.fid,'P2',doseData);      % WRITE TO A FILE
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in increaseDose1.
function increaseDose1_Callback(hObject, ~, handles)
% hObject    handle to increaseDose1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON

pumpDose = str2double(get(handles.pumpDose1,'String'));                     % GET CURRENT DOSE
pumpDose = min(handles.c1.drug.doseMax,pumpDose+handles.c1.drug.doseStep);  % INCREASE BY DOSE STEP
handles.c1.pumpDose = pumpDose; guidata(hObject, handles);                  % PLACE THE PUMP DOSE IN HANDLES
set(handles.pumpDose1,'String',num2str(handles.c1.pumpDose,4));             % UPDATE DOSE TEXT

pumpRate = num2str(pumpDose*handles.c1.drug.doseFactor,3);                  % CONVERT DOSE TO RATE
updateRate(handles.s,handles.c1.a,pumpRate,handles.pumpLight1);             % UPDATE PUMP RATE
set(handles.pumpRate1,'String',pumpRate);                                   % UPDATE RATE TEXT                           % UPDATE HANDLES

doseData = sprintf('DOSE TO %s',num2str(handles.c1.pumpDose,4));
writeData(get(handles.fileName,'UserData'),handles.fid,'P1',doseData);      % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in increaseDose2.
function increaseDose2_Callback(hObject, ~, handles)
% hObject    handle to increaseDose2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON

pumpDose = str2double(get(handles.pumpDose2,'String'));                     % GET CURRENT DOSE
pumpDose = min(handles.c2.drug.doseMax,pumpDose+handles.c2.drug.doseStep);  % INCREASE BY DOSE STEP
handles.c2.pumpDose = pumpDose; guidata(hObject, handles);                  % PLACE THE PUMP DOSE IN HANDLES
set(handles.pumpDose2,'String',num2str(handles.c2.pumpDose,4));             % UPDATE DOSE TEXT

pumpRate = num2str(pumpDose*handles.c2.drug.doseFactor,3);                  % CONVERT DOSE TO RATE
updateRate(handles.s,handles.c2.a,pumpRate,handles.pumpLight2);             % UPDATE PUMP RATE
set(handles.pumpRate2,'String',pumpRate);                                   % UPDATE RATE TEXT                                       % UPDATE HANDLES

doseData = sprintf('DOSE TO %s',num2str(handles.c2.pumpDose,4));
writeData(get(handles.fileName,'UserData'),handles.fid,'P2',doseData);      % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in decreaseDose1.
function decreaseDose1_Callback(hObject, ~, handles)
% hObject    handle to decreaseDose1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON

pumpDose = str2double(get(handles.pumpDose1,'String'));                     % GET CURRENT DOSE
pumpDose = max(0,pumpDose-handles.c1.drug.doseStep);                        % DECREASE BY DOSE STEP
handles.c1.pumpDose = pumpDose; guidata(hObject, handles);                  % PLACE THE PUMP DOSE IN HANDLES
set(handles.pumpDose1,'String',num2str(pumpDose,4));                        % UPDATE DOSE TEXT

pumpRate = num2str(pumpDose*handles.c1.drug.doseFactor,3);                  % CONVERT DOSE TO RATE
updateRate(handles.s,handles.c1.a,pumpRate,handles.pumpLight1);             % UPDATE PUMP RATE
set(handles.pumpRate1,'String',pumpRate);                                   % UPDATE RATE TEXT

doseData = sprintf('DOSE TO %s',num2str(handles.c1.pumpDose,4));
writeData(get(handles.fileName,'UserData'),handles.fid,'P1',doseData);      % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER

end
end

% --- Executes on button press in decreaseDose2.
function decreaseDose2_Callback(hObject, ~, handles)
% hObject    handle to decreaseDose2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON

pumpDose = str2double(get(handles.pumpDose2,'String'));                     % GET CURRENT DOSE
pumpDose = max(0,pumpDose-handles.c2.drug.doseStep);                        % DECREASE BY DOSE STEP
handles.c2.pumpDose = pumpDose; guidata(hObject, handles);                  % PLACE THE PUMP DOSE IN HANDLES
set(handles.pumpDose2,'String',num2str(pumpDose,4));                        % UPDATE DOSE TEXT

pumpRate = num2str(pumpDose*handles.c2.drug.doseFactor,3);                  % CONVERT DOSE TO RATE
updateRate(handles.s,handles.c2.a,pumpRate,handles.pumpLight2);             % UPDATE PUMP RATE
set(handles.pumpRate2,'String',pumpRate);                                   % UPDATE RATE TEXT

doseData = sprintf('DOSE TO %s',num2str(handles.c2.pumpDose,4));
writeData(get(handles.fileName,'UserData'),handles.fid,'P2',doseData);      % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER

end
end

% --- Executes on button press in bolusButton1.
function bolusButton1_Callback(hObject, ~, handles)
% hObject    handle to bolusButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON

goFlag = changeLight(handles.pumpLight1);                                   % IS PUMP RUNNING?
changeLight(handles.pumpLight1,'o','w',1);                                  % WHITE PUMP INDICATOR
updateRate(handles.s,handles.c1.a,'2100',handles.pumpLight1); pause(1.75);  % SET RATE AT MAX FOR 1.75s
pumpRate = num2str(handles.c1.pumpDose*handles.c1.drug.doseFactor,3);       % GET PUMP RATE
updateRate(handles.s,handles.c1.a,pumpRate,handles.pumpLight1);             % RESTORE PUMP RATE

if goFlag                                                                   % IF PUMP WAS RUNNING
    changeLight(handles.pumpLight1,'o',[0 1 0],goFlag);                     % GREEN PUMP INDICATOR
else                                                                        % OTHERWISE
    cmd = sprintf('%s STP',handles.c1.a); sendCmd(handles.s,cmd);           % STOP THE PUMP
    changeLight(handles.pumpLight1,'o',[.5 .5 .5],goFlag);                  % GRAY PUMP INDICATOR
end

writeData(get(handles.fileName,'UserData'),handles.fid,'P1','1 ML BOLUS');  % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in bolusButton2.
function bolusButton2_Callback(hObject, ~, handles)
% hObject    handle to bolusButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON

goFlag = changeLight(handles.pumpLight2);                                   % IS PUMP RUNNING?
changeLight(handles.pumpLight2,'o','w',1);                                  % WHITE PUMP INDICATOR
updateRate(handles.s,handles.c2.a,'2100',handles.pumpLight2); pause(1.75);  % SET RATE AT MAX FOR 1.75s
pumpRate = num2str(handles.c2.pumpDose*handles.c2.drug.doseFactor,3);       % GET PUMP RATE
updateRate(handles.s,handles.c2.a,pumpRate,handles.pumpLight2);             % RESTORE PUMP RATE

if goFlag                                                                   % IF PUMP WAS RUNNING
    changeLight(handles.pumpLight2,'o',[0 1 0],goFlag);                     % GREEN PUMP INDICATOR
else                                                                        % OTHERWISE
    cmd = sprintf('%s STP',handles.c2.a); sendCmd(handles.s,cmd);           % STOP THE PUMP
    changeLight(handles.pumpLight2,'o',[.5 .5 .5],goFlag);                  % GRAY PUMP INDICATOR
end

writeData(get(handles.fileName,'UserData'),handles.fid,'P2 ','1 ML BOLUS');  % WRITE TO A FILE
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in resetButton1.
function resetButton1_Callback(hObject, ~, handles)
% hObject    handle to resetButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON
handles.c1.syringe.volume = PumpReset;                                      % GET NEW SYRINGE VOLUME

goFlag = changeLight(handles.pumpLight1);                                   % IS PUMP RUNNING?
if goFlag;cmd = sprintf('%s STP',handles.c1.a);sendCmd(handles.s,cmd);end;  % IF SO STOP IT
cmd = sprintf('%s CLD INF',handles.c1.a); sendCmd(handles.s,cmd);           % CLEAR DISPENSED VOLUME
changeLight(handles.syringeLight1,'^',[.5 .5 .5],0);                        % RESET SYRINGE WARNING
if goFlag;cmd = sprintf('%s RUN',handles.c1.a);sendCmd(handles.s,cmd);end;  % RESTART PUMP IF APPROPRIATE

resetData = sprintf('SYRINGE REFILLED TO %g ML',handles.c1.syringe.volume);
writeData(get(handles.fileName,'UserData'),handles.fid,'P1',resetData);     % WRITE TO A FILE
guidata(hObject, handles);                                                  % UPDATE HANDLES
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in resetButton2.
function resetButton2_Callback(hObject, ~, handles)
% hObject    handle to resetButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
set(hObject,'Enable','off');                                                % DISABLE BUTTON
handles.c2.syringe.volume = PumpReset;                                      % GET NEW SYRINGE VOLUME

goFlag = changeLight(handles.pumpLight2);                                   % IS PUMP RUNNING?
if goFlag;cmd = sprintf('%s STP',handles.c2.a);sendCmd(handles.s,cmd);end;  % IF SO STOP IT
cmd = sprintf('%s CLD INF',handles.c2.a); sendCmd(handles.s,cmd);           % CLEAR DISPENSED VOLUME
changeLight(handles.syringeLight2,'^',[.5 .5 .5],0);                        % RESET SYRINGE WARNING
if goFlag;cmd = sprintf('%s RUN',handles.c2.a);sendCmd(handles.s,cmd);end;  % RESTART PUMP IF APPROPRIATE

resetData = sprintf('SYRINGE REFILLED TO %g ML',handles.c2.syringe.volume);
writeData(get(handles.fileName,'UserData'),handles.fid,'P2',resetData);     % WRITE TO A FILE
guidata(hObject, handles);                                                  % UPDATE HANDLES
set(hObject,'Enable','on');                                                 % ENABLE BUTTON
if strcmp(get(handles.timer,'Running'),'off'); start(handles.timer); end;   % RESTART THE TIMER
end
end

% --- Executes on button press in openPanel1.
function openPanel1_Callback(hObject, ~, handles)
set(handles.pumpPanel1,'Visible','on');                                     % Open panel 1
set(hObject,'Visible','off');                                               % Remove this button
end

% --- Executes on button press in openPanel2.
function openPanel2_Callback(hObject, ~, handles)
set(handles.pumpPanel2,'Visible','on');                                     % Open the panel 2
set(hObject,'Visible','off');                                               % Remove this button
end

% --- Executes on button press in closePanel1.
function closePanel1_Callback(~, ~, handles)
set(handles.openPanel1,'Visible','on');                                     % Add open panel button
set(handles.pumpPanel1,'Visible','off');                                    % Close panel 1
end

% --- Executes on button press in closePanel2.
function closePanel2_Callback(~, ~, handles)
set(handles.openPanel2,'Visible','on');                                     % Add open panel button
set(handles.pumpPanel2,'Visible','off');                                    % Close the panel 2
end

% --- Executes on button press in exitButton.
function exitButton_Callback(~, ~, handles)
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~get(handles.timer,'UserData')                                           % ONLY WHILE NOT TIMER
if strcmp(get(handles.timer,'Running'),'on'); stop(handles.timer); end;     % STOP THE TIMER
delete(handles.timer);                                                      % REMOVE THE TIMER

cmd = sprintf('%s STP',handles.c1.a); sendCmd(handles.s,cmd);               % STOP THE PUMPS
cmd = sprintf('%s STP',handles.c2.a); sendCmd(handles.s,cmd);

tempString = sprintf('Data saving stopped!\n\n');
fprintf(handles.fid,tempString); disp(tempString);
fclose(handles.fid);                                                        % CLOSE DATA FILE

fclose(handles.s); delete(handles.s);                                       % REMOVE THE PUMPS

close FerretPumpControl;                                                    % REMOVE THE GUI !!!!!! NOTE THIS NEEDS TO BE UPDATED MANUALLY IF THE GUI NAME CHANGES !!!!!!
close force;    % NECESSARY BECAUSE I DISABLED GUI CLOSING
fprintf('Pump control GUI is closed!\n');
end
end

% --- Executes on timer process
function pumpCheck(~, ~, hfigure)
handles = guidata(hfigure);                                                 % GET HANDLES STRUCTURE
set(handles.timer,'UserData',1);                                            % TIMER IS EXECUTING
writeFlag = get(handles.fileName,'UserData');

% CHECK ON PUMP 1
cmd = sprintf('%s RAT',handles.c1.a); str = sendCmd(handles.s,cmd,12);      % QUERY PUMP MOVEMENT

goFlag = changeLight(handles.pumpLight1);
switch str(4)                                                               % CHECK USER/PUMP MATCH
    case 'W'                                                                % IF IN REVERSE
        cmd = sprintf('%s STP',handles.c1.a); sendCmd(handles.s,cmd);       % STOP PUMP
        cmd = sprintf('%s DIR INF',handles.c1.a); sendCmd(handles.s,cmd);   % SET TO INFUSE
        if goFlag
            cmd = sprintf('%s RUN',handles.c1.a); sendCmd(handles.s,cmd);   % IF IT SHOULD, RUN PUMP
        end
        writeData(writeFlag,handles.fid,'P1','ERROR: SET TO REVERSE');      % WRITE ERROR TO FILE
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
        error = {'Pump 1 was in reverse!' 'Now set to infuse.'};            % WARNING MESSAGE
        PumpWarning('title','Go Mismatch','string',error);                  % WARNING POP-UP
        
    case 'I'                                                                % IF INFUSING
        if ~goFlag                                                          % BUT SHOULD BE STOPPED
            cmd = sprintf('%s STP',handles.c1.a); sendCmd(handles.s,cmd);   % STOP PUMP
            writeData(writeFlag,handles.fid,'P1','ERROR: PUMP RUNNING');    % WRITE ERROR TO FILE
            sound(sin(1:1000),3000);                                        % SINGLE BEEP
            error = {'Pump 1 was running!' 'Now stopped.'};                 % WARNING MESSAGE
            PumpWarning('title','Go Mismatch','string',error);              % WARNING POP-UP
        end
        
    case {'P' 'S'}                                                          % IF STOPPED
        cmd = sprintf('%s DIR INF',handles.c1.a);sendCmd(handles.s,cmd);    % ENSURE FORWARD DIRECTION
        if goFlag                                                           % BUT SHOULD BE INFUSING
            cmd = sprintf('%s RUN',handles.c1.a); sendCmd(handles.s,cmd);   % RUN PUMP
            writeData(writeFlag,handles.fid,'P1','ERROR: PUMP STOPPED');    % WRITE ERROR TO FILE
            sound(sin(1:1000),3000);                                        % SINGLE BEEP
            error = {'Pump 1 was stopped!' 'Now running.'};                 % WARNING MESSAGE
            PumpWarning('title','Go Mismatch','string',error);              % WARNING POP-UP
        end
        
    otherwise
        writeData(writeFlag,handles.fid,'P1','ERROR: UNKNOWN');             % WRITE ERROR TO FILE
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
        error = {'Pump 1 satus undefined!','Check hardware.'};              % WARNING MESSAGE
        PumpWarning('title','Go Mismatch','string',error);                  % WARNING POP-UP
end

userRate = handles.c1.pumpDose*handles.c1.drug.doseFactor;                  % GET USER SPECIFIED RATE
pumpRate = str2double(str(5:9));                                            % AND CURRENT PUMP RATE
if ~(abs(userRate-pumpRate) < .01 && strcmp(str(10:11),'MH'))               % IF RATES DISAGREE
    if goFlag; cmd = sprintf('%s STP',handles.c1.a); sendCmd(handles.s,cmd); end;
    cmd = sprintf('%s RAT %s MH',handles.c1.a,num2str(userRate,3)); sendCmd(handles.s,cmd); % SET TO USER RATE
    if goFlag; cmd = sprintf('%s RUN',handles.c1.a); sendCmd(handles.s,cmd); end;
    writeData(writeFlag,handles.fid,'P1','ERROR: PUMP RATE MISMATCH');      % WRITE ERROR TO FILE
    sound(sin(1:1000),3000);                                                % SINGLE BEEP
    error = {'Pump 1 rate =/= user rate!' 'Pump 1 set to user rate.'};      % WARNING MESSAGE
    PumpWarning('title','Rate Mismatch','string',error);                    % WARNING POP-UP
end

cmd = sprintf('%s DIS',handles.c1.a); str = sendCmd(handles.s,cmd,19);      % QUERY PUMP 1 VOLUME DISPENSED
volI = str2double(str(6:10));                                               % VOLUME INFUSED SINCE RESET
volS = handles.c1.syringe.volume - 2;                                       % VOLUME OF FULL SYRINGE (-2mL)
volR = volS - volI;                                                         % VOLUME REMAINING IN SYRINGE
volStr = sprintf('%s of %s mL dispensed', num2str(volI),num2str(volS));     % UPDATE VOLUME DISPENSED
set(handles.volumeDispensed1,'String',volStr);
tR = volR/userRate; if isinf(tR); tStr = ''; else                           % TIME REMAINING (IN HOURS)
tStr = sprintf('%g hr %g min left',floor(tR),floor(mod(60*tR,60))); end     % UPDATE TIME REMAINING
set(handles.timeLeft1,'String',tStr);

if tR < 1                                                                   % IF LESS THAN 1 HOUR LEFT
    lowFlag = changeLight(handles.syringeLight1);                           % GET WARNING STATE
    
    if lowFlag < 1 && tR > 0.5                                              % IF NO FLAG AND HALF+ HOUR LEFT
        changeLight(handles.syringeLight1,'^','b',1);                       % BLUE SYRINGE INDICATOR
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
        warn = {'Pump 1 has < 1 hour left!' 'Refill soon.'};                % WARNING STRING
        PumpWarning('title','Syringe Warning','string',warn);               % WARNING POP-UP
    end
    
    if lowFlag < 2 && tR < 0.5                                              % IF NO FLAG AND HALF- HOUR LEFT
        changeLight(handles.syringeLight1,'^','b',2);                       % BLUE SYRINGE INDICATOR
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
        warn = {'Pump 1 has < .5 hours left!' 'Refill now!'};               % WARNING STRING
        PumpWarning('title','Syringe Warning','string',warn);               % WARNING POP-UP
    end
    
    if lowFlag == 2                                                         % IF FLAGGED, KEEP ON BEEPING
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
    end
end

% CHECK ON PUMP 2
cmd = sprintf('%s RAT',handles.c2.a); str = sendCmd(handles.s,cmd,12);      % QUERY PUMP 1 MOVEMENT

goFlag = changeLight(handles.pumpLight2);

switch str(4)                                                               % CHECK USER/PUMP MATCH
    case 'W'                                                                % IF IN REVERSE
        cmd = sprintf('%s STP',handles.c2.a); sendCmd(handles.s,cmd);       % STOP PUMP
        cmd = sprintf('%s DIR INF',handles.c2.a); sendCmd(handles.s,cmd);   % SET TO INFUSE
        if goFlag
            cmd = sprintf('%s RUN',handles.c2.a); sendCmd(handles.s,cmd);   % IF IT SHOULD, RUN PUMP
        end
        writeData(writeFlag,handles.fid,'P2','ERROR: SET TO REVERSE');      % WRITE ERROR TO FILE
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
        error = {'Pump 2 was in reverse!' 'Now set to infuse.'};            % WARNING MESSAGE
        PumpWarning('title','Go Mismatch','string',error);                  % WARNING POP-UP
        
    case 'I'                                                                % IF INFUSING
        if ~goFlag                                                          % BUT SHOULD BE STOPPED
            cmd = sprintf('%s STP',handles.c2.a); sendCmd(handles.s,cmd);   % STOP PUMP
            writeData(writeFlag,handles.fid,'P2','ERROR: PUMP RUNNING');    % WRITE ERROR TO FILE
            sound(sin(1:1000),3000);                                        % SINGLE BEEP
            error = {'Pump 2 was running!' 'Now stopped.'};                 % WARNING MESSAGE
            PumpWarning('title','Go Mismatch','string',error);              % WARNING POP-UP
        end
        
    case {'P' 'S'}                                                          % IF STOPPED
        cmd = sprintf('%s DIR INF',handles.c2.a);sendCmd(handles.s,cmd);    % ENSURE FORWARD DIRECTION
        if goFlag                                                           % BUT SHOULD BE INFUSING
            cmd = sprintf('%s RUN',handles.c2.a); sendCmd(handles.s,cmd);   % RUN PUMP
            writeData(writeFlag,handles.fid,'P2','ERROR: PUMP STOPPED');    % WRITE ERROR TO FILE
            sound(sin(1:1000),3000);                                        % SINGLE BEEP
            error = {'Pump 2 was stopped!' 'Now running.'};                 % WARNING MESSAGE
            PumpWarning('title','Go Mismatch','string',error);              % WARNING POP-UP
        end
        
    otherwise
        writeData(writeFlag,handles.fid,'P2','ERROR: UNKNOWN');             % WRITE ERROR TO FILE
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
        error = {'Pump 2 satus undefined!','Check hardware.'};              % WARNING MESSAGE
        PumpWarning('title','Go Mismatch','string',error);                  % WARNING POP-UP
end

userRate = handles.c2.pumpDose*handles.c2.drug.doseFactor;                  % GET USER SPECIFIED RATE
pumpRate = str2double(str(5:9));                                            % AND CURRENT PUMP RATE
if ~(abs(userRate-pumpRate) < .01 && strcmp(str(10:11),'MH'))               % IF RATES DISAGREE
    if goFlag; cmd = sprintf('%s STP',handles.c2.a); sendCmd(handles.s,cmd); end;
    cmd = sprintf('%s RAT %s MH',handles.c2.a,num2str(userRate,3)); sendCmd(handles.s,cmd); % SET TO USER RATE
    if goFlag; cmd = sprintf('%s RUN',handles.c2.a); sendCmd(handles.s,cmd); end;
    writeData(writeFlag,handles.fid,'P2','ERROR: PUMP RATE MISMATCH');      % WRITE ERROR TO FILE
    sound(sin(1:1000),3000);                                                % SINGLE BEEP
    error = {'Pump 2 rate =/= user rate!' 'Pump 2 set to user rate.'};      % WARNING MESSAGE
    PumpWarning('title','Rate Mismatch','string',error);                    % WARNING POP-UP
end

cmd = sprintf('%s DIS',handles.c2.a); str = sendCmd(handles.s,cmd,19);      % QUERY PUMP 1 VOLUME DISPENSED
volI = str2double(str(6:10));                                               % VOLUME INFUSED SINCE RESET
volS = handles.c2.syringe.volume - 2;                                       % VOLUME OF FULL SYRINGE (-2mL)
volR = volS - volI;                                                         % VOLUME REMAINING IN SYRINGE
volStr = sprintf('%s of %s mL dispensed', num2str(volI),num2str(volS));     % UPDATE VOLUME DISPENSED
set(handles.volumeDispensed2,'String',volStr);
tR = volR/userRate; if isinf(tR); tStr = ''; else                           % TIME REMAINING (IN HOURS)
tStr = sprintf('%g hr %g min left',floor(tR),floor(mod(60*tR,60))); end     % UPDATE TIME REMAINING
set(handles.timeLeft2,'String',tStr);

if tR < 1                                                                   % IF LESS THAN 1 HOUR LEFT
    lowFlag = changeLight(handles.syringeLight2);                           % GET WARNING STATE
    
    if lowFlag < 1 && tR > 0.5                                              % IF NO FLAG AND HALF+ HOUR LEFT
        changeLight(handles.syringeLight2,'^','b',1);                       % BLUE SYRINGE INDICATOR
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
        error = {'Pump 2 has < 1 hour left!' 'Refill soon.'};               % WARNING STRING
        PumpWarning('title','Syringe Warning','string',error);              % WARNING POP-UP
    end
    
    if lowFlag < 2 && tR < 0.5                                              % IF NO FLAG AND HALF- HOUR LEFT
        changeLight(handles.syringeLight2,'^','b',2);                       % BLUE SYRINGE INDICATOR
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
        error = {'Pump 2 has < .5 hours left!' 'Refill now!'};              % WARNING STRING
        PumpWarning('title','Syringe Warning','string',error);              % WARNING POP-UP
    end
    
    if lowFlag == 2                                                         % IF FLAGGED, KEEP ON BEEPING
        sound(sin(1:1000),3000);                                            % SINGLE BEEP
    end
end

set(handles.timer,'UserData',0);                                            % EXECUTION COMPLETE
% toc
end

function writeData(writeFlag,fid,pump,data)
% THIS FUNCTION WRITES DATA TO A FILE
if writeFlag
    c = fix(clock); c = [c(3:-1:1) c(4:6)];
    tempString = sprintf('%g-%g-%g, %g:%g:%g, %s, %s\n',c,pump,data);
    fprintf(fid,tempString); disp(tempString);
end
end

function updateRate(s,a,pumpRate,pumpLight)
% THIS FUNCTION UPDATES THE PUMP RATE

goFlag = changeLight(pumpLight); 
if goFlag == 1; cmd = sprintf('%s STP',a); sendCmd(s,cmd); end;
cmd = sprintf('%s RAT %s MH',a,pumpRate); sendCmd(s,cmd);
if goFlag == 1
    if strcmp(pumpRate,'0'); changeLight(pumpLight,'o',[.5 .5 .5],0);
    else cmd = sprintf('%s RUN',a); sendCmd(s,cmd); end;
end

end

function flagCheck = changeLight(h,sym,col,flg)
% THIS FUNCTION CHANGES ONE OF THE SIGNAL LIGHTS. OPTION TO SET A FLAG.

if nargin > 3                                                               % SET LIGHT, IF OBJECT INPUT
    scatter(h,.5,.5,1200,sym,'MarkerEdgeColor','k','MarkerFaceColor',col);
    axis(h,[0 1 0 1]); bkgd = [.931 .931 .931];
    set(h,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);
    set(h,'UserData',flg);
end

if nargout; flagCheck = get(h,'UserData'); end;                             % CHECK FLAG, IF OUT REQUESTED

end

function str = sendCmd(s,cmd,nB)
% THIS FUNCTION TAKES AN OPEN SERIAL OBJECT AND A COMMAND AND SENDS THAT
% COMMANDS TO THE SERIAL OBJECT. IT RETURNS THE SERIAL OBJECTS RESPONSE TO
% THAT COMMAND.

if nargin < 3; nB = 5; end;                                                 % DEFAULT WAIT FOR 5 BYTES
    
while s.BytesAvailable > 0                                                  % CLEAR THE BUFFER
    fscanf(s,'%s',s.BytesAvailable);  pause(.001);
end
fprintf(s,cmd);                                                             % SEND THE COMMAND
while s.BytesAvailable < nB; pause(.001); end;                              % WAIT FOR THE RESPONSE
str = fscanf(s,'%s',s.BytesAvailable);                                      % READ THE RESPONSE

end

% --- Executes on mouse press over figure background
function figure1_WindowButtonDownFcn(~,~,~); end
% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(~,~,~); end
% --- Executes on mouse press over figure background
function figure1_WindowButtonUpFcn(~,~,~); end

function editSave_Callback(hObject, ~, handles)
% hObject    handle to editSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fn = lower(get(hObject,'String'));
set(hObject,'String',fn);

if ~strcmp(fn,handles.fn)   % IF NEW FILENAME IS DIFFERENT THAN THE OLD ONE
    handles.fn = fn;                            % UPDATE FILENAME
    set(handles.fileName,'String',handles.fn);  % SET FILENAME TEXT
    if isempty(fn)              % IF NO FILENAME WAS GIVEN
        set(handles.fileName,'UserData',0);     % STOP SAVING
    else
        tempString = sprintf('Data saving stopped!\n\n');
        fprintf(handles.fid,tempString); disp(tempString);
        fclose(handles.fid);                    % CLOSE CURRENT FILE
        handles.fid = fopen(fn,'a');            % OPEN NEW FILE TO APPEND
        set(handles.fileName,'UserData',1);     % SET TO SAVE DATA
        c = fix(clock);
        tempString = sprintf('%g-%g-%g, (DMY), %g:%g:%g, (HMS), %s, %g kg\n',c(3:-1:1),c(4:6),handles.c1.subject.name,handles.c1.subject.weight);
        fprintf(handles.fid,tempString); disp(tempString);
        tempString = sprintf('Pump 1 delivers %s at %g %s\n',handles.c1.drug.name,handles.c1.drug.concentration,handles.c1.drug.units);
        fprintf(handles.fid,tempString); disp(tempString);
        tempString = sprintf('Pump 1 default dose is %g %s\n',handles.c1.pumpDose,handles.c1.drug.units);
        fprintf(handles.fid,tempString); disp(tempString);
        tempString = sprintf('Pump 2 delivers %s at %g %s\n',handles.c2.drug.name,handles.c2.drug.concentration,handles.c2.drug.units);
        fprintf(handles.fid,tempString); disp(tempString);
        tempString = sprintf('Pump 2 default dose is %g %s\n',handles.c2.pumpDose,handles.c2.drug.units);
        fprintf(handles.fid,tempString); disp(tempString);
    end
end
end

% --- Executes during object creation, after setting all properties.
function editSave_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(~, ~, ~)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% THIS IS SET TO NOT DO ANYTHING TO PREVENT CASUAL CLOSING OF THIS GUI!!!!

% Hint: delete(hObject) closes the figure
% delete(hObject);
end

% --- Executes on button press in VencSwitch.
function VencSwitch_Callback(~, ~, handles)
% hObject    handle to VencSwitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if changeLight(handles.VencLight)
    changeLight(handles.VencLight,'o','w',0);
    set(handles.doseTitle2,'String','Dose ( LRS )');
    set(handles.drugInstructions2,'String','LRS + Dextrose, Comes Prepared');
    c = fix(clock); c = [c(3:-1:1) c(4:6)];
    tempString = sprintf('%g-%g-%g, %g:%g:%g, Pump 2 is LRS only\n',c);
    fprintf(handles.fid,tempString); disp(tempString);
else
    changeLight(handles.VencLight,'o','r',1);
    set(handles.doseTitle2,'String',['Dose (' handles.c2.drug.doseUnits ')']);
    set(handles.drugInstructions2,'String','5mL drug (1mg/mL) + 57.5mL Ringer');
    c = fix(clock); c = [c(3:-1:1) c(4:6)];
    tempString = sprintf('%g-%g-%g, %g:%g:%g, Pump 2 is Vencuronium and LRS\n',c);
    fprintf(handles.fid,tempString); disp(tempString);
end

end
