function teraPro
% function teraPro
% HELP: this function serves as an hypothetical example to be used 
% in the lectures of Diagnóstico e Terapia com Radiações e Protões
%
% INPUT
% * none
%
% OUTPUT
% * none
%
% SEE ALSO: isdate, filterByCourse
%
% -------------------------------------------------------------------------
% made by bcf in 09-01-2023
% -------------------------------------------------------------------------


%-----------------------------------------------------
% Initialize some variables for demonstration purposes
%-----------------------------------------------------
age = rand(30);
data = {22 51 25199 16 'Jose X' true 'Select...';...
    18 01 9501 18 'Maria XY' false 'Physics';...
    22 55 9612 '' 'Jose XYZ' true 'Mathematics';
    26 55 9612 '' 'João Z' false 'Chemistry'};
%---

%---------------------------------------------------------------
% BUILD THE MAIN FIGURE
%---------------------------------------------------------------
mainFig =figure(1);
set(mainFig ,'Name','Example for DTRP',...
    'Position',[1 82.3333 1280 566],...
    'KeyPressFcn',@figure_keyPressFcn,...
    'MenuBar','None');
clf, % clear the figure

    function figure_keyPressFcn(hObject,eventdata)
                
        switch eventdata.Key
            case 'return'
                set(hObject,'Color','r')
              
            case 'backspace'
                set(hObject,'Color','b')
            case 'escape'
                set(hObject,'Color',[1 0.5 0])
                
        end
    end


% ADD CIENCIAS LOGO
%-------------------
[tmp,~,alfa] = imread('ciencias_ul_azul_h_s-ass.png');
%maximize the use of temporary variables
handles.axes_logo = axes('Parent',mainFig,...
    'Units','Normalized','Position',[0.03 0.87 0.12 0.12],...
    'Visible','off');
tmp=image(tmp);
set(tmp, 'AlphaData', alfa);
axis equal off
%---



%---------------------------------------------------------------
% BUILD THE MENU
%---------------------------------------------------------------
handles.uimenu_new = uimenu(mainFig,'Label','New');
handles.uimenu_newFile = uimenu(handles.uimenu_new,...
    'Label','New File...',...
    'Callback',@uimenu_new_callback);
handles.uimenu_saveFile = uimenu(handles.uimenu_new,...
    'Label','Save...',...
    'Separator','on',...
    'Callback',@uimenu_save_callback); % See Also: UImenu properties


    % the advantage of having the Callback function close to the creation
    % of the object is that it is easy to get there with the Go To...
    function uimenu_new_callback(hObject,eventdata)
        
        warndlg(['No action will happen when Pressing OK because'...
            ' this Callback function is not programmed yet!'],...
            '!! Warning !!')
        
        % See Also: dialog, questdlg, errordlg
    end

    function uimenu_save_callback(hObject,eventdata)
        
        % Can be any variable stored in the interface or the workspace
        uisave({'data'},'ListStudents.mat') %Suggested filename
        
        %See Also: uigetfifle, uiopen
    end

%---------------------------------------------------------------
% ADD A TOOLBAR
%---------------------------------------------------------------
handles.toolbar=uitoolbar(mainFig);
diretory = 'matlabDTRP';
b=load('.\myloginicon.mat');
uipushtool(handles.toolbar,'CData',b.icon,...
    'TooltipString','Login',...
    'Tag','pushtool_login',...
    'Enable','on',...
    'ClickedCallback','menu_login_Callback();')
b=load('.\mylogouticon.mat');
uipushtool(handles.toolbar,'CData',b.icon,...
    'TooltipString','Logout',...
    'Tag','pushtool_logout',...
    'Enable','off',...
    'ClickedCallback','menu_logout_Callback();')
% CallBack Functions or any other functions
% do not need to be inside this file
%-


%---------------------------------------------------------------
% BUILD A PANEL
%---------------------------------------------------------------
panel_studentsList = uipanel('Tag','panel_studentsList',...
    'Title',            'List',...
    'Units',            'Normalized',...
    'Position',         [.01 .007 .17 .84],...
    'HighlightColor',   [0 0 1],...
    'FontSize',         12,...
    'Parent',           mainFig);

% is text no need to keep the handle
uicontrol(panel_studentsList,...
    'Tag','text',...
    'Style',' Text', ...
    'String','Students List at FCUL',...
    'FontName', 'Arial',...
    'FontSize',13,...
    'Units','Normalized',...
    'Position',[.05 .95 .88 .05],...
    'Enable','on',...
    'Callback',@listbox_Callback);

handles.listbox_students = uicontrol(panel_studentsList,...
    'Tag','listbox_students',...
    'Style',' listbox', ...
    'String',{'Student1','Student2','Student344' 'Student489'},...
    'Units','Normalized',...
    'Position',[.1 .2 .75 .75],...
    'Enable','on',...
    'Callback',@listbox_students_Callback);
% String defined as cell to accomodate different size strings
% String can be a list read     directly from a file or a database which then
% fills up the listbox

    function listbox_students_Callback(hObject,~)
        
        handles.pushbutton_delete.Enable ='on';
        
        tmp = get(hObject,'String'); % cells
        val= get(hObject,'Value');
        if strcmp(tmp(val),'Student1')
            cla(handles.axes_plot)
            plot(0:0.1:10,sin(0:0.1:10),'rs','Parent',handles.axes_plot)            
        elseif strcmp(tmp(val),'Student2')
            handles.edit_date.String = '12-02-2023';
        else
            tmp = imread('emogi.jpg');
            imagesc(rot90(tmp,2),'Parent',handles.axes_plot)
            % TODO: ??????????????????
        end
        
    end


handles.pushbutton_add = uicontrol(panel_studentsList,...
    'Tag','pushbutton_add',...
    'Style',' pushbutton', ...
    'String','Add new student',...
    'Units','Normalized',...
    'Position',[.1 .12 .75 .07],...
    'Enable','on',...
    'ForegroundColor','r',...
    'Tooltipstring','This button allows to add a new student to the list',...
    'Callback',@pushbutton_add_Callback);

    function pushbutton_add_Callback(hObject,eventdata)
        
        
        % Data may be added without question the user
        qst = 'Would you like to add a new student to the list?';
        button = questdlg(qst,'Question','Yes','Cancel','Cancel');        
        if strcmp(button,'Yes')
            
            data = get(handles.uitable,'Data');
            list = get(handles.listbox_students,'String');
            % if there is no data yet in the list or all was deleted
            if isempty(list)
                set(handles.listbox_students,'String',{'Student1'},...
                    'Value',1) % leave this student selected
                
                % string needs to be cell to be consistent with the
                % following code and the format adopted for the list
            else
                %check the number of the last student and add a student
                %with a new number
                n=numel(list);
                nb_laststudent=str2double(list{n}(8:end));
                list = [list;'Student' int2str(nb_laststudent+1)];
                set(handles.listbox_students,'String',list,...
                    'Value',n+1)% leave last student selected
                
                % ATTENTION: data has changed but not in the workspace
                % this variable was now stored in Userdata
                data(size(data,1)+1,:)=cell(1,7);
                set(handles.uitable,...
                    'Rowname',get(handles.listbox_students,'String'),...
                    'Data', data,'Userdata',data)                
            end
        end
        
    end

handles.pushbutton_delete = uicontrol(panel_studentsList,...
    'Tag','pushbutton_delete',...
    'Style',' pushbutton', ...
    'String','Delete',...
    'Units','Normalized',...
    'Position',[.1 .02 .75 .07],...
    'Enable','off',...
    'Callback',@pushbutton_delete_Callback);

    function pushbutton_delete_Callback(hObject,~)
        
        % As a precaution measure, everytime data is deleted, the user
        % should be questioned
        qst = 'Are you sure you need to delete this information?';
        button = questdlg(qst,'WARNING DELETE','Yes','No','No');
        % No is the default button selected
        if strcmp(button,'Yes')
            list = get(handles.listbox_students,'String');
            val=get(handles.listbox_students,'Value');
            list(val) ='';
            set(handles.listbox_students,'String',list,'Value',1)
            
            % all information related to that instance needs to be erased
            set(handles.edit_date,'String','')
            set(handles.uitable,...
                'Rowname',get(handles.listbox_students,'String'))
            data = get(handles.uitable,'Userdata');%or get(handles.uitable,'Data');
            data(val,:)='';
            set(handles.uitable,'Data',data,'Userdata',data)
        end
        
    end

handles.buttonGroup = uibuttongroup('Parent',mainFig,...
    'Title','Student Registration',...
    'Tag','buttongroup',...
    'FontSize',12,...
    'FontWeight','bold',...
    'Units','Normalized','Position',[.19 .006 .193 .165],...
    'UserData','Test 1',...
    'SelectionChangeFcn',@buttongroup_Callback);
handles.radiobutton_yes = uicontrol(handles.buttonGroup,...
    'Tag','radiobutton_yes',...
    'Style','radiobutton',...
    'String','Yes',......
    'Units','Normalized','Position',[.55 .47 .34 .24],...
    'TooltipString','tooltipstring',...
    'FontSize',10,...
    'HorizontalAlignment','left');
handles.radiobutton_no = uicontrol(handles.buttonGroup,...
    'Tag','radiobutton_no',...
    'Style','radiobutton',...
    'String','No',......
    'Units','Normalized','Position',[.15 .47 .34 .24],...
    'TooltipString','tooltipstring',...
    'FontSize',10,...
    'HorizontalAlignment','left');

    function buttongroup_Callback(hObject,~)
        
        tmp = get(hObject,'SelectedObject');
        if strcmp(tmp.String,'No')
            set(handles.edit_date,'String','','BackgroundColor','y')
        elseif strcmp(tmp.String,'Yes')
            set(handles.edit_date,'String','09-01-2023',...
                'BackgroundColor','w')
        end
        
    end


uicontrol(handles.buttonGroup,'Style','text',...
    'String','Date',...
    'Units','Normalized','Position',[0.03 0.02 0.3 0.33],...
    'FontSize',10,...
    'HorizontalAlignment','left');
handles.edit_date = uicontrol(handles.buttonGroup,'Style','edit',...
    'Tag','edit_date',...
    'Units','Normalized','Position',[0.3 0.02 0.6 0.38],...
    'TooltipString','Valid format: dd-mm-yyyy',...
    'HorizontalAlignment','left',...
    'BackgroundColor','red',...
    'UserData','',...
    'Callback',@edit_date_Callback);


    function edit_date_Callback(hObject,eventdata)
        
        
        oldvalue = get(hObject,'String');
        
        % there should always be made a validation of the imput
        thisdate = isdate(get(hObject,'String'));
        if isempty(thisdate),set(hObject,'String',''),return,end
        
        % If the date is valid write on screen with the correct format
        set(hObject,'String',thisdate)
        
    end

%-----------------------------
% BUILD ONE UICONTEXTMENU
%-----------------------------
c = uicontextmenu;
m1 = uimenu(c,'Label','Red','Callback',@backgroundcolor);
m2 = uimenu(c,'Label','Blue','Callback',@backgroundcolor);
m3 = uimenu(c,'Label','White','Callback',@backgroundcolor);
set(handles.edit_date,'UIContextMenu',c)

    function backgroundcolor(source,callbackdata)
        switch source.Label
            case 'Red'
                handles.edit_date.BackgroundColor ='r';
            case 'Blue'
                handles.edit_date.BackgroundColor ='b';
            case 'White'
                handles.edit_date.BackgroundColor ='w';
        end
    end
%-


%---------------------------------------------------------------
% BUILD A NEW PANEL
%---------------------------------------------------------------
handles.panel_studentDetails = uipanel('Parent',mainFig,...
    'Tag',              'panel_studentDetails',...
    'Title',            'Student Details',...
    'Units',            'Normalized',...
    'Position',         [.19 .2 .75 .79],...
    'HighlightColor',   'm',...
    'ForegroundColor',  'm',...
    'FontSize',         12);

% It is convenient that the first option is an instruction
courses = {'Select Course...' 'Physics' 'Chemistry' 'Mathematics'};
handles.popupmenu_courses = uicontrol(...
    'Parent',handles.panel_studentDetails,...
    'Style','popup',...
    'Tag','popup_courses',...
    'Units','Normalized','Position',[0.01 0.9 0.15 0.05],...
    'String',courses,...
    'TooltipString','Select Course',...
    'HorizontalAlignment','left',...
    'BackgroundColor','y',...
    'UserData','',...
    'Callback',@popupmenu_courses_Callback);

    function popupmenu_courses_Callback(hObject,~)
        
        % Because I'm getting the value, I need to know the relation
        % between the value and the string
        val = get(hObject,'Value');
        if     val == 1 % it may be needed to reset all data
            cla(handles.axes_plot)
            
            % Show the all data again
            set(handles.uitable,'Data',data,...
                'Rowname',get(handles.listbox_students,'String'))
        elseif val == 2 % Physics
            % fill table with data
            filterByCourse('Physics');
            % clear plot
            cla(handles.axes_plot)
        elseif val == 3 % Chemistry
            plot(age(:,1),age(:,end),'kx','MarkerSize',12,...
                'Parent',handles.axes_plot)
            %clear table
            set(handles.uitable,'Data','','Rowname','')
        elseif val == 4 % Mathematics
            filterByCourse('Mathematics');
            
            cla(handles.axes_plot)
            for i=1:size(age,2)                
                plot(age(:,i),age(:,end-i+1),'x')
                drawnow
            end
            
        end
    end

handles.checkbox_verification = uicontrol(...
    'Parent',handles.panel_studentDetails,...
    'Style','checkbox',...
    'Tag','checkbox_verification',...
    'String','Student Verified',...
    'Units','Normalized','Position',[0.18 0.9 0.15 0.05],...
    'TooltipString','Select if student was verified.',...
    'UserData','',...
    'Callback',@checkbox_verification_Callback);

    function checkbox_verification_Callback(hObject,~)
        
        val = get(hObject,'Value');
        if val == 1 % Checkbox was selected
            set(handles.uitable,'Enable','off')
        else
            set(handles.uitable,'Enable','on')
        end
    end


%------------------------------------------------------------------
% BUILD UITABLE
%------------------------------------------------------------------
handles.uitable = uitable(handles.panel_studentDetails,...
    'Tag','uitable',...
    'ColumnFormat',{'numeric' 'numeric' 'numeric' 'numeric' ...
         'char' 'logical' {'Select...' 'Physics' 'Chemistry' 'Mathematics'}},...
    'Data',data,...
    'Units','Normalized','Position',[0.01 0.01 0.5 0.85],...
    'ColumnEditable',true,...
    'ColumnName',...
          {'Age' 'Code' 'Phone' 'Average' 'Name' 'Graduated' 'Degree'},...
    'RowName',get(handles.listbox_students,'string'),...
    'Userdata',data,...% Simple way store data
    'CellEditCallback',@uitable_Callback);
% Check other properties in the Inspector from Guide or Help manual


    % if there is more than one uitable, give it an more appropriate name
     function uitable_Callback(hObject,eventdata)
        
        tmp = get(hObject,'Data')
        % keep the data from the table somwhere
        set(handles.uitable,'Userdata',tmp)
        
        % another way to store variables in the workspace
        assignin('base','data',tmp)
    end


%------------------------------------------------------------------
% BUILD AXES TO PLOT DATA
%------------------------------------------------------------------
handles.axes_plot = axes('Parent',handles.panel_studentDetails,...
    'Units','Normalized','Position',[0.58 0.1 0.4 0.85],...
    'Visible','on');
xlabel('xx'),ylabel('yy'),hold on


end