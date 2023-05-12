function main
% function main
% HELP: this function serves as an hypothetical example to be used 
% in the lectures of Diagn�stico e Terapia com Radia��es e Prot�es
%
% INPUT
% * none
%
% OUTPUT
% * none
%
% SEE ALSO: 
%
% -------------------------------------------------------------------------
% Authors:
% R. Pires
% A. Pardal
% R. Santos
% 
% Last Update: 10/05/2023
% 
% adapted from bcf's teraPro function made in 09-01-2023
% -------------------------------------------------------------------------


%-----------------------------------------------------
% Initialize some variables for demonstration purposes
%-----------------------------------------------------
age = rand(30);
data = {};
%---

%---------------------------------------------------------------
% BUILD THE MAIN FIGURE
%---------------------------------------------------------------
mainFig =figure(1);
set(mainFig ,'Name','Example for DTRP',...
    'Position',[500 300 1280 566],...
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
    function uimenu_new_callback(~,~)
        
        warndlg(['No action will happen when Pressing OK because'...
            ' this Callback function is not programmed yet!'],...
            '!! Warning !!')
        
        % See Also: dialog, questdlg, errordlg
    end

    function uimenu_save_callback(~,~)
        
        % Can be any variable stored in the interface or the workspace
        uisave({'data'},'ListStudents.mat') %Suggested filename
        
        %See Also: uigetfifle, uiopen
    end

%---------------------------------------------------------------
% ADD A TOOLBAR
%---------------------------------------------------------------
handles.toolbar=uitoolbar(mainFig);
%diretory = 'matlabDTRP';
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
panel_DataList = uipanel('Tag','panel_DataList',...
    'Title',            'List',...
    'Units',            'Normalized',...
    'Position',         [.01 .007 .17 .84],...
    'HighlightColor',   [0 0 1],...
    'FontSize',         12,...
    'Parent',           mainFig);

% is text no need to keep the handle
uicontrol(panel_DataList,...
    'Tag','text',...
    'Style',' Text', ...
    'String','Data Sets',...
    'FontName', 'Arial',...
    'FontSize',13,...
    'Units','Normalized',...
    'Position',[.05 .95 .88 .05],...
    'Enable','on',...
    'Callback',@listbox_Callback);

handles.listbox_DataSets = uicontrol(panel_DataList,...
    'Tag','listbox_DataSets',...
    'Style',' listbox', ...
    'String','',...
    'Units','Normalized',...
    'Position',[.1 .2 .75 .75],...
    'Enable','on',...
    'Callback',@listbox_DataSets_Callback);
% String defined as cell to accomodate different size strings
% String can be a list read directly from a file or a database which then
% fills up the listbox

    function listbox_DataSets_Callback(hObject, ~)

                %%%   !!!   TO DO   !!!   %%%
        %%%   Plot selected data set on the pannel   %%%
                %%%   !!!   TO DO   !!!   %%%

        handles.pushbutton_delete.Enable ='on';   
        
        DataSetsList = get(handles.listbox_DataSets,'String')

        tmp = get(hObject, 'String')
        val = get(hObject, 'Value')
        
        for i = 1:numel(DataSetsList)
            if strcmp(tmp(val), DataSetsList(i))
                InputData = load(strcat('.\',string(tmp(val,:)),'.m'));
                cla(handles.axes_plot)
                Time = InputData(:, 1);
                SR = InputData(:, 2);
                plot(Time, SR, '*')
               
            end
        end
    end


handles.pushbutton_add = uicontrol(panel_DataList,...
    'Tag','pushbutton_add',...
    'Style',' pushbutton', ...
    'String','Add new data set',...
    'Units','Normalized',...
    'Position',[.1 .12 .75 .07],...
    'Enable','on',...
    'ForegroundColor','r',...
    'Tooltipstring','This button allows to add a new data set to be uploaded to the fitting function',...
    'Callback',@pushbutton_add_Callback);

    function pushbutton_add_Callback(~,~)
        % Data may be added without question the user
        qst = 'Would you like to add a new data set to the list?';
        button = questdlg(qst,'Question','Yes','Cancel','Cancel');        
        if strcmp(button,'Yes')
            data = get(handles.uitable,'Data');
            DataSetsList = get(handles.listbox_DataSets,'String');          
            % if there is no data yet in the list or all was deleted
            if isempty(DataSetsList)
                file = uigetfile; % Selects file
                FileName = strsplit(file, '.');
                FileName = string(FileName{1}); % Gets file name
                set(handles.listbox_DataSets,'String',FileName,...
                                             'Value',1) % leave this student selected
                % string needs to be cell to be consistent with the
                % following code and the format adopted for the list

                data(size(data,1)+1,:) = cell(1,5);
                set(handles.uitable, ...
                    'Rowname'      ,    get(handles.listbox_DataSets,'String'),...
                    'Data'         ,    data, ...
                    'Userdata'     ,    data)
            else
                %check the number of the last student and add a student
                %with a new number
                file = uigetfile; % Selects file
                FileName = strsplit(file, '.');
                FileName = string(FileName{1}); % Gets file name
                DataSetsList = [DataSetsList;FileName];
                n=numel(DataSetsList);                         
                set(handles.listbox_DataSets,'String',DataSetsList,...
                    'Value',n)% leave last student selected                
                % ATTENTION: data has changed but not in the workspace
                % this variable was now stored in Userdata
                data(size(data,1)+1,:)=cell(1,5);
                set(handles.uitable,...
                    'Rowname',get(handles.listbox_DataSets,'String'),...
                    'Data', data, ...
                    'Userdata',data)                
            end
        end
    end

handles.pushbutton_delete = uicontrol(panel_DataList,...
    'Tag','pushbutton_delete',...
    'Style',' pushbutton', ...
    'String','Delete',...
    'Units','Normalized',...
    'Position',[.1 .02 .75 .07],...
    'Enable','off',...
    'Callback',@pushbutton_delete_Callback);

    function pushbutton_delete_Callback(~,~)
        
        % As a precaution measure, everytime data is deleted, the user
        % should be questioned
        qst = 'Are you sure you need to delete this information?';
        button = questdlg(qst,'WARNING DELETE','Yes','No','No');
        % No is the default button selected
        if strcmp(button,'Yes')
            list = get(handles.listbox_DataSets,'String');
            val=get(handles.listbox_DataSets,'Value');
            list(val) ='';
            set(handles.listbox_DataSets,'String',list,'Value',1)        
            % all information related to that instance needs to be erased
            set(handles.edit_date,'String','')
            set(handles.uitable,...
                'Rowname',get(handles.listbox_DataSets,'String'))
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

    handles.edit_date = uicontrol(handles.buttonGroup,'Style','edit',...
        'Tag','edit_date',...
        'Units','Normalized','Position',[0.3 0.02 0.6 0.38],...
        'TooltipString','Valid format: dd-mm-yyyy',...
        'HorizontalAlignment','left',...
        'BackgroundColor','red',...
        'UserData','',...
        'Callback',@edit_date_Callback);
    

%-----------------------------
% BUILD ONE UICONTEXTMENU
%-----------------------------
c = uicontextmenu;
m1 = uimenu(c,'Label','Red','Callback',@backgroundcolor);
m2 = uimenu(c,'Label','Blue','Callback',@backgroundcolor);
m3 = uimenu(c,'Label','White','Callback',@backgroundcolor);
set(handles.edit_date,'UIContextMenu',c)

    function backgroundcolor(source,~)
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
handles.panel_DataDetails = uipanel('Parent',mainFig,...
    'Tag',              'panel_DataDetails',...
    'Title',            'Data Sets� Details',...
    'Units',            'Normalized',...
    'Position',         [.19 .2 .75 .79],...
    'HighlightColor',   'm',...
    'ForegroundColor',  'm',...
    'FontSize',         12);

% It is convenient that the first option is an instruction
DataSets = {'Select Data Sets...' 'Physics' 'Chemistry' 'Mathematics'};
handles.popupmenu_SortData = uicontrol(...
    'Parent',handles.panel_DataDetails,...
    'Style','popup',...
    'Tag','popup_SortData',...
    'Units','Normalized','Position',[0.01 0.9 0.15 0.05],...
    'String',DataSets,...
    'TooltipString','Select Data Set',...
    'HorizontalAlignment','left',...
    'BackgroundColor','y',...
    'UserData','',...
    'Callback',@popupmenu_SortData_Callback);

    function popupmenu_SortData_Callback(hObject,~)
        
        % Because I'm getting the value, I need to know the relation
        % between the value and the string
        val = get(hObject,'Value');
        if     val == 1 % it may be needed to reset all data
            cla(handles.axes_plot)
            
            % Show the all data again
            set(handles.uitable,'Data',data,...
                'Rowname',get(handles.listbox_DataSets,'String'))
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

%------------------------------------------------------------------
% BUILD UITABLE
%------------------------------------------------------------------
handles.uitable = uitable(handles.panel_DataDetails,...
    'Tag','uitable',...
    'ColumnFormat',{'logical' 'char' 'char' 'numeric' 'numeric' ...
                                 'numeric'},...
    'Data',data,...
    'Units','Normalized', ...
    'Position',[0.01 0.01 0.5 0.85],...
    'ColumnEditable',true,...
    'ColumnName',{'Select' 'Author' 'Label' 'D' 'd' 'Td'},...
    'RowName',get(handles.listbox_DataSets,'string'),...
    'Userdata',data,...
    'CellEditCallback',@uitable_Callback);
% Check other properties in the Inspector from Guide or Help manual


    % if there is more than one uitable, give it an more appropriate name
     function uitable_Callback(hObject,~)
        
        tmp = get(hObject,'Data')
        % keep the data from the table somwhere
        set(handles.uitable,'Userdata',tmp)
        
        % another way to store variables in the workspace
        assignin('base','data',tmp)
    end


%------------------------------------------------------------------
% BUILD AXES TO PLOT DATA
%------------------------------------------------------------------
handles.axes_plot = axes('Parent',handles.panel_DataDetails,...
    'Units','Normalized','Position',[0.58 0.1 0.4 0.85],...
    'Visible','on');
xlabel('Time (months)'),ylabel('SR (%)'),hold on

%------------------------------------------------------------------
% CALLS FIT FUNCTION
%------------------------------------------------------------------

    function Fit(hObject,~)       
        %%%   !!!   !!!!!   !!!   %%%
        %%%   !!!   TO DO   !!!   %%%
        %%%   !!!   !!!!!   !!!   %%%
        tmp = get(hObject,'Data')
        % keep the data from the table somwhere
        set(handles.uitable,'Userdata',tmp)

        Selection = get(handles.uitable,'ColumnFormat');

    end


%------------------------------------------------------------------
% FIT BUTTON
%------------------------------------------------------------------
panel_Fit = uipanel('Parent', mainFig, ...
    'Tag', 'panel_Fit', ...
    'Title','Start', ...
    'Units', 'normalized', ...
    'Position',         [.40 .1 .1 .1],...
    'HighlightColor',   'm',...
    'ForegroundColor',  'm',...
    'FontSize',         12);

handles.pushbutton_fit = uicontrol(panel_Fit,...
    'Tag','pushbutton_Fit',...
    'Style',' pushbutton', ...
    'String','Fit',...
    'Units','Normalized',...
    'Position',[.20 .2 .7 .7],...
    'Enable','on',...
    'ForegroundColor','r',...
    'Tooltipstring','Perform fit',...
    'Callback',@pushbutton_Fit_Callback);

    function pushbutton_Fit_Callback(hObject,~)
        
        data = get(handles.uitable,'Userdata')
        DataFiles = strings(0)
        DataSetsList = get(handles.listbox_DataSets,'String')

        if isempty(data)
            disp('No data to show')
        else
        Selected = data(:,1)
            for i = 1:numel(Selected)
                %disp(Selected(i))
                %disp(isequal(Selected(i), {[1]}))
                if isequal(Selected(i),{[1]})
                    disp('File Added')
                    DataFiles = [DataFiles  strcat(".\",string(DataSetsList(i,:)),".m")]
                    file_names = cellstr(DataFiles)
                end
            end
        end
        
        fit1(file_names)

    end

end %main