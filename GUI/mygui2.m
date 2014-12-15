function varargout = mygui2(varargin)
% MYGUI2 MATLAB code for mygui2.fig
%      MYGUI2, by itself, creates a new MYGUI2 or raises the existing
%      singleton*.
%
%      H = MYGUI2 returns the handle to a new MYGUI2 or the handle to
%      the existing singleton*.
%
%      MYGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYGUI2.M with the given input arguments.
%
%      MYGUI2('Property','Value',...) creates a new MYGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mygui2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mygui2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by GUIDE v2.5 24-Oct-2014 11:29:29
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mygui2_OpeningFcn, ...
                   'gui_OutputFcn',  @mygui2_OutputFcn, ...
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

% --- Executes just before mygui2 is made visible.
function mygui2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mygui2 (see VARARGIN)
% Choose default command line output for mygui2
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mygui2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = mygui2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;

function edit1_Callback(hObject, eventdata, handles)
global highpass   %highpass used to store value entered into highpass field
global x          %x is used to store the values read in from the file
highpass=x(1)            %highpass stores the value in index 1 of x
set(handles.edit1,'string',num2str(highpass)); %when the start button is pressed the
highpass=str2double(get(hObject,'String')) %current value x is printed into the edit text box

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end                                        

function edit2_Callback(hObject, eventdata, handles)
global buffer  %buffer is used to store the value entered into the buffer field
global x       %x is used to store the values read in from the file
buffer=x(2)    %buffer stores the of index 2 of x
set(handles.edit2,'string',num2str(buffer)); %when the start button is pressed the value
buffer=str2double(get(hObject,'String')) %current value x is printed into the edit text box

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)
global window  %window is used to store the value entered into the window text box
global x       %x is used to store the values read in from the file
window=x(3)    %window stores the value of index 3
set(handles.edit3,'string',num2str(window));  %When the start button is pressed the value
window=str2double(get(hObject, 'String')) %of x(3) is entered into the edit text box

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(hObject, eventdata, handles)
global movement %movement is used to store the value entered into the edit text box
global x        %x is used to store the values read in from the file
movement=x(4)   %movement stores the value of index 4
set(handles.edit4,'string',num2str(movement)); %when the start button is pressed the value
movement=str2double(get(hObject, 'String')) %of x(4) is entered into the edit text box

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global highpass        %Declares all the edit text field boxes as global
global buffer          %this done so that the pushbutton creat fcn     
global window          %may access these values as well as allowing      
global movement        %the array of x to access these values      
global slope_uv               
global spike_up_uv
global spike_down_uv
global blink_up_uv
global blink_down_uv
global slope_ms
global spike_up_ms
global spike_down_ms
global blink_up_ms
global blink_down_ms
file=[highpass];
file1=[buffer];
file2=[window];
file3=[slope_uv slope_ms];
file4=[spike_up_uv spike_down_uv spike_up_ms spike_down_ms];
file5=[blink_down_uv blink_up_uv blink_up_ms blink_down_ms];
%file=[highpass buffer window movement slope_uv slope_ms spike_up_uv spike_down_uv spike_up_ms spike_down_ms blink_down_uv  blink_up_uv  blink_up_ms blink_down_ms];
art=fopen('read.par','a+');
art2=fprintf(art,'%d\r\n',file);
fclose('all');
art=fopen('read.par','a+');
art2=fprintf(art,'%d\r\n',file1);
fclose('all');
art=fopen('read.par','a+');
art2=fprintf(art,'%d\r\n',file2);
fclose('all');
art=fopen('read.par','a+');
art2=fprintf(art,'%d\t',file3);
fclose('all');
art=fopen('read.par','a+');
art2=fprintf(art,'%d\n\t',file4);
fclose('all');
art=fopen('read.par','a+');
art2=fprintf(art,'%d\n\t',file5);
fclose('all');

function edit5_Callback(hObject, eventdata, handles)
global slope_uv %slope_uv stores the value of the edit text box
global x        %x is used to store the values read in from the file
slope_uv=x(5)   %slope_uv is used to store the value of x(5)
set(handles.edit5,'string',num2str(slope_uv)); %when the start button is pressed the value of
slope_uv=str2double(get(hObject, 'String'))  %x(5) is written to the edit text box

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)
global spike_up_uv %spike_up_uv stores the value of the edit text box
global x           %x is used to store the values read in from the file
spike_up_uv=x(6)   %spike_up_uv is used to store the value of x(6)
set(handles.edit6,'string',num2str(spike_up_uv)); %when the start button is pressed the value of
spike_up_uv=str2double(get(hObject, 'String')) %x(6) is written to the edit text box

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)
global spike_down_uv %spike_down_uv is used to store the value of the edit text box
global x             %x is used to store the values read in from the file
spike_down_uv=x(6)   %spike_down_uv is used to store the value of x(7)
set(handles.edit7,'string',num2str(spike_down_uv));  % when the start button is pressed the value of
spike_down_uv=str2double(get(hObject, 'String')) %x(7) is written to the edit text box

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit8_Callback(hObject, eventdata, handles)
global blink_up_uv %blink_up_uv is used to store the value of the edit text box
global x           %x is used to store the values read in from the file
blink_up_uv=x(8)   % is used to store the value of x(8)
set(handles.edit8,'string',num2str(blink_up_uv));  %when the start button is pressed the value of
blink_up_uv=str2double(get(hObject, 'String')) %x(8) is written to the edit text box

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit9_Callback(hObject, eventdata, handles)
global blink_down_uv %blink_down_uv is used to store the value of the edit text box
global x             %x is used to store the values read in from the file
blink_down_uv=x(8)   %blink_down_uv is used to store the value of x(9)
set(handles.edit9,'string',num2str(blink_down_uv)); %when the start button is pressed the value of
blink_down_uv=str2double(get(hObject, 'String')) %x(9) is stored in the edit text box

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit10_Callback(hObject, eventdata, handles)
global slope_ms %slope_ms is used to store the value of the edit text box
global x        %x is used to store the values read in from the file
slope_ms =x(18) %slope_ms  is used to store the value of x(10)
set(handles.edit10,'string',num2str(slope_ms )); %when the start button is pressed the value of 
slope_ms=str2double(get(hObject, 'String')) %x(10) is stored in the edit text box

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit11_Callback(hObject, eventdata, handles)
global spike_up_ms %spike_up_ms is used to store the value of the edit text box
global x           %x is used to store the values read in from the file
spike_up_ms=x(19)  %spike_up_ms is used to store the value of x(11)
set(handles.edit11,'string',num2str(spike_up_ms)); %when the start button is pressed the value of
spike_up_ms=str2double(get(hObject, 'String')) %is entered into the edit text box

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit12_Callback(hObject, eventdata, handles)
global spike_down_ms %spike_down_ms is used to store the value of the edit text box
global x             %x is used to store the values read in from the file
spike_down_ms=x(32)  %spike_down_ms is used to store the value of x(12)
set(handles.edit12,'string',num2str(spike_down_ms)); %when the start button is pressed the value of 
spike_down_ms=str2double(get(hObject, 'String')) %x(12) is written to the edit text box

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit13_Callback(hObject, eventdata, handles)
global blink_up_ms  %blink_up_ms is used to store the value of the edit text box
global x            %x is used to store the value read from the file
blink_up_ms=x(20)   %blink_up_ms is used to store the value of x(13)
set(handles.edit13,'string',num2str(blink_up_ms)); %when the start button is pressed the value of
blink_up_ms=str2double(get(hObject, 'String')) %x(13) is written to the edit text box

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit14_Callback(hObject, eventdata, handles)
global blink_down_ms %blink_down_ms is used to store the value of the edit text box
global x             %x is used to store the value read from the file
blink_down_ms=x(33)  %blink_down_ms is used to store the value of x(14)
set(handles.edit14,'string',num2str(blink_down_ms)); %when the start button is pressed the value of
blink_down_ms=str2double(get(hObject, 'String'))  %x(14) is written to the edit text box

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
global x
art=fopen('newread.txt','a+');  %opens the file read.par
art1=importdata('newread.txt'); %stores the values of the read file in art1
x=[art1]  %x is used to store the values read from the file 
fclose('all'); %closes the file read.par
edit1_Callback(hObject, eventdata, handles) %calls the callback functions
edit2_Callback(hObject, eventdata, handles) %of the various text fields 
edit3_Callback(hObject, eventdata, handles) %to store the obtained
edit4_Callback(hObject, eventdata, handles) %from the file
edit5_Callback(hObject, eventdata, handles) %
edit6_Callback(hObject, eventdata, handles) %
edit7_Callback(hObject, eventdata, handles) %
edit8_Callback(hObject, eventdata, handles) %
edit9_Callback(hObject, eventdata, handles) %
edit10_Callback(hObject, eventdata, handles) %
edit11_Callback(hObject, eventdata, handles) %
edit12_Callback(hObject, eventdata, handles) %
edit13_Callback(hObject, eventdata, handles) %
edit14_Callback(hObject, eventdata, handles) %
