function varargout = PumpReset(varargin)
% PUMPRESET MATLAB code for PumpReset.fig
%      PUMPRESET by itself, creates a new PUMPRESET or raises the
%      existing singleton*.
%
%      H = PUMPRESET returns the handle to a new PUMPRESET or the handle to
%      the existing singleton*.
%
%      PUMPRESET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PUMPRESET.M with the given input arguments.
%
%      PUMPRESET('Property','Value',...) creates a new PUMPRESET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PumpReset_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PumpReset_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PumpReset

% Last Modified by GUIDE v2.5 07-Nov-2012 14:18:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PumpReset_OpeningFcn, ...
                   'gui_OutputFcn',  @PumpReset_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

end

% --- Executes just before PumpReset is made visible.
function PumpReset_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PumpReset (see VARARGIN)

% Choose default command line output for PumpReset
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
if(nargin > 3)                          % USER SPECIFIED TEXT IF BOTH A TITLE AND STRING ARE PROVIDED
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title' % TAKE THE STRING AFTER TITLE DESIGNATION
          set(hObject, 'Name', varargin{index+1}); % NAME THE FIGURE
         case 'string' % TAKE THE STRING AFTER STRING DESIGNATION
          set(handles.warningText, 'String', varargin{index+1}); % SET THIS AS WARNING TEXT
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a warning icon from dialogicons.mat
load dialogicons.mat

IconData=questIconData;
questIconMap(256,:) = get(handles.figure1, 'Color');
IconCMap=questIconMap;

Img=image(IconData, 'Parent', handles.warningSign);
set(handles.figure1, 'Colormap', IconCMap);

set(handles.warningSign, ...
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(Img,'XData'), ...
    'YLim'   , get(Img,'YData')  ...
    );

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes PumpReset wait for user response (see UIRESUME)
uiwait(handles.figure1);

end

% --- Outputs from this function are returned to the command line.
function varargout = PumpReset_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

end

% --- Executes on button press in confirmButton.
function confirmButton_Callback(hObject, ~, handles) %#ok<*DEFNU>
% hObject    handle to confirmButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = str2double(get(handles.loadedVolume,'String'));

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

end

function loadedVolume_Callback(hObject, ~, handles)
% hObject    handle to loadedVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadedVolume as text
%        str2double(get(hObject,'String')) returns contents of loadedVolume as a double

vol = round(10*abs(real(str2double(get(hObject,'String')))))/10;            % GET VOLUME TO .1 mL

if isnan(vol)                                                               % IF VOLUME IS INVALID
    set(hObject,'String','');                                               % ENTER NO VALUE
    set(handles.confirmButton,'Enable','off');                              % AND DISABLE CONFIRM
else                                                                        % OTHERWISE
    vol = min(vol,60);                                                      % KEEP UNDER MAX VOLUME
    set(hObject,'String',num2str(vol));                                     % SET VALUE
    set(handles.confirmButton,'Enable','on');                               % AND ENABLE CONFIRM
end

end

% --- Executes during object creation, after setting all properties.
function loadedVolume_CreateFcn(hObject, ~, ~)
% hObject    handle to loadedVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
