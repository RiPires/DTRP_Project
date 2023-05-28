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
% Last Update: 23/05/2023
% 
% adapted from bcf's teraPro function made in 09-01-2023
% -------------------------------------------------------------------------


%-----------------------------------------------------
% Initialize some variables for demonstration purposes
%-----------------------------------------------------
data = {};
TestData = {true 'Data1.m' 'data1' 128 53.6 4.88 28;...
            true 'Data2.m' 'data2' 35 61.5 1.5 42;...
            true 'Data3.m' 'data3' 83 55 1.8 37;...
            true 'Data4.m' 'data4' 51 45 1.8 37;...
            true 'Data5.m' 'data5' 24 32.5 1.8 37};
FitData = {};
FitInput = {};
%---

%---------------------------------------------------------------
% BUILD THE MAIN FIGURE
%---------------------------------------------------------------
mainFig =figure(1);
set(mainFig ,'Name','SR Modeling',...
    'WindowState', 'maximized',...
    'KeyPressFcn',@figure_keyPressFcn,...
    'MenuBar','None');
clf, % clear the figure

    function figure_keyPressFcn(hObject,eventdata)
                
        switch eventdata.Key
            case 'return'
                pushbutton_Fit_Callback() 
            case 'backspace'
                set(hObject,'Color','b')
            case 'escape'
                pushbutton_ClearAxes_Callback()
                pushbutton_ClearFitAxes_Callback()       
        end
    end


%-------------------
% ADD CIENCIAS LOGO
%-------------------
[tmp,~,alfa] = imread('ciencias_ul_azul_h_s-ass.png');
%maximize the use of temporary variables
handles.axes_logo = axes('Parent',mainFig,...
    'Units','Normalized','Position',[0.03 0.85 0.12 0.12],...
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
% BUILD DATA SETS LIST PANEL
%---------------------------------------------------------------
panel_DataList = uipanel('Tag','panel_DataList',...
    'Title',            'Data Sets',...
    'Units',            'Normalized',...
    'Position',         [.16 .78 .2 .2],...
    'HighlightColor',   [0 0 1],...
    'FontSize',         12,...
    'Parent',           mainFig);

% is text no need to keep the handle
uicontrol(panel_DataList,...
    'Tag','text',...
    'Style',' Text', ...
    'String',' ',...
    'FontName', 'Arial',...
    'FontSize',13,...
    'Units','Normalized',...
    'Position',[.05 .95 .99 .05],...
    'Enable','on',...
    'Callback',@listbox_Callback);

handles.listbox_DataSets = uicontrol(panel_DataList,...
    'Tag','listbox_DataSets',...
    'Style',' listbox', ...
    'String',{'Data1', 'Data2', 'Data3', 'Data4', 'Data5'},...
    'Units','Normalized',...
    'Position',[.05 .30 .6 .70],...
    'Enable','on',...
    'Tooltipstring','Select a Data Set to plot',...
    'Callback',@listbox_DataSets_Callback);

    function listbox_DataSets_Callback(hObject, ~)
        handles.pushbutton_delete.Enable ='on';   
        % Get entries in listbox_DataSets
        DataSetsList = get(handles.listbox_DataSets,'String');
        tmp = get(hObject, 'String');
        val = get(hObject, 'Value');  
        % Get data stored in the Data Details table as "Userdata"
        data = get(handles.uitable,'Userdata');
        % Labels for each data set
        Labels = data(:,3);    
        % Plot the selected data set
        for i = 1:numel(DataSetsList)
            if strcmp(tmp(val), DataSetsList(i))
                InputData = load(strcat('.\',string(tmp(val,:)),'.m'));
                %cla(handles.axes_plotData, 'reset') %reset plot
                axes(handles.axes_plotData); %Select "plotData" axes
                Time = InputData(:, 1);
                SR = InputData(:, 2);

                my_color = rand(1,3);
                all_marks = {'o','+','*','x','s','d','^','v','>','<','p','h'};

                plot(Time, SR, ...
                    'LineStyle', 'none', ...
                    'Marker',all_marks{mod(i,12)},...
                    'LineWidth', 2, ...
                    'Color', my_color, ...
                    'MarkerSize', 6, ...
                    'DisplayName', string(Labels(i)))
                legend('Location', 'northeast')
                legend('boxoff')
                xlabel('Time (months)')
                ylabel('SR (%)')
                title('Clinical Data')               
            end
        end
    end


handles.pushbutton_add = uicontrol(panel_DataList,...
    'Tag','pushbutton_add',...
    'Style',' pushbutton', ...
    'String','Add new',...
    'Units','Normalized',...
    'Position',[.68 .7 .3 .3],...
    'Enable','on',...
    'ForegroundColor', "#77AC30",...
    'Tooltipstring','This button allows to add a new data set to be uploaded to the fitting function',...
    'Callback',@pushbutton_add_Callback);

    function pushbutton_add_Callback(~,~)
        % Get data from the Data Details table
        data = get(handles.uitable,'Userdata');
        % Get entries in listbox_DataSets
        DataSetsList = get(handles.listbox_DataSets,'String'); 
        n=numel(DataSetsList); 
        % if there is no data yet in the list or all was deleted
        if isempty(DataSetsList)
            file = uigetfile; % Selects file
            FileName = strsplit(file, '.');
            FileName = string(FileName{1}); % Gets file name
            set(handles.listbox_DataSets,'String',FileName,...
                                         'Value',1) % leave this student selected

            data(size(data,1)+1,:) = cell(1,7);
            set(handles.uitable, ...
                'Rowname'      ,    get(handles.listbox_DataSets,'String'),...
                'Data'         ,    data, ...
                'Userdata'     ,    data);
        else
            %check the number of the last student and add a student
            %with a new number
            file = uigetfile; % Selects file
            FileName = strsplit(file, '.');
            FileName = string(FileName{1}); % Gets file name
            DataSetsList = [DataSetsList;FileName];              
            set(handles.listbox_DataSets,'String',DataSetsList,...
                'Value',n)% leave last student selected                

            data(size(data,1)+1,:) = cell(1,7);
            set(handles.uitable,...
                'Rowname',get(handles.listbox_DataSets,'String'),...
                'Data', data, ...
                'Userdata',data);

        end
    end

handles.pushbutton_delete = uicontrol(panel_DataList,...
    'Tag','pushbutton_delete',...
    'Style',' pushbutton', ...
    'String','Delete',...
    'Units','Normalized',...
    'Position',[.68 .4 .3 .2],...
    'Enable','off',...
    'ForegroundColor', 'r',...
    'Tooltipstring','Deletes the selected entry from the list',...
    'Callback',@pushbutton_delete_Callback);

    function pushbutton_delete_Callback(~,~)
        
        % As a precaution measure, everytime data is deleted, the user
        % should be questioned
        qst = 'Are you sure you need to delete this information?';
        button = questdlg(qst,'WARNING DELETE','Yes','No','No');
        % No is the default button selected
        if strcmp(button,'Yes')
            DataList = get(handles.listbox_DataSets,'String');
            val=get(handles.listbox_DataSets,'Value');
            DataList(val) ='';
            set(handles.listbox_DataSets,'String',DataList,'Value',1)        
            % all information related to that instance needs to be erased
            %set(handles.edit_date,'String','')
            set(handles.uitable,...
                'Rowname',get(handles.listbox_DataSets,'String'))
            data = get(handles.uitable,'Userdata');%or get(handles.uitable,'Data');
            data(val,:)='';
            set(handles.uitable,'Data',data,'Userdata',data)
        end
        
    end


handles.pushbutton_ClearAxes = uicontrol(panel_DataList,...
    'Tag','pushbutton_ClearAxes',...
    'Style',' pushbutton', ...
    'String','Clear',...
    'Units','Normalized',...
    'Position',[.68 .1 .3 .2],...
    'Enable','on',...
    'ForegroundColor', "#EDB120",...
    'Tooltipstring','Clear "Clinical Data" axes',...
    'Callback',@pushbutton_ClearAxes_Callback);

function pushbutton_ClearAxes_Callback(~,~)

    cla(handles.axes_plotData, 'reset') %reset plot
    axes(handles.axes_plotData);
    xlabel('Time (months)')
    ylabel('SR (%)')
    title('Clinical Data') 
    hold on;
    enableDefaultInteractivity(handles.axes_plotData)

end


%---------------------------------------------------------------
% BUILD DATA DETAILS PANEL
%---------------------------------------------------------------
handles.panel_DataDetails = uipanel('Parent',mainFig,...
    'Tag',              'panel_DataDetails',...
    'Title',            'Data Details',...
    'Units',            'Normalized',...
    'Position',         [.01 .53 .35 .25],...
    'HighlightColor',   'm',...
    'ForegroundColor',  'k',...
    'FontSize',         12);


%------------------------------------------------------------------
% BUILD DATA DETAILS UITABLE
%------------------------------------------------------------------
handles.uitable = uitable(handles.panel_DataDetails,...
    'Tag','uitable',...
    'ColumnFormat',{'logical' 'char' 'char' 'numeric' 'numeric' ...
                                 'numeric' 'numeric'},...
    'Data',TestData,...
    'Units','Normalized', ...
    'Position',[0.01 0.05 .98 .95],...
    'ColumnEditable',true,...
    'ColumnName',{'Select' 'Author' 'Label' 'Nr.  Patients' 'D [Gy]' 'd [Gy/fx]' 'Td [days]'},...
    'RowName',get(handles.listbox_DataSets,'string'),...
    'Userdata',TestData,...
    'Tooltip', {'Select data to perform the fit' 'The author of the study' 'Label on the plot' 'Number of patients on the study' 'Total prescription dose' 'Dose per fraction' 'Treatment time'},...
    'CellEditCallback',@uitable_Callback);


    % if there is more than one uitable, give it an more appropriate name
     function uitable_Callback(hObject,~)
        tmp = get(hObject,'Data');
        % keep the data from the table somwhere
        set(handles.uitable, ...
            'Userdata',tmp);
        % another way to store variables in the workspace
        %assignin('base','data',tmp);
    end


%---------------------------------------------------------------
% PLOT PANEL
%---------------------------------------------------------------
handles.panel_Plot = uipanel('Parent',mainFig,...
    'Tag',              'panel_Plot',...
    'Title',            'Plots',...
    'Units',            'Normalized',...
    'Position',         [.37 .01 .6 .99],...
    'HighlightColor',   'k',...
    'ForegroundColor',  'k',...
    'FontSize',         12);


%-------------------------
% BUILD AXES TO PLOT DATA
%-------------------------
handles.axes_plotData = axes('Parent',handles.panel_Plot,...
    'Units','Normalized','Position',[0.1 0.1 0.4 0.85],...
    'Visible','on');
xlabel('Time (months)'),ylabel('SR (%)'), title('Clinical Data'), hold on
enableDefaultInteractivity(handles.axes_plotData)

 
%-------------------------
% BUILD AXES TO PLOT FIT
%-------------------------
handles.axes_plotFit = axes('Parent',handles.panel_Plot,...
    'Units','Normalized','Position',[0.57 0.1 0.4 0.85],...
    'Visible','on');
xlabel('Time (months)'),ylabel('SR (%)'), title('Fited Data'), hold on
enableDefaultInteractivity(handles.axes_plotFit)
 

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
% FIT OPTIONS PANNEL
%------------------------------------------------------------------
panel_Fit = uipanel('Parent', mainFig, ...
    'Tag', 'panel_Fit', ...
    'Title','Model Options', ...
    'Units', 'normalized', ...
    'Position',         [.01 .23 .35 .3],...
    'HighlightColor',  "#EDB120",...
    'ForegroundColor',  'k',...
    'FontSize',         12);


%----------------------------
% FIT OPTIONS UITABLE
%----------------------------
handles.fitoptionsuitable = uitable(panel_Fit,...
    'Tag','fitoptionsuitable',...
    'ColumnFormat',{'numeric' 'numeric' 'numeric' 'numeric' 'numeric' 'numeric'},...
    'Data',FitInput,...
    'Units','Normalized', ...
    'Position',[0.01 .25 .99 .745],...
    'ColumnEditable',true,...
    'ColumnName',{'K' '<html><center />Alpha<br /> [Gy<sup>-1</sup>]</html>' '<html><center />Beta<br />[Gy<sup>-2</sup>]</html>' 'Gamma' '<html><center />a <br />[mo<sup>-1</sup>]</html>' 'Delta'},...
    'ColumnWidth', {50, 50, 50, 50, 50, 50},...
    'RowName',{'Initial Guess' 'Lower limit' 'Upper limit'},...
    'Userdata',FitInput,...
    'CellEditCallback',@fitoptionsuitable_Callback);

 function fitoptionsuitable_Callback(hObject,~)
    tmp = get(hObject,'Data')
    % keep the data from the table somwhere
    set(handles.fitoptionsuitable, ...
        'Userdata',tmp);
end

%------------------------------------------------
% FIT BUTON
%------------------------------------------------
handles.pushbutton_fit = uicontrol(panel_Fit,...
    'Tag','pushbutton_Fit',...
    'Style',' pushbutton', ...
    'String','Fit',...
    'Units','Normalized',...
    'FontSize', 12,...
    'Position',[.5 .02 .15 .22],...
    'Enable','on',...
    'ForegroundColor',"#A2142F",...
    'BackgroundColor', '#77AC30',...
    'Tooltipstring','Perform fit',...
    'Callback',@pushbutton_Fit_Callback);

    function pushbutton_Fit_Callback(~,~)
        
        data = get(handles.uitable,'Userdata')
        DataFiles = strings(0);
        DataSetsList = get(handles.listbox_DataSets,'String')
        Labels = data(:,3)

        if isempty(data)
            disp('No data to show')
        else
            cla(handles.axes_plotFit, 'reset') %clear axes
            axes(handles.axes_plotFit)
            Selected = data(:,1)
            for i = 1:numel(Selected)
                if isequal(Selected(i),{[1]})
                    disp('File Added')
                    DataFiles = [DataFiles  strcat(".\",string(DataSetsList(i,:)),".m")]
                    file_names = cellstr(DataFiles)
                end
            end
            [K, alpha, beta, gamma, a, Td, delta] = fit1(file_names, Labels)
            FitData = {round(str2num(K),5) round(str2num(alpha),5) round(str2num(beta),5) round(str2num(alpha)/str2num(beta),3) round(str2num(gamma),5) round(str2num(a),5) round(str2num(Td),0) round(str2num(delta),5)}
            set(handles.fiteduitable,...
                'Data', FitData,...
                'Userdata', FitData)
            %msgbox('Complete!')
        end    
    end

%------------------------------------------------
% CLEAR FIT AXES BUTON
%------------------------------------------------
handles.pushbutton_ClearFitAxes = uicontrol(panel_Fit,...
    'Tag','pushbutton_ClearFitAxes',...
    'Style',' pushbutton', ...
    'String','Clear',...
    'Units','Normalized',...
    'Position',[.2 .02 .15 .22],...
    'Enable','on',...
    'ForegroundColor', "#EDB120",...
    'Tooltipstring','Clear "Fited Data" axes',...
    'Callback',@pushbutton_ClearFitAxes_Callback);

function pushbutton_ClearFitAxes_Callback(~,~)

    cla(handles.axes_plotFit, 'reset') %reset plot
    axes(handles.axes_plotFit);
    xlabel('Time (months)')
    ylabel('SR (%)')
    title('Fited Data') 
    hold on;
    enableDefaultInteractivity(handles.axes_plotFit)

end



%------------------------------------------------------------------
% FITED PARAMETERS PANEL
%------------------------------------------------------------------
handles.panel_Fited = uipanel('Parent', mainFig, ...
    'Tag', 'panel_Fited', ...
    'Title','Fited Parameters', ...
    'Units', 'normalized', ...
    'Position',         [.01 .01 .35 .2],...
    'HighlightColor',   'r',...
    'ForegroundColor',  'k',...
    'FontSize',         12);

%----------------------------
% FITED PARAMETERS UITABLE
%----------------------------
handles.fiteduitable = uitable(handles.panel_Fited,...
    'Tag','fiteduitable',...
    'ColumnFormat',{'char' 'char' 'char' 'char' 'char' 'char' 'char' 'char'},...
    'Data',FitData,...
    'Units','Normalized', ...
    'Position',[0.01 .3 .99 .7],...
    'ColumnEditable',false,...
    'ColumnName',{'K' '<html><center />Alpha <br /> [Gy<sup>-1</sup> ]</html>' '<html><center />Beta <br /> [Gy<sup>-2</sup>]</html>' 'A/B|[Gy]' 'Gamma' '<html><center />a <br /> [mo<sup>-1</sup>]</html>' 'Td|[day]' 'Delta'},...
    'RowName',' ',...
    'Userdata',FitData,...
    'CellEditCallback',@fiteduitable_Callback);


handles.pushbutton_SavePlot = uicontrol(handles.panel_Fited,...
    'Tag','pushbutton_SavePlot',...
    'Style',' pushbutton', ...
    'String','<html><center />Save<br /> Plot</html>',...
    'Units','Normalized',...
    'Position',[.80 .005 .1 .25],...
    'Enable','on',...
    'ForegroundColor','r',...
    'Tooltipstring','Perform fit',...
    'Callback',@pushbutton_SavePlot_Callback);

    function pushbutton_SavePlot_Callback (~,~)

        FileName = inputdlg('Enter file name and extension (.png, .pdf, .jpg, .fig, .m, .jpeg, .svg):')

        fignew = figure('Visible','off'); % Invisible figure
        newAxes = copyobj(handles.axes_plotFit,fignew); % Copy the appropriate axes
        set(newAxes,'Position',get(groot,'DefaultAxesPosition')); % The original position is copied too, so adjust it.
        set(fignew,'CreateFcn','set(gcbf,''Visible'',''on'')'); % Make it visible upon loading
        saveas(fignew,string(FileName));
        delete(fignew);
    end


end %main