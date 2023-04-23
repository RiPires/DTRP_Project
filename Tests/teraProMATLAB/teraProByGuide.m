function varargout = teraProByGuide(varargin)
%TERAPROBYGUIDE MATLAB code file for teraProByGuide.fig
%      TERAPROBYGUIDE, by itself, creates a new TERAPROBYGUIDE or raises the existing
%      singleton*.
%
%      H = TERAPROBYGUIDE returns the handle to a new TERAPROBYGUIDE or the handle to
%      the existing singleton*.
%
%      TERAPROBYGUIDE('Property','Value',...) creates a new TERAPROBYGUIDE using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to teraProByGuide_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TERAPROBYGUIDE('CALLBACK') and TERAPROBYGUIDE('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TERAPROBYGUIDE.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help teraProByGuide

% Last Modified by GUIDE v2.5 16-Jan-2023 08:52:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @teraProByGuide_OpeningFcn, ...
                   'gui_OutputFcn',  @teraProByGuide_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before teraProByGuide is made visible.
function teraProByGuide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for teraProByGuide
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes teraProByGuide wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = teraProByGuide_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_date_Callback(hObject, eventdata, handles)
% hObject    handle to edit_date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_date as text
%        str2double(get(hObject,'String')) returns contents of edit_date as a double


% --- Executes during object creation, after setting all properties.
function edit_date_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_courses.
function popupmenu_courses_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_courses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_courses contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_courses


% --- Executes during object creation, after setting all properties.
function popupmenu_courses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_courses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_verification.
function checkbox_verification_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_verification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_verification


% --- Executes on selection change in listbox_students.
function listbox_students_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_students (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_students contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_students


% --- Executes during object creation, after setting all properties.
function listbox_students_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_students (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_delete.
function pushbutton_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
