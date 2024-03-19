function radiance
% HELP: this function launches the RADIANCE: 
%       Radiotherapy Survival Rate Modeling Interface,
%       a GUI (Graphical User Interface) to perform
%       survival rate (SR) modeling by fitting different survival 
%       models to clinical data inputed by the user
%      
% INPUT
%   The function main requires NO INPUT to launch the interface!
%  
%  While runing and interacting with the interface, the user may prompt
% different kinds of inputs, such as: adding new files via the uigetfile
% class, edit contents of uitable objects, type output files' names, etc.
%
% OUTPUT
%  The function main returns NO OUTPUT when launching the interface!
%
%  While runing and interacting with the interface, the user may prompt
% different kinds of outputs, such as: result of fited parameters and
% uncertainties; clinical data, fiting SR over time and over BED plots
% 
% SEE ALSO: uimenu, uitoolbar, uipushtool, uipanel, uicontrol, uigetfile,
%           uibuttongroup, 
% -------------------------------------------------------------------------
% Authors:
% R. Pires
% A. Pardal
% R. Santos
% 
% Last Update: 07/03/2024
% 
% adapted from bcf's teraPro function made in 09/01/2023
% -------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Initialize some variables for demonstration purposes
%--------------------------------------------------------------------------
data = {};
TestData = {false 'Data1.m' 128 53.6 4.88 28 'magenta' 'downward-pointing triangle' 'X';... %N,D,d,T 
            false 'Data2.m' 35 61.5 1.5 42 'blue' 'circle' 'X';...
            false 'Data3.m' 83 55 1.8 37 'black' 'upward-pointing triangle' 'X';...
            false 'Data4.m' 51 45 1.8 37 'red' 'square' 'X';...
            false 'Data5.m' 24 32.5 1.8 37 'electric green' 'circle' 'X'}; % test data for the data table - "Data Details"

ModelOptions1 = {0.042 0.037 0.002587 0.00608 1268 0.16;... % initial guess
                 0 0 0 0 1000 0;...                         % lower limit     
                 0.05 0.05 0.003 0.007 1500 0.30};          % upper limit
                 % initial values for the options table - "Model Options" - for the 1st Fit

ModelOptions2 = {2.03 0.010 0.000666 0.00542 0.65 0.20;... % initial guess
                 1.99 0.009 0.000647 0.00495 0.59 0.19;... % lower limit  
                 2.07 0.011 0.000692 0.00598 0.71 0.21};   % upper limit
                 % initial values for the options table - "Model Options" - for the 2nd Fit

FitData = {};                                               % needed to initialize uitable_ResultFit
UncertaintyData = {};
handles.FileNames = {'Data1' 'Data2' 'Data3' 'Data4' 'Data5'};
%----------                                                     ----------%

%--------------------------------------------------------------------------
% MAIN FIGURE
%--------------------------------------------------------------------------
mainFig = figure(1);
set(mainFig ,'Name','RADIANCE: Radiotherapy Survival Rate Modeling Interface',...
    'NumberTitle','off',...
    'WindowState', 'maximized',...                  % Maximize window by default
    'KeyPressFcn',@figure_keyPressFcn,...           % What happens when certain keys are pressed on the keyboard
    'MenuBar','None');
clf,                                                % clear the figure

    function figure_keyPressFcn(~,eventdata)
               %%%   !!!   TO DO   !!!   %%% 
        switch eventdata.Key
            case 'return'
                pushbutton_Fit_Callback() 
            case 'escape'
                ClearAxes()       
        end
    end
%----------                                                     ----------%

%--------------------------------------------------------------------------
% CIENCIAS LOGO
%--------------------------------------------------------------------------
[tmp,~,alfa] = imread('./Images/Icons/cienciaslogo.png');

handles.axes_logo = axes('Parent',mainFig,...
                         'Units','Normalized', ...
                         'Position',[0.08 0.93 0.14 0.07],...
                         'Visible','off');
tmp=image(tmp);
set(tmp, 'AlphaData', alfa);
axis equal off
%--------------------------------------------------------------------------
% INTERFACE LOGO
%--------------------------------------------------------------------------                                                   ----------%
[tmp,~,alfa] = imread('./Images/Icons/logo.png');

handles.axes_logo = axes('Parent',mainFig,...
                         'Units','Normalized', ...
                         'Position',[0.001 0.93 0.11 0.07],...
                         'Visible','off');
tmp=image(tmp);
set(tmp, 'AlphaData', alfa);
axis equal off

%--------------------------------------------------------------------------
% TEXT AREA
%--------------------------------------------------------------------------
dim = [.2 .78 .1 .21]; 
str = {'RADIANCE_v2.0.0'
       'github.com/RiPires/DTRP_Project.git'};
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'none');
%----------                                                     ----------%

%--------------------------------------------------------------------------
% MENU
%--------------------------------------------------------------------------
%%%   !!!   TO DO   !!!   %%% 

%-----------
% FILE
%-----------
handles.uimenu_file = uimenu(mainFig, ... 
        	                'Label','File');

    handles.uimenu_newFile = uimenu(handles.uimenu_file,...
                                   'Label','Add Files...',...
                                   'Callback',@AddFile_CB);

    handles.uimenu_delFile = uimenu(handles.uimenu_file,...
                                   'Label','Delete Files...',...
                                   'Callback',@Del_CB);
    
    handles.uimenu_saveFile = uimenu(handles.uimenu_file,...
                                    'Label','Open...',...
                                    'Separator','on',...
                                    'Callback',@uimenu_open_callback);

    handles.uimenu_saveFile = uimenu(handles.uimenu_file,...
                                    'Label','Save...',...
                                    'Separator','off',...
                                    'Callback',@uimenu_save_callback);
        
        function uimenu_open_callback(~,~)        
            uiopen('*.mat')             % Search for .mat files
        end
    
        function uimenu_save_callback(~,~)        
            uisave() 
        end

%-----------
% FIT
%-----------
handles.uimenu_fit = uimenu(mainFig, ...
        	                'Label', 'Fit');

    handles.uimenu_model = uimenu(handles.uimenu_fit,...
                                  'Label', 'Select Model');

        handles.uimenu_fit1 = uimenu(handles.uimenu_model,...
                                     'Label',   'Fit1',...
                                     'Callback', @uimenu_fit1_callback);

            function uimenu_fit1_callback(~,~)
                handles.radiobutton_Fit1.Value = 1;
            end

        handles.uimenu_fit2 = uimenu(handles.uimenu_model,...
                                     'Label',     'Fit2',...
                                     'Callback',  @uimenu_fit2_callback);

            function uimenu_fit2_callback(~,~)
                handles.radiobutton_Fit2.Value = 1;
            end

    handles.uimenu_dofit = uimenu(handles.uimenu_fit,...
                                  'Label',      'Perform Fit',...
                                  'Callback',   @pushbutton_Fit_Callback);

    handles.uimenu_saveresults = uimenu(handles.uimenu_fit,...
                              'Label',      'Save Results',...
                              'Callback',   @SaveResults_Callback);

        function SaveResults_Callback(~,~)
            SelectedFit = get(handles.uitable_ResultFit1, 'Visible');       % Checks selected model      
            if strcmp(SelectedFit, 'on')                                    % If Fit1 is selected
                Results = cell2table(get(handles.uitable_ResultFit1, 'Userdata'));
                Results.Properties.VariableNames = ...
                ["K", "alpha [Gy^-1]", "beta [Gy^-2]", "alpha/beta [Gy]", "gamma", "Td [day]", "a [mon^-1]", "delta", "qui^2/dof"];
            elseif strcmp(SelectedFit, 'off')                               % If Fit2 is selected
                Results = cell2table(get(handles.uitable_ResultFit2, 'Userdata'));
                Results.Properties.VariableNames = ...
                ["K50/K0", "alpha [Gy^-1]", "beta [Gy^-2]", "alpha/beta [Gy]", "gamma", "Td [day]", "sigma_k/K0", "delta", "qui^2/dof"];
            end
            FileName = inputdlg('Enter file name and extension (.txt, .csv):');
            writetable(Results, string(FileName));                          % write file
        end
%-----------
% PLOT
%-----------
handles.uimenu_plot = uimenu(mainFig, ...
        	                 'Label', 'Plot');
    handles.uimenu_clr = uimenu(handles.uimenu_plot,...
                                'Label',    'Clear axes',...
                                'Callback', @ClearAxes);
    
    handles.uimenu_pltdata = uimenu(handles.uimenu_plot,...
                                    'Label',    'Plot selected clinical data',...
                                    'Callback', @PltData);

    handles.uimenu_save = uimenu(handles.uimenu_plot,...
                                 'Label',    'Save',...
                                 'Callback', @SavePlot);
%-----------
% HELP
%-----------
handles.uimenu_hp = uimenu(mainFig, ...
        	                'Label', 'Help',...
                            'Callback', @Help_Callback);

    function Help_Callback(~,~)
        open("RADIANCE-Guide.pdf")
    end
%----------                                                     ----------%

%--------------------------------------------------------------------------
% TOOLBAR
%--------------------------------------------------------------------------
handles.toolbar=uitoolbar(mainFig);

%-------------------
% "Add File" Button
%-------------------
myimage = imread('./Images/Icons/AddFileIcon.png');
myIcon = imresize(myimage, [20, 20]);
uipushtool(handles.toolbar, ...
           'TooltipString',    'Add File',...
           'CData',             myIcon,...
           'Tag',              'pushtool_addfile',...
           'Enable',           'on',...
           'ClickedCallback',  @AddFile_CB)

    function AddFile_CB(~,~)       
        data = get(handles.uitable,'Userdata');             % Get data from the Data Details table
        FileList = get(handles.uitable,'RowName');          % The names of the files are stored in the RowName
        n=numel(FileList); 
        files = uigetfile('*', ...                          % GUI that allows to select multiple files
                          'Select one or more files to import', ...
                          'MultiSelect','on');             
        if ischar(files)                                    % If only one file is selected, "files" is a char vector
            FileNames = strsplit(files, '.');               % gets file name without extension
            FileNames = string(FileNames{1});
            
        else                                                % If multiple files are selected
            FileNames = [];
            for k = 1:numel(files)                          % for each one    
                File = strsplit(files{k}, '.');             % gets file name without extension
                File = string(File{1});
                FileNames = [FileNames;File];               % stack it to "FileNames" array
            end
        end

        if isempty(data)                                    % If there is no data yet in the list or all was deleted
            set(handles.uitable,...                         % just paste "FileNames" in the "RowName"
                'RowName',   FileNames)                     
        else                                                % If there was already data
            FileList = [FileList;FileNames];                % stack the new FileNames to the pre-existing FileList  
            set(handles.uitable, ...                        % and past it to the "RowName"
                'RowName',FileList)                                                         
        end

        data(size(data,1)+numel(FileNames),:) = cell(1,7);  % Add as many extra rows as the nr of files imported
        set(handles.uitable, ...                            % to the "Userdata" and "Data" properties of the table
        'Data',     data, ...
        'Userdata', data);                                  % Update them


    end

%------------------------
% "Delete File(s)" Button
%------------------------
myimage = imread('./Images/Icons/DeleteFilesIcon.png');
myIcon = imresize(myimage, [20, 20]);
uipushtool(handles.toolbar, ...
    'TooltipString',    'Delete selected files',...
    'CData',            myIcon,...
    'Tag',              'pushtool_delfile',...
    'Enable',           'on',...
    'ClickedCallback',  @Del_CB)
    
   function Del_CB(~,~)
       
        qst = 'Are you sure you want to delete the selected data?'; % As a precaution measure, everytime data is deleted, the user should be questioned
        button = questdlg(qst,'WARNING DELETE','Yes','No','No');   % No is the default button selected
        
        if strcmp(button,'Yes')

            FileNames = get(handles.uitable, 'Rowname'); % Gets file names in the row header
            data = get(handles.uitable,'Userdata');      % Gets Userdata in the table
            select = cell2mat(data(:,1));                % Gets selection status of the data
            n = numel(data(:,1));
            for k=n:-1:1                                 % Starting from the end of the table, otherwise we'll have problems with the indexing
                if select(k) == 0                        % If the selection state is OFF             
                    data(k,:) = '';                      % Clears the information on this row
                    FileNames(k) = '';                   % And also the row header
                end
            end
            set(handles.uitable, ...                     % In the end sets
                'Data',data, ...                         % updated displayed data
                'Userdata',data, ...                     % userdata
                'Rowname',FileNames)                     % and headers
        end
        
    end

%---------------------
% "Save Plot" Button
%---------------------
myimage = imread('./Images/Icons/SavePlotIcon.png');
myIcon = imresize(myimage, [20, 20]);
uipushtool(handles.toolbar, ...
    'TooltipString',    'Save Plot',...
    'CData',             myIcon,...
    'Tag',              'pushtool_saveplottime',...
    'Enable',           'on',...
    'ClickedCallback',  @SavePlot)

%---------------------
% "Clear Axes" Button
%---------------------
myimage = imread('./Images/Icons/ClearPlotIcon.png');
myIcon = imresize(myimage, [20, 20]);
uipushtool(handles.toolbar, ...
    'TooltipString',    'Clear Axes',...
    'CData',             myIcon,...
    'Tag',              'pushtool_clearaxes',...
    'Enable',           'on',...
    'ClickedCallback',  @ClearAxes)

%----------                                                     ----------%

%--------------------------------------------------------------------------
% "DATA DETAILS" PANEL
%--------------------------------------------------------------------------
handles.panel_DataDetails = uipanel('Parent',mainFig,...   
    'Tag',              'panel_DataDetails',...
    'Title',            'Data Details',...
    'Units',            'Normalized',...
    'Position',         [.01 .62 .38 .30],...
    'HighlightColor',   '#D95319',...
    'ForegroundColor',  'k',...
    'FontSize',         12);

%-----------------------------
% "DATA DETAILS" UITABLE
%-----------------------------

handles.uitable = uitable(handles.panel_DataDetails,...        
    'Tag',              'uitable',...
    'Data',             TestData,...                    % Data displayed on the table
    'Units',            'normalized', ...
    'Position',         [0.01 0.05 .98 .95],...
    'ColumnEditable',   [true,true,true,true,true,true,true,true,true,false],...
    'ColumnWidth',      {70 70 70 70 70 70 70 70 70 70},...
    'ColumnFormat',     {'logical' 'char' 'numeric' 'numeric' 'numeric' 'numeric' {'red' 'electric green' 'blue' 'cyan' ...
    'magenta' 'yellow' 'black' 'orange' 'purple' 'pink' 'gray' 'bordeaux' 'dark green' 'dark yellow' 'brown'} ...
    {'circle' 'plus sign' 'asterisk' 'point' 'cross' 'horizontal line' 'vertical line' 'square' 'diamond' ...
    'upward-pointing triangle' 'downward-pointing triangle' 'right-pointing triangle' 'left-pointing triangle' ...
    'pentagram' 'hexagram'}},...                                     
    'ColumnName',       {'Select' 'Author' 'Nr. Patients' 'D [Gy]' 'd [Gy/fx]' 'T [days]' 'Color' 'Marker'...
    'Delete'},...
    'Tooltip',          {['<html>Select: data to fit<br />' ...
                          'Author: of the study<br /> ' ...
                          'Nr. Patients: total number of patients in the study<br /> ' ...
                          'D: total prescription dose in grey<br /> ' ...
                          'd: dose administrated in each fraction in grey per fraction<br />' ...
                          'T: total treatment time in days<br /> ' ...
                          'Color: color of the datapoints<br /> ' ...
                          'Marker: marker of the datapoints<br /> ' ...
                          'Delete: Delete data points</html>']},...
    'RowName',          handles.FileNames,...
    'Userdata',         TestData,...                    % Data that can be accesible by the user 
    'CellEditCallback', @datauitable_Callback,...
    'CellSelectionCallback', @(s, e) delete_count_row(e));
        % s: handle of the uitable object
        % e: event data structure containing 
        % information about the cell selection event

% Add a push button for select/unselect all
handles.selectButton = uicontrol(handles.panel_DataDetails, 'Style', 'pushbutton', ...
    'String', 'Select/Unselect All', ...
    'Units', 'normalized', ...
    'Position', [0.01 0.01 0.2 0.08], ...
    'Callback', @selectAllCallback, ...
    'BackgroundColor', '#D95319');

   
    function datauitable_Callback(hObject, event)
        
        tmp = get(hObject, 'Data');                     % Get data from the table
        indices = event.Indices;                        % Index the edited cell
        % indices = event.Indices();                      
      
        if ~isempty(indices)
            input = cell2mat(tmp(indices(1), indices(2)));  % Input kept as a number
                                                            % indices(1)-row
                                                            % indices(2)-column
                                                            
            if indices(2) > 3 && indices(2) < 8              % If a cell in columns 4, 5, 6 or 7 changes 
                if ~isnan(input)                            % check if it's not NaN 
                    if indices(2) == 7 ... % If a cell in columns 4 or 7 changes
                        & rem(2*input,2) ~=0                  % and it's not integer                           
                        warndlg(['Are you sure this is the correct input? ' ...
                                 'Tipicaly, the number of patients in the study,' ...
                                 ' and the total treament time are positive, ' ...
                                 'non-zero, integer values.'], 'Input Warning')
    
                    elseif indices(2) == 4 && rem(2*input,2) ~=0
                        prevState = get(hObject, 'Userdata');   % gets previous state of the table stored in the Userdata
                        set(hObject, 'Data', prevState)         % updates the data in the table back to the previous state, before editing
                        errordlg(['There is no such thing as non-integer patients! ' ...
                                  'Tipicaly, the number of patients in the study,' ...
                                  ' and the total treament time are positive, ' ...
                                  'non-zero, integer values.'], 'Invalid Input')
                    
                    elseif (indices(2) == 4 || indices(2) == 5 ||... % If a cell in the columns 4, 5,
                        indices(2) == 6 || indices(2) == 7)...   % 6 or 7 changes
                        & input <= 0                            % and it's not positive
                        
                        prevState = get(hObject, 'Userdata');   % gets previous state of the table stored in the Userdata
                        set(hObject, 'Data', prevState)         % updates the data in the table back to the previous state, before editing
                        errordlg(['Number of patients in the study,' ...
                                  ' total prescription dose, ' ...
                                  'dose per fraction and ' ...
                                  'total treatment time should be ' ...
                                  'positive, non-zero values.'], 'Invalid Input')
                    else 
                        set(hObject, 'Userdata', tmp);          % keeps Data in the table and updates Userdata
                    end
                else                                        % If input is NaN
                    prevState = get(hObject, 'Userdata');   % gets previous state of the table stored in the Userdata
                    set(hObject, 'Data', prevState)         % updates the data in the table back to the previous state, before editing
                    errordlg(['Input must be a number!' ...      % Propts what the input must be
                              'Use point decimal separator (e.g. 3.14 instead of 3,14).' ...
                              'Cientific notation is valid (e.g. 314 = 3.14e2). ' ...
                              'Number of patients in the study, total prescription dose, ' ...
                              'dose per fraction and total treatment time' ...
                              ' should be positive, non-zero values.'], 'Invalid Input') 
                end
            elseif indices(2) <= 3                          % If a cell in column 2, 3, 8, or 9 changes
                                                            % (Selection State, Author, Color, Marker)
                set(hObject, 'Userdata', tmp);              % updates Userdata
            
            % elseif indices(2) == 9  % Check if the "Delete" column is edited (index 9 corresponds to the 9th column)
            %     tmp(row, :) = [];  % Delete the selected row from the table data
            %     set(hObject, 'Data', tmp);  % Update the table data
            
            end
            
            if indices(2) == 1
            
                PltData
       
            end
        end
    end


%--------------------------------------------------------------------------
% "PLOTS" PANEL
%--------------------------------------------------------------------------
handles.panel_Plot = uipanel('Parent',mainFig,...
    'Tag',              'panel_Plot',...
    'Title',            'Plots',...
    'Units',            'Normalized',...
    'Position',         [.395 .01 .6 .99],...
    'HighlightColor',   '#D95319',...
    'ForegroundColor',  'k',...
    'FontSize',         12);

%---------------------------
% AXES OF THE 1ST PLOT
 
%---------------------------
handles.axes_left_plot = axes('Parent',handles.panel_Plot,...
    'Units','Normalized','Position',[0.1 0.1 0.4 0.85],...
    'Visible','on');
axis([0 1 0 100]),...
title(' '),...
hold on
enableDefaultInteractivity(handles.axes_left_plot)
 
%-------------------------
% AXES OF THE 2ND PLOT
 
%-------------------------
handles.axes_right_plot = axes('Parent',handles.panel_Plot,...
    'Units','Normalized','Position',[0.57 0.1 0.4 0.85],...
    'Visible','on');
axis([0 1 0 100]),...
title(' '),...
hold on
enableDefaultInteractivity(handles.axes_right_plot)
%----------                                                     ----------% 

%--------------------------------------------------------------------------
% "MODEL OPTIONS" PANNEL
%--------------------------------------------------------------------------
panel_ModelOpt = uipanel('Parent', mainFig, ...
    'Tag',              'panel_ModelOpt', ...
    'Title',            'Model Options', ...
    'Units',            'normalized', ...
    'Position',         [.01 .315 .38 .3],...
    'HighlightColor',   "#D95319",...
    'ForegroundColor',  'k',...
    'FontSize',         12);

%----------------------------
% FIT1 or FIT2 RADIO BUTTONS
%----------------------------
handles.SelectModel = uibuttongroup('Parent',panel_ModelOpt,...
    'Title',                ' ',...
    'Tag',                  'buttongroup',...
    'FontSize',             10,...
    'FontWeight',           'bold',...
    'Units',                'normalized', ...
    'Position',             [.01 .02 .45 .22],...
    'UserData',             {},...
    'SelectionChangeFcn',   @SelectModel_Callback);

handles.radiobutton_Fit1 = uicontrol(handles.SelectModel,...
    'Tag',                  'radiobutton_Fit1',...
    'Style',                'radiobutton',...
    'String',               'Fit1',......
    'Units',                'Normalized', ...
    'Position',             [.15 .3 .2 .5],...
    'FontSize',             10,...
    'HorizontalAlignment',  'right',...
    'TooltipString',        ['<html><center>Select Model 1:<br />' ...
                             'SR(d,D,&tau) = exp(-K exp(-[&alpha(1+d/(&alpha/&beta)) D - &gamma T - a(&tau - T))<sup>&delta</sup>]))<br />' ...
                             ' </center> <br />' ...
                             'SR: Survival Rate in percentage (%) <br />' ...
                             '&tau: enlapsed time from the beggining of the treatment (months) <br />' ...
                             '&gamma = ln2/T<sub>d</sub>, &alpha and &beta characterize the intrinsic radiosensitivity of cells <br />' ...
                             'T<sub>d</sub>: potential doubling time <br />' ...
                             'K, a and &delta are the remaining fitting parameters. </html>']);

handles.radiobutton_Fit2 = uicontrol(handles.SelectModel,...
    'Tag',                      'radiobutton_Fit2',...
    'Style',                    'radiobutton',...
    'String',                   'Fit2',......
    'Units',                    'Normalized', ...
    'Position',                 [.6 .3 .2 .5],...
    'FontSize',                 10,...
    'HorizontalAlignment',      'left',...
    'TooltipString',            ['<html><center>Select Model 2:<br /> ' ...
                                 'SR(d,D,&tau) = 1 - (2&pi)<sup>-1/2</sup> &int<sub>-&infin</sub><sup>t</sup> exp(-x<sup>2</sup>/2) dx <br /> ' ...
                                 't = (exp(-[&alpha(1+d/(&alpha/&beta))D - &gamma T -(&gamma(&tau - T))<sup>&delta</sup>])-K<sub>50</sub>/K<sub>0</sub>)/(&sigma<sub>k</sub>/K<sub>0</sub>) <br /> ' ...
                                 '</center> <br />' ...
                                 'SR: Survival Rate in percentage (%) <br /> ' ...
                                 '&tau: enlapsed time from the beggining of the treatment (months) <br /> ' ...
                                 't = (K - K<sub>50</sub>)/&sigma<sub>k</sub> <br />' ...
                                 'K<sub>50</sub> is the critical number of tumour clonogens corresponding to death in 50 % patients <br />' ...
                                 '&sigma<sub>k</sub> is the gaussian width for the distribution of critical clonogen numbers <br />' ...
                                 'Dependence of tumor cells on D, d, T and &tau is given by the following LQ inspired model: <br />' ...
                                 'K = K<sub>50</sub> exp(-[&alpha(1+d/(&alpha/&beta))D - &gamma T -(&gamma(&tau - T))<sup>&delta</sup>]) <br />' ...
                                 '(&gamma(&tau - T))<sup>&delta</sup> characterizes the time dependence of tumor regrowth after completions of RT. </html>']);
 
    function SelectModel_Callback(hObject,~)
        tmp = get(hObject, 'SelectedObject');                       
        if strcmp(tmp.String, 'Fit1')
            set(handles.uitable_OptFit1,    'Visible', 'on');
            set(handles.uitable_OptFit2,    'Visible', 'off');
            set(handles.uitable_ResultFit1, 'Visible', 'on');
            set(handles.uitable_ResultFit2, 'Visible', 'off');
        elseif strcmp(tmp.String, 'Fit2')
            set(handles.uitable_OptFit1,    'Visible', 'off');
            set(handles.uitable_OptFit2,    'Visible', 'on');
            set(handles.uitable_ResultFit1, 'Visible', 'off');
            set(handles.uitable_ResultFit2, 'Visible', 'on');
        end
    end
   
%----------------------------
% "MODEL OPTIONS" UITABLE
%----------------------------
handles.nFiles = 0;

handles.uitable_OptFit1 = uitable(panel_ModelOpt,...
    'Tag',              'uitable_OptFit1',...
    'ColumnFormat',     {'numeric' 'numeric' 'numeric' 'numeric' 'numeric' 'numeric'},...
    'Data',             ModelOptions1,...
    'Units',            'normalized', ...
    'Position',         [0.01 .25 .99 .745],...
    'Visible',          'on',...
    'ColumnEditable',   [true, true, true, true, true, true, false],...
    'ColumnWidth',      {65 65 65 65 65 65 65 65 65},...
    'ColumnName',       {'K'...
                        '<html><center />&alpha<br /> [Gy<sup>-1</sup>]</html>' ...
                        '<html><center />&beta<br />[Gy<sup>-2</sup>]</html>' ...
                        '<html><center>&gamma <br /> [days<sup>-1</sup>]</center></html>' ...
                        '<html><center />a <br />[mo<sup>-1</sup>]</html>' '<html>&delta</html>'...
                        'Delete'},...
    'RowName',          {'Initial Guess' 'Lower limit' 'Upper limit'},...
    'Userdata',         ModelOptions1,...
    'Tooltip',          {['<html><center> Define options to perform the fit </center><br />' ...
                          'Initial guess: an apropriate guess for each parameter, based on the radiobiological expertise of the user. <br />' ...
                          'Lower limit: lower bound of a range to serach for the fited parameter. <br />' ...
                          'Upper limit: upper bound of a range to serach for the fited parameter. <br />' ...
                          '<br />'...
                          'NOTES: <br />' ...
                          '- the initial guess should be inside the lower to upper limits range; <br />' ...
                          '- the wider the range, the more probable is that the algorithm will not converge to an optimal solution, or will converge at all; <br />' ...
                          '- these are the default values used to estimate the parameters for a liver irradiation; </html>']},... 
    'CellEditCallback', @fitoptionsuitable_Callback,...
    'CellSelectionCallback', @(s,e) delete_count_row(e));
        % s: handle of the uitable object
        % e: event data structure containing 
        % information about the cell selection event

handles.uitable_OptFit2 = uitable(panel_ModelOpt,...
    'Tag',              'uitable_OptFit2',...
    'ColumnFormat',     {'numeric' 'numeric' 'numeric' 'numeric' 'numeric' 'numeric'},...
    'Data',             ModelOptions2,...
    'Units',            'normalized', ...
    'Position',         [0.01 .25 .99 .745],...
    'Visible',          'off',...
    'ColumnEditable',   true,...
    'ColumnWidth',      {65 65 65 65 65 65 65 65},...
    'ColumnName',       {'<html>K<sub>50</sub><span>&#47;</span>K<sub>0</sub></html>'...
                         '<html><center />&alpha<br /> [Gy<sup>-1</sup>]</html>' ...
                         '<html><center />&beta<br />[Gy<sup>-2</sup>]</html>'...
                         '<html><center>&gamma <br /> [day<sup>-1</sup>]</center></html>' ...
                         '<html><center /> &sigma<sub>k</sub> <span>&#47;</span>K<sub>0</sub></html>'...
                         '<html>&delta</html>'},...
    'RowName',          {'Initial Guess' 'Lower limit' 'Upper limit'},...
    'Userdata',         ModelOptions2,...
    'Tooltip',          {['<html><center> Define options to perform the fit </center><br />' ...
                          'Initial guess: an apropriate guess for each parameter, based on the radiobiological expertise of the user. <br />' ...
                          'Lower limit: lower bound of a range to serach for the fited parameter. <br />' ...
                          'Upper limit: upper bound of a range to serach for the fited parameter. <br />' ...
                          '<br />'...
                          'NOTES: <br />' ...
                          '- the initial guess should be inside the lower to upper limits range; <br />' ...
                          '- the wider the range, the more probable is that the algorithm will not converge to an optimal solution, or will converge at all; <br />' ...
                          '- these are the default values used to estimate the parameters for a liver irradiation; </html>']},...
    'CellEditCallback', @fitoptionsuitable_Callback);

    function fitoptionsuitable_Callback(hObject,event)        
        tmp = get(hObject,'Data');                       % keep the data from the table somewhere
        input = cell2mat(...
        tmp(event.Indices(1),event.Indices(2)));         % The input given by the user is kept as a double
                                                         % If the input is other than numeric, it will be passed as
                                                         % a NaN double;
        if ~isnan(input)                                 % In the case it's a number                               
                                                         
            if input <0                                  % Check if it's negative
                prevState = get(hObject, 'Userdata');    % Gets the previous state of the table, stored in the Userdata
                set(hObject, ...
                    'Data', prevState);                  % Updates the data in the table back to the previous state, before editing
                errordlg(['These parameters are positive, non-zero values. '...
                          'Use point decimal separator (e.g. 3.14 instead of 3,14). ' ...
                          'Cientific notation is valid (e.g. 314 = 3.14e2).'], 'Invalid Input')
                                                         
                                                         % And check if it's not zero in the case 
            elseif input == 0 && event.Indices(1) ~= 2   % the change is on rows 1 or 3 (initial guess and upper limit)
                warndlg(['Are you sure this is the correct input? '...
                         'Tipicaly these parameters are positive, non-zero values. '...
                         'Use point decimal separator (e.g. 3.14 instead of 3,14). ' ...
                         'Cientific notation is valid (e.g. 314 = 3.14e2).'], 'Input Warning')
            end

        set(hObject, ...                                 % If the input is not a NaN, and fullfill the previous conditions                          
            'Userdata',tmp);                             % then it's kept on the table and stored in the Userdata                            
            
        else                                             % Otherwise, if the input is NaN
            prevState = get(hObject, 'Userdata');        % Gets the previous state of the table, stored in the Userdata
            set(hObject, ...
                'Data', prevState);                      % Updates the data in the table back to the previous state, before editing
            errordlg(['Input must be a number! ' ...     % Tells what the input must be
                      'Tipicaly these parameters are positive, non-zero values.'...
                      'Use point decimal separator (e.g. 3.14 instead of 3,14). ' ...
                      'Cientific notation is valid (e.g. 314 = 3.14e2).'], 'Invalid Input')            
        end
     end

% Get current data from the table
tableData = get(handles.uitable, 'Data');
% Count the number of selected files
numberfiles = sum(cell2mat(tableData(:, 1)));
handles.numFiles = numberfiles;

%--------------------------------------------------------------------------
% BUTTON FOR THE PLOTS THE USER WANTS TO SEE (MAXIMUM OF 2)
%--------------------------------------------------------------------------
handles.pushbutton_Plots = uicontrol(panel_ModelOpt,...
    'Tag',              'pushbutton_Plots',...
    'Style',            'pushbutton', ...
    'String',           'Select Plot(s)',...
    'Units',            'Normalized',...
    'FontSize',         12,...
    'Position',         [.5 .02 .2 .22],...
    'Enable',           'on',...
    'ForegroundColor',  "k",...
    'BackgroundColor',  '#D95319',...
    'Tooltipstring',    'Select Plot(s) you want to visualize on the right panel',...
    'Callback',         @(btn, event)pushbutton_Plots_Callback); 

% when the button is clicked it opens a new window for the user 
% to select plot(s) if the number of selected files is at 
% least 5

% This function creates a new UI figure for the selection window
% where the user selects the plots he wants to see (1 or 2),
% the tau values needed if he wants to plot the BED or EQDX
% and the d value he's interested in (the default is 2 Gy/fx)

% input: handles with the following variables stored: 
    % valSel - bool to store if the user selection is valid or not
    % listFits - list with the selected fit(s)
    % listPlots - list with the selected plot(s)
    % tauValues - list with lists of tau values
    % XValues - values for the dose per fraction (Gy/fx) for the EQDX
    % dValue - value for the dose per fraction (Gy/fx)


function pushbutton_Plots_Callback(~,~)

    %--------------------------------------------------------------------------
    % INITIALIZATION OF THE OUTPUT VARIABLES
    %--------------------------------------------------------------------------

    handles.valSel = false; % bool to store if the user selection is valid or not
                        % we start by assuming the user's choice is not valid
    handles.listFits = [0, 0]; % list with the selected fit(s)
                           % the order is the following: [FIT1, FIT2]
    handles.listPlots = [0, 0, 0, 0, 0, 0]; % list with the selected plot(s)
                                        % the order is the following: [BED1, EQDX1, FIT1, BED2, EQDX2, FIT2]
    handles.tauValues = {0, 0, 0, 0}; % list with lists of tau values
                                  % the order is the following: {BED1, EQDX1, BED2, EQDX2}
    handles.XValues = [2,2]; % list with values for the dose per fraction (Gy/fx) of the EQDX (Equivalent Dose in XGy fractions) 
                         % for both fits. the order is the following: [FIT1, FIT2]. the default value is 2 Gy/fx
    handles.dValue = 2; % value for the dose per fraction (Gy/fx) of the BED (Biological Effective Dose)
                    % the default value is 2 Gy/fx

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions % 

    function [XValues] = XvalButtonCallback(~,~,n,XValues) 
        % Function to open a box where the user can put a value for X for the
        % EQDX (Equivalent Dose in XGy fractions) 
        % input:
            % XValues = 2 (default)
            % the selected files
            % n - index of the fit in question to know where to place the new
            % value of X choosen by the user
            % order: [FIT1,FIT2]
        % variables:
            % XValid - bool to store if the X selected by the user is valid
        % output:
            % XValues - values of X selected by the user, and, thus, updated
        persistent enteredValues; % Use persistent variable to store entered values
    
        if isempty(enteredValues)
            enteredValues = []; % Initialize the array if it's empty
        end

        XValid = false; % We start by assuming the user's choice is not valid
    
        prompt = 'Enter a unique positive real value:';
        dlgTitle = 'X value';
        numLines = 1;
        defaultAnswer = {''}; % Initial empty string
        input = inputdlg(prompt, dlgTitle, numLines, defaultAnswer);
    
        if isempty(input)
            % User canceled the input dialog
            return;
        end
    
        % Convert the input cell array to a string
        inputStr = input{1};
    
        % Convert the string to a number and validate
        X = str2double(inputStr);
    
        if ~isnan(X) && X > 0 && floor(X) == X
            % Check if the entered value is unique
            if ~ismember(X, enteredValues)
                XValid = true;
                enteredValues = [enteredValues, X]; % Add the value to the array
            else
            % Entered value is not unique
                errordlg('Entered value is not unique. Please enter a unique positive real number.', 'Error');
              
            end
        else
        % Invalid input
            errordlg('Invalid input. Please enter a unique positive real number.', 'Error');
        end

        if XValid == true
            XValues(n) = X; 
            disp('X:');
            disp(X);
        end

    end


    function [dValue] = dvalButtonCallback(~,~,dValue)
        % Function to open a box where the user can put a reference value for d
        % - dose per fraction (Gy/fx) of the BED (Biological Effective Dose)
        % input:
            % dValue = 2 (default)
        % variables:
            % dValid - bool to store if the d selected by the user is valid
        % output:
            % dValue - value of d selected by the user, and, thus, updated
        persistent enteredValues; % Use persistent variable to store entered values
    
        if isempty(enteredValues)
            enteredValues = []; % Initialize the array if it's empty
        end

        dValid = false; % We start by assuming the user's choice is not valid
    
        prompt = 'Enter a unique positive real value:';
        dlgTitle = 'd value';
        numLines = 1;
        defaultAnswer = {''}; % Initial empty string
        input = inputdlg(prompt, dlgTitle, numLines, defaultAnswer);
    
        if isempty(input)
            % User canceled the input dialog
            return;
        end
    
        % Convert the input cell array to a string
        inputStr = input{1};
    
        % Convert the string to a number and validate
        d = str2double(inputStr);
    
        if ~isnan(d) && d > 0 && floor(d) == d
            % Check if the entered value is unique
            if ~ismember(d, enteredValues)
                dValid = true;
                enteredValues = [enteredValues, d]; % Add the value to the array
            else
            % Entered value is not unique
                errordlg('Entered value is not unique. Please enter a unique positive real number.', 'Error');
            end
        else
        % Invalid input
            errordlg('Invalid input. Please enter a unique positive real number.', 'Error');
        end

        if dValid == true
            dValue = d; 
        end
    end

    function saving_taus(~)
    % Saves the taus presented on the selected files
    % Function that generates an array containing the taus presented on the 
    % selected files. It will be useful later when the user clicks on the 
    % "Select Plot(s)" button and choses tau values either for the BED or EQDX plots,
    % because at least one of these selected taus must be at least on one of the files
    % otherwise it will not be possible to generate the plot(s)


        % Initialize the taus_data array
        all_taus = [];
        
        % Get the data from the table
        DataSetsList = get(handles.uitable,'RowName');
        data = get(handles.uitable,'UserData');
        Selected = data(:,1); % Selection state of the data
        numDatasets = numel(DataSetsList);
        
        % If there is data
        if numDatasets ~= 0 
            for i = 1:numDatasets
                if cell2mat(Selected(i)) == 1
                    % Load data from file
                    InputData = load(fullfile('./Data/', [DataSetsList{i} '.m']));
                    Tau = InputData(:,1);
                    % Concatenate tau values to the all_taus array
                    all_taus = [all_taus; Tau];
                 
                end
            end
        end

        % Save taus_data in the handles structure 
        handles.taus_data = all_taus;
    end

    % Function to handle Fit1
    function Fit1Callback(~, event, secondaryPanelFit1)
        checkboxValue = event.Source.Value;
        if checkboxValue == 1 % Check if the checkbox is activated
            set(secondaryPanelFit1, 'Visible', 'on');
        else
            set(secondaryPanelFit1, 'Visible', 'off');
        end
    end


    % Function to handle Fit2
    function Fit2Callback(~, event, secondaryPanelFit2)
        checkboxValue = event.Source.Value;
        if checkboxValue == 1 % Check if the checkbox is activated
            set(secondaryPanelFit2, 'Visible', 'on');
        else
            set(secondaryPanelFit2, 'Visible', 'off');
        end
    end

    % Function to handle BED from Fit1
    function BEDFit1Callback(~, event, BEDPanelFit1)
        checkboxValue = event.Source.Value;
        if checkboxValue == 1 % Check if the checkbox is activated
            set(BEDPanelFit1, 'Visible', 'on');
        else
            set(BEDPanelFit1, 'Visible', 'off');
        end
    end

    % Function to handle EQDX from Fit1
    function EQDXFit1Callback(~, event, EQDXPanelFit1)
        checkboxValue = event.Source.Value;
        if checkboxValue == 1 % Check if the checkbox is activated
            set(EQDXPanelFit1, 'Visible', 'on');
        else
            set(EQDXPanelFit1, 'Visible', 'off');
        end
    end

    % Function to handle BED from Fit2
    function BEDFit2Callback(~, event, BEDPanelFit2)
        checkboxValue = event.Source.Value;
        if checkboxValue == 1 % Check if the checkbox is activated
            set(BEDPanelFit2, 'Visible', 'on');
        else
            set(BEDPanelFit2, 'Visible', 'off');
        end
    end

    % Function to handle EQDX from Fit2
    function EQDXFit2Callback(~, event, EQDXPanelFit2)
        checkboxValue = event.Source.Value;
        if checkboxValue == 1 % Check if the checkbox is activated
            set(EQDXPanelFit2, 'Visible', 'on');
        else
            set(EQDXPanelFit2, 'Visible', 'off');
        end
    end

    
    function tauValid = askTau(~,~,n)
        % Function to open a box where the user can put the tau values
        % input:
            % tausData (stored in the handles structure) - taus available on
            % the selected files
            % tausValues (stored in the handles structure) - previous values 
            % of tauValues
            % n - index of the list of lists of tau values where to place
            % the values choosen by the user
            % order: [BED1,EQDX1,BED2,EQDX2]
        % variables:
            % tauFiles - bool to store if the taus selected by the user are
            % present on at least one of selected the data files
        % output:
            % tauValid - bool to store if the user made a valid choice or not
            % tauValues (list of taus selected by the user) is going to be saved on the handles structure
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Function
        function found_match = check_match(taus, tausData)
            % Initialize a flag to indicate if a match is found
            found_match = false;
    
            % Iterate over each value in tausData
            for i = 1:numel(tausData)
                % Iterate over each value in taus
                for j = 1:numel(taus)
                        % Check if the absolute difference is less than 2
                        if abs(tausData(i) - taus(j)) < 2
                            % If a match is found, set the flag and break out of the loop
                            found_match = true;
                            return;
                        end
                end
            end
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        tausData = handles.taus_data; % array containing the taus presented on the selected files
        tauValues = handles.tauValues;

        tauFiles = false;
        tauValid = false; % we start by assuming the user's choice is not valid
         
        prompt = 'Enter positive integers separated by commas:';
        dlgTitle = 'Tau values';
        numLines = 1;
        defaultAnswer = {''}; % Initial empty string
        input = inputdlg(prompt, dlgTitle, numLines, defaultAnswer);

        if isempty(input)
            % User canceled the input dialog
            return;
        end

        % Convert the input cell array to a string
        inputStr = input{1};

        % Split the input string into an array of strings using commas as the delimiter
        valuesStr = strsplit(inputStr, ',');

        % Convert the strings to numbers and validate
        taus = str2double(valuesStr);
        
        % Check if any of the selected taus is present on at least one of 
        % the data files. Otherwise it will not be possible to generate the
        % plot(s)
        if check_match(taus, tausData) == 1
            tauFiles = true;
        
        end

        if tauFiles == true
        
            if all(~isnan(taus)) && all(taus > 0) && all(floor(taus) == taus)
                % All values are positive integers
                % Process the values as needed
                tauValid = true;
            else
                % Invalid input
                errordlg('Invalid input. Please enter positive integers separated by commas.', 'Error');
            end
        else
            % Invalid input
            errordlg('Invalid input. Please enter values present on at least 1 data file.', 'Error');

        end

       
        if tauValid == true
            tauValues{n} = taus; 
            % disp('tauValues_total:');
            % disp(tauValues);
            % disp('tauValues_n:');
            % disp(tauValues{n});
       
        end

        % Store the output values in the handles structure
        handles.tauValues = tauValues;

        % disp('tauValid:');
        % disp(tauValid);
        % disp('tauValues:');
        % disp(tauValues);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calling the saving_taus function
    saving_taus;

    tausData = handles.taus_data; % array containing the taus presented on the selected files

    valSel = handles.valSel; % bool to store if the user selection is valid or not
                             % we start by assuming the user's choice is not valid
    listFits = handles.listFits; % list with the selected fit(s)
                                 % the order is the following: [FIT1, FIT2]
    listPlots = handles.listPlots; % list with the selected plot(s)
                               % the order is the following: [BED1, EQDX1, FIT1, BED2, EQDX2, FIT2]
    tauValues = handles.tauValues; % list with lists of tau values
                                   % the order is the following: {BED1, EQDX1, BED2, EQDX2}
    XValues = handles.XValues; % list with values for the dose per fraction (Gy/fx) of the EQDX
                               % (Equivalent Dose in XGy fractions) for both fits. 
                               % the order is the following: [FIT1, FIT2]. the default value is 2 Gy/fx
                      

    dValue = handles.dValue; % value for the dose per fraction (Gy/fx) of the BED (Biological Effective Dose)
                             % the default value is 2 Gy/fx


    % check if the number of selected files is valid
    numberfiles = handles.numFiles;
    if numberfiles < 5
        msg = 'Please select at least 5 Data Files';
        % Display the message to the user
        msgbox(msg, 'Select Data Files');
        return;
    else % the user's choice is valid 
        % opens a new figure
        selectionFig = uifigure('Name', 'Plot Selection', 'Position', [500, 500, 500, 500]);
    end
    
    handles.SelectPlot = uibuttongroup('Parent', selectionFig, ...
        'Tag', 'buttongroup', ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Units', 'normalized', ...
        'Position', [0 0 1.0 1.0]);

    
    %%%%%%%%%%%%%%%%%% FIT 1 %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Panel for the Fit1 Secondary Buttons
    secondaryPanelFit1 = uipanel('Parent', selectionFig, ...
        'Title', '', ...
        'Tag', 'secondary_buttons_fit1', ...
        'FontSize', 10, ...
        'BorderType',  "none",...
        'FontWeight', 'bold', ...
        'Units', 'normalized', ...
        'Position', [.05 .30 .45 .2], ...
        'Visible', 'off');

   
    % Fit1 Secondary Buttons
    % Fit1
    handles.SecondarySelect_Fit1 = uicontrol('Parent', secondaryPanelFit1, ...
        'Tag', 'SecondarySelect_Fit1', ...
        'Style', 'checkbox', ...
        'String', 'Fit1', ...
        'Units', 'Normalized', ...
        'Position', [.05 .6 .9 .2], ... 
        'FontSize', 8, ...
        'HorizontalAlignment', 'center');

    % BED
    handles.SecondarySelect_BED1 = uicontrol('Parent', secondaryPanelFit1, ...
        'Tag', 'SecondarySelect_BED1', ...
        'Style', 'checkbox', ...
        'String', 'BED', ...
        'Units', 'Normalized', ...
        'Position', [.05 .3 .9 .3], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'center');

    % Panel for the tau values for BED
    BEDPanelFit1 = uipanel('Parent', secondaryPanelFit1, ...
        'Title', '', ...
        'Tag', 'tau_BED_fit1', ...
        'FontSize', 8, ...
        'BorderType',  "none",...
        'FontWeight', 'bold', ...
        'Units', 'normalized', ...
        'Position', [.27 .3 .63 .27], ... 
        'Visible', 'off');
   
    % Button to select the tau values
    handles.tauBEDFit1 = uicontrol('Parent', BEDPanelFit1, ...
        'Style', 'pushbutton', ...
        'String', 'Select 𝜏 value(s).',...
        'Units', 'Normalized', ...
        'Position', [0.008 0.05 .80 .91], ... 
        'FontSize', 8, ...
        'ForegroundColor',  "k",...
        'BackgroundColor',  '#FFFFFF', ...
        'Tooltipstring',    'Select 𝜏 value(s) in months separated by commas. Do not forget to select values present in your data file.',...
        'Callback', @(src, event)askTau(src, event,1));

    % Callback for BED from Fit1
    set(handles.SecondarySelect_BED1, 'Callback', @(src, event) BEDFit1Callback(src, event, BEDPanelFit1)); 
    
    % EQDX
    handles.SecondarySelect_EQDX1 = uicontrol('Parent', secondaryPanelFit1, ...
        'Tag', 'SecondarySelect_EQDX1', ...
        'Style', 'checkbox', ...
        'String', 'EQDX', ...
        'Units', 'Normalized', ...
        'Position', [.05 0 .9 .3], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'center');

    % Panel for the tau and X values for EQDX
    EQDXPanelFit1 = uipanel('Parent', secondaryPanelFit1, ...
        'Title', '', ...
        'Tag', 'tau_EQDX_fit1', ...
        'FontSize', 8, ...
        'BorderType',  "none",...
        'FontWeight', 'bold', ...
        'Units', 'normalized', ...
        'Position', [.27 0 .63 .27], ...   
        'Visible', 'off');

    % Button to select the tau values
    handles.tauEQDXFit1 = uicontrol('Parent', EQDXPanelFit1, ...
        'Style', 'pushbutton', ...
        'String', 'Select 𝜏 value(s).',...
        'Units', 'Normalized', ...
        'Position', [0.008 0.05 .80 .91], ... 
        'FontSize', 8, ...
        'ForegroundColor',  "k",...
        'BackgroundColor',  '#FFFFFF',...
        'Tooltipstring',    'Select 𝜏 value(s) in months separated by commas. Do not forget to select values present in your data file.',...
        'Callback', @(src, event)askTau(src, event,2));

 

    % Button to select the X value 
    handles.XEQDXFit1 = uicontrol('Parent', EQDXPanelFit1, ...
        'Style', 'pushbutton', ...
        'String', 'X',...
        'Units', 'Normalized', ...
        'Position', [0.84 0.05 0.17 .91], ... 
        'FontSize', 8, ...
        'ForegroundColor',  "k",...
        'BackgroundColor',  '#FFFFFF',...
        'Tooltipstring',    'Choose the value of the dose per fraction, X, for the EQDX. The default value is 2 Gy/fx.',...
        'Callback', @(src, event)XvalButtonCallback(src, event,1,XValues)); 

    disp('handles.XValues:');
    disp(handles.XValues);

    % Callback for EQDX from Fit1
    set(handles.SecondarySelect_EQDX1, 'Callback', @(src, event) EQDXFit1Callback(src, event, EQDXPanelFit1));
   

    % Fit 1 Button
    fit1Checkbox = uicontrol('Parent', selectionFig, ...
        'Style', 'checkbox', ...
        'String', 'Fit1:', ...
        'Units', 'Normalized', ...
        'Position', [.3 .5 .25 .1], ... 
        'FontSize', 10, ...
        'HorizontalAlignment', 'center', ...
        'TooltipString', ['<html><center>Select Model 1:<br />' ...
        'SR(d,abD,&tau) = exp(-K exp(-[&alpha(1+d/(&alpha/&beta)) D - &gamma T - a(&tau - T))<sup>&delta</sup>]))<br />' ...
        ' </center> <br />' ...
        'SR: Survival Rate in percentage (%) <br />' ...
        '&tau: elapsed time from the beginning of the treatment (months) <br />' ...
        '&gamma = ln2/T<sub>d</sub>, &alpha and &beta characterize the intrinsic radiosensitivity of cells <br />' ...
        'T<sub>d</sub>: potential doubling time <br />' ...
        'K, a and &delta are the remaining fitting parameters. </html>']);

    
    %%%%%%%%%%%%%%%%%%%%%%%

    % Callback for Fit1
    set(fit1Checkbox, 'Callback', @(src, event) Fit1Callback(src, event, secondaryPanelFit1));
    
    %%%%%%%%%%%%%%%%%% FIT 2 %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Panel for the Fit2 Secondary Buttons
    secondaryPanelFit2 = uipanel('Parent', selectionFig, ...
        'Title', '', ...
        'Tag', 'secondary_buttons_fit2', ...
        'FontSize', 10, ...
        'BorderType',  "none",...
        'FontWeight', 'bold', ...
        'Units', 'normalized', ...
        'Position', [.50 .30 .45 .2], ... 
        'Visible', 'off');


    % Fit2 Secondary Buttons
    % Fit2
    handles.SecondarySelect_Fit2 = uicontrol('Parent', secondaryPanelFit2, ...
        'Tag', 'SecondarySelect_Fit2', ...
        'Style', 'checkbox', ...
        'String', 'Fit2', ...
        'Units', 'Normalized', ...
        'Position', [.05 .6 .9 .3], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'center');

    % BED
    handles.SecondarySelect_BED2 = uicontrol('Parent', secondaryPanelFit2, ...
        'Tag', 'SecondarySelect_BED2', ...
        'Style', 'checkbox', ...
        'String', 'BED', ...
        'Units', 'Normalized', ...
        'Position', [.05 .3 .9 .3], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'center');

    % Panel for the tau values for BED
    BEDPanelFit2 = uipanel('Parent', secondaryPanelFit2, ...
        'Title', '', ...
        'Tag', 'tau_BED_fit2', ...
        'FontSize', 8, ...
        'BorderType',  "none",...
        'FontWeight', 'bold', ...
        'Units', 'normalized', ...
        'Position', [.27 .3 .63 .27], ...
        'Visible', 'off');

    % Button to select the tau values
    handles.tauBEDFit2 = uicontrol('Parent', BEDPanelFit2, ...
        'Style', 'pushbutton', ...
        'String', 'Select 𝜏 value(s).',...
        'Units', 'Normalized', ...
        'Position', [0.008 0.05 .80 .91], ...
        'FontSize', 8, ...
        'ForegroundColor',  "k",...
        'BackgroundColor',  '#FFFFFF',...
        'Tooltipstring',    'Select 𝜏 value(s) in months separated by commas. Do not forget to select values present in your data file.',...
        'Callback', @(src, event)askTau(src, event,3));

 

    % Callback for BED from Fit2
    set(handles.SecondarySelect_BED2, 'Callback', @(src, event) BEDFit2Callback(src, event, BEDPanelFit2));


    % EQDX
    handles.SecondarySelect_EQDX2 = uicontrol('Parent', secondaryPanelFit2, ...
        'Tag', 'SecondarySelect_EQDX2', ...
        'Style', 'checkbox', ...
        'String', 'EQDX', ...
        'Units', 'Normalized', ...
        'Position', [.05 0 .9 .3], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'center');

    % Panel for the tau and X values for EQDX
    EQDXPanelFit2 = uipanel('Parent', secondaryPanelFit2, ...
        'Title', '', ...
        'Tag', 'tau_EQDX_fit2', ...
        'FontSize', 8, ...
        'BorderType',  "none",...
        'FontWeight', 'bold', ...
        'Units', 'normalized', ...
        'Position', [.27 0 .63 .27], ... 
        'Visible', 'off');

    % Button to select the tau values
    handles.tauEQDXFit2 = uicontrol('Parent', EQDXPanelFit2, ...
        'Style', 'pushbutton', ...
        'String', 'Select 𝜏 value(s).',...
        'Units', 'Normalized', ...
        'Position', [0.008 0.05 .80 .91], ...
        'FontSize', 8, ...
        'ForegroundColor',  "k",...
        'BackgroundColor',  '#FFFFFF',...
        'Tooltipstring',    'Select 𝜏 value(s) in months separated by commas. Do not forget to select values present in your data file.',...
        'Callback', @(src, event)askTau(src, event,4));


    % Button to select the X value 
    handles.XEQDXFit2 = uicontrol('Parent', EQDXPanelFit2, ...
        'Style', 'pushbutton', ...
        'String', 'X',...
        'Units', 'Normalized', ...
        'Position', [0.84 0.05 0.17 .91], ... 
        'FontSize', 8, ...
        'ForegroundColor',  "k",...
        'BackgroundColor',  '#FFFFFF',...
        'Tooltipstring',    'Choose the value of the dose per fraction, X, for the EQDX. The default value is 2 Gy/fx.',...
        'Callback', @(src, event)XvalButtonCallback(src, event,2,XValues)); 

    % Callback for BED from Fit2
    set(handles.SecondarySelect_EQDX2, 'Callback', @(src, event) EQDXFit2Callback(src, event, EQDXPanelFit2));

    % Fit 2 Button
    fit2Checkbox = uicontrol('Parent', selectionFig, ...
        'Style', 'checkbox', ...
        'String', 'Fit2:', ...
        'Units', 'Normalized', ...
        'Position', [.70 .5 .25 .1], ...
        'FontSize', 10, ...
        'HorizontalAlignment', 'center', ...
        'TooltipString', ['<html><center>Select Model 2:<br /> ' ...
        'SR(d,D,&tau) = 1 - (2&pi)<sup>-1/2</sup> &int<sub>-&infin</sub><sup>t</sup> exp(-x<sup>2</sup>/2) dx <br /> ' ...
        't = (exp(-[&alpha(1+d/(&alpha/&beta))D - &gamma T -(&gamma(&tau - T))<sup>&delta</sup>])-K<sub>50</sub>/K<sub>0</sub>)/(&sigma<sub>k</sub>/K<sub>0</sub>) <br /> ' ...
        '</center> <br />' ...
        'SR: Survival Rate in percentage (%) <br /> ' ...
        '&tau: elapsed time from the beginning of the treatment (months) <br /> ' ...
        't = (K - K<sub>50</sub>)/&sigma<sub>k</sub> <br />' ...
        'K<sub>50</sub> is the critical number of tumour clonogens corresponding to death in 50 % patients <br />' ...
        '&sigma<sub>k</sub> is the gaussian width for the distribution of critical clonogen numbers <br />' ...
        'Dependence of tumor cells on D, d, T and &tau is given by the following LQ inspired model: <br />' ...
        'K = K<sub>50</sub> exp(-[&alpha(1+d/(&alpha/&beta))D - &gamma T -(&gamma(&tau - T))<sup>&delta</sup>]) <br />' ...
        '(&gamma(&tau - T))<sup>&delta</sup> characterizes the time dependence of tumor regrowth after completion of RT. </html>']);


    % Callback for Fit2
    set(fit2Checkbox, 'Callback', @(src, event) Fit2Callback(src, event, secondaryPanelFit2));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Select Plot(s) button
    selectPlotsButton = uicontrol('Parent', selectionFig, ...
        'Style', 'pushbutton', ...
        'String', 'Select Plot(s)', ...
        'Units', 'Normalized', ...
        'Position', [.4 .1 .2 .1], ...
        'FontSize', 10, ...
        'ForegroundColor',  "k",...
        'BackgroundColor',  '#D95319',...
        'Callback', @(src, event) SelectPlotsCallback(src, valSel, listFits,listPlots,XValues,dValue,selectionFig)); 


    % Choose d value
    dvalButton = uicontrol('Parent', selectionFig, ...
        'Style', 'pushbutton', ...
        'String', 'd', ...
        'TooltipString', 'Choose the value of the dose per fraction, d. The default value is 2 Gy/fx.', ...
        'Units', 'Normalized', ...
        'Position', [.45 0.225 0.1 .05], ... 
        'FontSize', 8, ...
        'ForegroundColor',  "k",...
        'BackgroundColor',  '#FFFFFF',...
        'Callback', @(src, event) dvalButtonCallback(src, event)); 
end
     
    % Callback for "Select Plot(s)" button:

    % Function to:
        % see if the number of selected plot(s) is valid
        % see if there are selected tau values
        % store the fits(s) and plot(s) the user wants
    % input
        % valSel - bool to store if the user selection is valid or not
        % listFits - list with the selected fit(s)
        % listPlots - list with the selected plot(s)
        % tauValues - list with the selected tau(s)
    % output
        % listFits - updated with the fit(s) the user wants to perform
        % listPlots - updated with the plot(s) the user wants to see
 
    function [listFits,listPlots] = SelectPlotsCallback(~,valSel, listFits,listPlots,XValues,dValue,selectionFig) 
        
       

        tauValues = handles.tauValues;

        
        numSel = false; % variable to store if the number of plot(s) 
                        % selected by the user is valid or not

        % Count the number of selected secondary buttons for Fit1
        numSelectedFit1 = sum([
            handles.SecondarySelect_Fit1.Value
            handles.SecondarySelect_BED1.Value
            handles.SecondarySelect_EQDX1.Value
        ]);

        % Count the number of selected secondary buttons for Fit2
        numSelectedFit2 = sum([
            handles.SecondarySelect_Fit2.Value
            handles.SecondarySelect_BED2.Value
            handles.SecondarySelect_EQDX2.Value
        ]);

        % Check the number of selected buttons and display a message
        if numSelectedFit1 == 0 && numSelectedFit2 == 0
            msg = 'Please select 1 or 2 plot(s).';
        elseif numSelectedFit1 + numSelectedFit2 > 2
            msg = 'You can select up to 2 plots.';
        elseif (numSelectedFit1 == 1 || numSelectedFit1 == 2) && numSelectedFit2 == 0
        % 1 or 2 plot(s) only from the first fit
            listFits(1) = 1;
            numSel = true; % the user's choice is valid
        elseif (numSelectedFit2 == 1 || numSelectedFit2 == 2) && numSelectedFit1 == 0
        % 1 or 2 plot(s) only from the second fit
            listFits(2) = 1;
            numSel = true; % the user's choice is valid 
        elseif numSelectedFit1 == 1 && numSelectedFit2 == 1 % 1 plot from the first fit, and 1 from the second
            listFits(1) = 1;
            listFits(2) = 1;
            numSel = true; % the user's choice is valid 
        end

        % See if the user selected tau values in case he selected BED
        % and/or EQDX plot(s)

        if numSel == true 
            if handles.SecondarySelect_BED1.Value == 1
                if tauValues{1} == 0
                    msg = 'Please select tau values for the BED Fit1 Plot.';
                else
                    valSel = true;
                end
            elseif handles.SecondarySelect_EQDX1.Value == 1
                if tauValues{2} == 0
                    msg = 'Please select tau values for the EQDX Fit1 Plot.';
                else
                    valSel = true;
                end
            elseif handles.SecondarySelect_BED2.Value == 1
                if tauValues{3} == 0
                    msg = 'Please select tau values for the BED Fit2 Plot.';
                else
                    valSel = true;
                end
            elseif handles.SecondarySelect_EQDX2.Value == 1
                if tauValues{4} == 0
                    msg = 'Please select tau values for the EQDX Fit2 Plot.';
                else
                    valSel = true; 
                end
            else % the user didn't select BED or EQDX plot(s), therefore the
                % tau values are not necessary and the selection is valid
                valSel = true;
            end
        end
        

        % Save selected plot(s) in a list
        % listPlots = [BED1, EQDX1, FIT1, BED2, EQDX2, FIT2]
        if valSel == true

            if handles.SecondarySelect_BED1.Value == 1
                listPlots(1) = 1; 
            end

            if handles.SecondarySelect_EQDX1.Value == 1
                listPlots(2) = 1;
            end
  
            if handles.SecondarySelect_Fit1.Value == 1
                listPlots(3) = 1;
            end
        
            if handles.SecondarySelect_BED2.Value == 1
                listPlots(4) = 1;
            end

            if handles.SecondarySelect_EQDX2.Value == 1
                listPlots(5) = 1;
            end
  
            if handles.SecondarySelect_Fit2.Value == 1
                listPlots(6) = 1;
            end

            % Display the message to the user in case the selection is valid
            msgbox('Valid Selection', 'Plot Selection');
            % Close the plot selection window
            close(selectionFig);
        end

        if valSel == false || numSel == false 
            % disp('valSel');
            % disp(valSel);
            % disp('numSel');
            % disp(numSel);

            % Display the message to the user in case the selection is not valid
            msgbox(msg, 'Plot Selection');
        end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Store the output values in the handles structure
    handles.valSel = valSel;
    handles.listFits = listFits;
    handles.listPlots = listPlots;
    handles.tauValues = tauValues;
    handles.XValues = XValues;
    handles.dValue = dValue;

  end

%------------------------------------------------
% "PERFORM FIT(S)" BUTTON
%------------------------------------------------
handles.pushbutton_Fit = uicontrol(panel_ModelOpt,...
    'Tag',              'pushbutton_Fit',...
    'Style',            'pushbutton', ...
    'String',           'Perform Fit(s)',...
    'Units',            'Normalized',...
    'FontSize',         12,...
    'Position',         [.75 .02 .2 .22],...
    'Enable',           'on',...
    'ForegroundColor',  "k",...
    'BackgroundColor',  '#D95319',...
    'Tooltipstring',    'Perform fit for the selected files',...
    'Callback',         @pushbutton_Fit_Callback);

    function pushbutton_Fit_Callback(~,~) 
        % Access the values from handles
        valSel = handles.valSel;
        listFits = handles.listFits;
        listPlots = handles.listPlots;
        tauValues = handles.tauValues;
        XValues = handles.XValues;
        dValue = handles.dValue;
        
        cla(handles.axes_left_plot, 'reset');                    % clear both axes
        cla(handles.axes_right_plot, 'reset');

        data = get(handles.uitable,'Userdata');              % Gets "Userdata" from Data Details table
        % statefit1 = get(handles.uitable_OptFit1, 'Visible'); % State of button Fit1 (On or Off)
        % statefit2 = get(handles.uitable_OptFit2, 'Visible'); % State of button Fit2 (On or Off)
        DataFiles = strings(0);
        DataSetsList = get(handles.uitable,'RowName');
        cellstate = cellfun(@isempty,data);                  % logical value 1 if cells are empty


        
        if valSel == false % if the user selection is not valid we don't advance
            msg = 'Please Select 1 or 2 Plot(s) by clicking on the "Select Plot(s)" button.';
            msgbox(msg, 'Plot Selection');
        else % we advance
            % see what fits we need to perform according to the user
            % plot(s) choices
          
            % disp('listFits');
            % disp(listFits);
            % disp('listPlots');
            % disp(listPlots);

            if listFits(1) == 1 && listFits(2) == 0 % we'll perform only the 1st fit

                if isempty(data)                                            % If the table is empty
                    helpdlg('No data to perform the fit!','')               % we have nothing to display

                elseif any(cellstate(:,4)) || any(cellstate(:,5)) || ...    % Check if there are any empty cells
                    any(cellstate(:,6)) || any(cellstate(:,7))              % in columns N, D, d and T

                    errordlg(['Input must be a number!' ...                 % Propts what the input must be
                    'Use point decimal separator (e.g. 3.14 instead of 3,14).' ...
                    'Cientific notation is valid (e.g. 314 = 3.14e2). ' ...
                    'Number of patients in the study, total prescription dose, ' ...
                    'dose per fraction and total treatment time should be positive, non-zero values.'], 'Invalid Input') 

                else                                                        % If the table contains data
                    cla(handles.axes_left_plot, 'reset');                    % clear both axes
                    cla(handles.axes_right_plot, 'reset');
                    axes(handles.axes_left_plot);                          % Select axes_left_plot
                    enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity

                    %%%%%% data files %%%%%%
                    
                    Selected = data(:,1);
    
                    % Selection state of the data
                    for i = 1:numel(Selected)                       
                        if isequal(Selected(i),{1})                                                  % If it's selected
                            DataFiles = [DataFiles  strcat("./Data/",string(DataSetsList(i,:)),".m")];   % Complete the file names with the extension
                            file_names = cellstr(DataFiles);
                            
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    Bounds = get(handles.uitable_OptFit1, 'Userdata');                      % Check initial guess, upper and lower bounds to perform the fit
                    [p,up,gf] = fit1(file_names, data, Bounds);                             % Performs Fit1 (p->vector with parameters; up->vector with uncertainties)
                    FitData = {round(p(1),5)...                                             % Stores fited parameters
                    ,round(p(2),5)...
                    ,round(p(3),5)...
                    ,round(p(4),5)...
                    ,round(p(5),5)...
                    ,round(p(6),0)...
                    ,round(p(7),5)...
                    ,round(p(8),5)...
                    ,round(gf,2)};
                    UncertaintyData = {round(up(1),5)...                                    % Stores uncertainties of the parameters                     
                    ,round(up(2),5)...
                    ,round(up(3),5)...
                    ,round(up(4),5)...
                    ,round(up(5),5)...
                    ,round(up(6),0)...
                    ,round(up(7),5)...
                    ,round(up(8),5)...
                    ,'----'};

                    Results = [FitData; UncertaintyData; UncertaintyData];           
    
                    set(handles.uitable_ResultFit1,...                                      % Keep fited parameters information
                        'Data', Results,...                                                 % and displays it on the table
                        'Userdata', Results) 

                    % the user only selected one plot                                                                  
                    % tauValues = [BED1, EQDX1, BED2, EQDX2]

                    if listPlots(1) == 0 && listPlots(2) == 0 && listPlots(3) == 1 % the user only selected the FIT1 plot
                        % axes(handles.axes_left_plot);                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        % fit1(file_names, data, Bounds);
                        return;
                    
                    elseif listPlots(1) == 1 && listPlots(2) == 0 && listPlots(3) == 0 % the user only selected the BED1 plot
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        BED(file_names,data,p,1,tauValues(1),dValue); 
            
                    elseif listPlots(1) == 0 && listPlots(2) == 1 && listPlots(3) == 0 % the user only selected the EQDX1 plot
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        EQDX(file_names,data,p,1,tauValues(2),dValue,XValues(1));


                    % the user selects two plots
                    elseif listPlots(1) == 1 && listPlots(2) == 1 % the user selects BED1 and EQDX1
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        BED(file_names,data,p,1,tauValues(1),dValue); 

                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        EQDX(file_names,data,p,1,tauValues(2),dValue,XValues(1));

                    elseif listPlots(1) == 1 && listPlots(3) == 1 % the user selects BED1 and FIT1
                        hold on;
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        BED(file_names,data,p,1,tauValues(1),dValue);

                        % axes(handles.axes_left_plot);                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        % fit1(file_names,data, Bounds);

                    elseif listPlots(2) == 1 && listPlots(3) == 1 % the user selects EQDX1 and FIT1
                        hold on;
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        EQDX(file_names,data,p,1,tauValues(2),dValue,XValues(1));

                        % axes(handles.axes_left_plot);                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        % fit1(file_names,data, Bounds);

                    end
                end
                
        

            elseif listFits(1) == 0 && listFits(2) == 1 % we'll perform only the 2nd fit

                if isempty(data)                                        % If the table is empty
                    helpdlg('No data to perform the fit!','')           % we have nothing to display

                elseif any(cellstate(:,4)) || any(cellstate(:,5)) || ...    % Check if there are any empty cells
                    any(cellstate(:,6)) || any(cellstate(:,7))              % in columns N, D, d and T

                    errordlg(['Input must be a number!' ...                 % Propts what the input must be
                      'Use point decimal separator (e.g. 3.14 instead of 3,14).' ...
                      'Cientific notation is valid (e.g. 314 = 3.14e2). ' ...
                      'Number of patients in the study, total prescription dose, ' ...
                      'dose per fraction and total treatment time should be positive, non-zero values.'], 'Invalid Input') 

                else                                                        % If the table contains data
                                                             % If the table contains data
                    cla(handles.axes_left_plot, 'reset');                    % clear both axes
                    cla(handles.axes_right_plot, 'reset');
                    axes(handles.axes_left_plot);                          % Select axes_left_plot
                    enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity

                    %%%%%% data files %%%%%%
                    
                    Selected = data(:,1);
    
                    % Selection state of the data
                    for i = 1:numel(Selected)                       
                        if isequal(Selected(i),{1})                                                  % If it's selected
                            DataFiles = [DataFiles  strcat("./Data/",string(DataSetsList(i,:)),".m")];   % Complete the file names with the extension
                            file_names = cellstr(DataFiles);
                            
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%
                  
                    Bounds = get(handles.uitable_OptFit2, 'Userdata');                      % Check initial guess, upper and lower bounds to perform the fit
                    [p,up,gf] = fit2(file_names, data, Bounds);                             % Performs Fit2 (p->vector with parameters; up->vector with uncertainties)
                    FitData = {round(p(1),5)...                                             % Stores fited parameters
                       ,round(p(2),5)...
                       ,round(p(3),5)...
                       ,round(p(4),5)...
                       ,round(p(5),5)...
                       ,round(p(6),0)...
                       ,round(p(7),5)...
                       ,round(p(8),5)...
                       ,round(gf,2)};
                    UncertaintyData = {round(up(1),5)...                                    % Stores uncertainties of the parameters                     
                       ,round(up(2),5)...
                       ,round(up(3),5)...
                       ,round(up(4),5)...
                       ,round(up(5),5)...
                       ,round(up(6),0)...
                       ,round(up(7),5)...
                       ,round(up(8),5)...
                       ,'----'};

                    Results = [FitData; UncertaintyData; UncertaintyData];  
  
                    set(handles.uitable_ResultFit2,...                                      % Keep fited parameters information
                        'Data', Results,...                                                 % and displays it on the table
                        'Userdata', Results) 

                    % the user only selected one plot 
                    % tauValues = [BED1, EQDX1, BED2, EQDX2]                                                                 
            
                    
                    if listPlots(4) == 0 && listPlots(5) == 0 && listPlots(6) == 1 % the user only selected the FIT2 plot
                        % axes(handles.axes_left_plot)                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot)    % Enable its interactivity
                        % fit2(file_names,data, Bounds);
                        return;

                    elseif listPlots(4) == 1 && listPlots(5) == 0 && listPlots(6) == 0 % the user only selected the BED2 plot
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        BED(file_names,data,p,2,tauValues(3),dValue);
            
                    elseif listPlots(4) == 0 && listPlots(5) == 1 && listPlots(6) == 0 % the user only selected the EQDX2 plot
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        EQDX(file_names,data,p,2,tauValues(4),dValue,XValues(2));

                    % the user selects two plots
                    elseif listPlots(4) == 1 && listPlots(5) == 1 % the user selects BED2 and EQDX2
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        BED(file_names,data,p,2,tauValues(3),dValue);

                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        EQDX(file_names,data,p,2,tauValues(4),dValue,XValues(2));

                    elseif listPlots(4) == 1 && listPlots(6) == 1 % the user selects BED2 and FIT2
                        hold on;
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        BED(file_names,data,p,2,tauValues(3),dValue);

                        % axes(handles.axes_left_plot)                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot)    % Enable its interactivity
                        % fit2(file_names,data, Bounds);

                    elseif listPlots(5) == 1 && listPlots(6) == 1 % the user selects EQDX2 and FIT2
                        hold on;
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        EQDX(file_names,data,p,2,tauValues(4),dValue,XValues(2));

                        % axes(handles.axes_left_plot)                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot)    % Enable its interactivity
                        % fit2(file_names,data, Bounds);

                    end
                end

            elseif listFits(1) == 1 && listFits(2) == 1 % we'll perform both fits
                if isempty(data)                                            % If the table is empty
                    helpdlg('No data to perform the fits!','')              % we have nothing to display
                
                elseif any(cellstate(:,4)) || any(cellstate(:,5)) || ...    % Check if there are any empty cells
                    any(cellstate(:,6)) || any(cellstate(:,7))              % in columns N, D, d and T
                     
        
                    errordlg(['Input must be a number!' ...                 % Propts what the input must be
                      'Use point decimal separator (e.g. 3.14 instead of 3,14).' ...
                      'Cientific notation is valid (e.g. 314 = 3.14e2). ' ...
                      'Number of patients in the study, total prescription dose, ' ...
                      'dose per fraction and total treatment time should be positive, non-zero values.'], 'Invalid Input') 
                
                else
                % If both tables contain data
                    
                    cla(handles.axes_left_plot, 'reset');                    % clear both axes
                    cla(handles.axes_right_plot, 'reset');
                    axes(handles.axes_left_plot);                          % Select axes_left_plot
                    enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity

                    % FIT 1 %
                    %%%%%% data files %%%%%%
                    data1 = get(handles.uitable,'Userdata');              % Gets "Userdata" from Data Details table
                    DataFiles1 = strings(0);
                    DataSetsList1 = get(handles.uitable,'RowName');
                    Selected1 = data1(:,1);                                                           % Selection state of the data
                    for i = 1:numel(Selected1)                       
                        if isequal(Selected1(i),{1})                                                 % If it's selected
                            DataFiles1 = [DataFiles1  strcat("./Data/",string(DataSetsList1(i,:)),".m")];   % Complete the file names with the extension
                            file_names1 = cellstr(DataFiles1);
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%
                  
                    Bounds1 = get(handles.uitable_OptFit1, 'Userdata');                      % Check initial guess, upper and lower bounds to perform the fit
                    [p1,up1,gf1] = fit1(file_names1, data, Bounds1);                     % Performs Fit1 (p1->vector with parameters; up1->vector with uncertainties)
                    Fit1Data = {round(p1(1),5)...                                           % Stores fited parameters
                       ,round(p1(2),5)...
                       ,round(p1(3),5)...
                       ,round(p1(4),5)...
                       ,round(p1(5),5)...
                       ,round(p1(6),0)...
                       ,round(p1(7),5)...
                       ,round(p1(8),5)...
                       ,round(gf1,2)};
                    Uncertainty1Data = {round(up1(1),5)...                                   % Stores uncertainties of the parameters                     
                       ,round(up1(2),5)...
                       ,round(up1(3),5)...
                       ,round(up1(4),5)...
                       ,round(up1(5),5)...
                       ,round(up1(6),0)...
                       ,round(up1(7),5)...
                       ,round(up1(8),5)...
                       ,'----'};

                    Results1 = [Fit1Data; Uncertainty1Data; Uncertainty1Data]; 
                    % disp('fit1-results:');
                    % disp(Results1);
                    set(handles.uitable_ResultFit1,...                                      % Keep fited parameters information
                        'Data', Results1,...                                                 % and displays it on the table
                        'Userdata', Results1)

                    axes(handles.axes_right_plot);                          % Select axes_right_plot
                    enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity

                    % FIT 2 %
                    %%%%%% data files %%%%%%
                    data2 = get(handles.uitable,'Userdata');              % Gets "Userdata" from Data Details table
                    DataFiles2 = strings(0);
                    DataSetsList2 = get(handles.uitable,'RowName');
                    Selected2 = data2(:,1);                                                           % Selection state of the data
                    for i = 1:numel(Selected2)                       
                        if isequal(Selected2(i),{1})                                                 % If it's selected
                            DataFiles2 = [DataFiles2  strcat("./Data/",string(DataSetsList2(i,:)),".m")];   % Complete the file names with the extension
                            file_names2 = cellstr(DataFiles2);
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%
                  
                    Bounds2 = get(handles.uitable_OptFit2, 'Userdata');                      % Check initial guess, upper and lower bounds to perform the fit
                    [p2,up2,gf2] = fit2(file_names2, data2, Bounds2);                             % Performs Fit1 (p->vector with parameters; up->vector with uncertainties)
                    Fit2Data = {round(p2(1),5)...                                             % Stores fited parameters
                       ,round(p2(2),5)...
                       ,round(p2(3),5)...
                       ,round(p2(4),5)...
                       ,round(p2(5),5)...
                       ,round(p2(6),0)...
                       ,round(p2(7),5)...
                       ,round(p2(8),5)...
                       ,round(gf2,2)};
                    Uncertainty2Data = {round(up2(1),5)...                                    % Stores uncertainties of the parameters                     
                       ,round(up2(2),5)...
                       ,round(up2(3),5)...
                       ,round(up2(4),5)...
                       ,round(up2(5),5)...
                       ,round(up2(6),0)...
                       ,round(up2(7),5)...
                       ,round(up2(8),5)...
                       ,'----'};

                    Results2 = [Fit2Data; Uncertainty2Data; Uncertainty2Data];
                    % disp('fit2-results:');
                    % disp(Results2);
                    set(handles.uitable_ResultFit2,...                                      % Keep fited parameters information
                        'Data', Results2,...                                                 % and displays it on the table
                        'Userdata', Results2) 
                                                                

                    % the user selects two plots (only option bc he's selecting both fits)
                    % listPlots = [BED1, EQDX1, FIT1, BED2, EQDX2, FIT2]
                    % tauValues = [BED1, EQDX1, BED2, EQDX2]

                    if listPlots(1) == 1 && listPlots(4) == 1 % the user selects BED1 and BED2
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');

                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        BED(file_names1,data1,p1,1,tauValues(1),dValue);

                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        BED(file_names2,data2,p2,2,tauValues(3),dValue);

                    elseif listPlots(1) == 1 && listPlots(5) == 1 % the user selects BED1 and EQDX2
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');

                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity                        
                        BED(file_names1,data1,p1,1,tauValues(1),dValue);

                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        EQDX(file_names2,data2,p2,2,tauValues(4),dValue,XValues(2));

                    elseif listPlots(1) == 1 && listPlots(6) == 1 % the user selects BED1 and FIT2
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity                        
                        BED(file_names1,data1,p1,1,tauValues(1),dValue);
                         
                        % axes(handles.axes_left_plot)                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot)    % Enable its interactivity
                        % fit2(file_names2, data2, Bounds2);
                
                    elseif listPlots(2) == 1 && listPlots(4) == 1 % the user selects EQDX1 and BED2
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');
                        
                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        EQDX(file_names1,data1,p1,1,tauValues(2),dValue,XValues(1));

                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        BED(file_names2,data2,p2,2,tauValues(3),dValue);

                    elseif listPlots(2) == 1 && listPlots(5) == 1 % the user selects EQDX1 and EQDX2
                        cla(handles.axes_left_plot, 'reset');                    % clear both axes
                        cla(handles.axes_right_plot, 'reset');

                        axes(handles.axes_left_plot);                          % Select axes_left_plot
                        enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        EQDX(file_names1,data1,p1,1,tauValues(2),dValue,XValues(1));

                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        EQDX(file_names2,data2,p2,2,tauValues(4),dValue,XValues(2));

                    elseif listPlots(2) == 1 && listPlots(6) == 1 % the user selects EQDX1 and FIT2
                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        EQDX(file_names1,data1,p1,1,tauValues(2),dValue,XValues(1));

                        % axes(handles.axes_left_plot)                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot)    % Enable its interactivity
                        % fit2(file_names2, data2, Bounds2);

                    elseif listPlots(3) == 1 && listPlots(4) == 1 % the user selects FIT1 and BED2
                        % axes(handles.axes_left_plot)                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot)    % Enable its interactivity
                        % fit1(file_names1, data1, Bounds1);

                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        BED(file_names2,data2,p2,2,tauValues(3),dValue);

                    elseif listPlots(3) == 1 && listPlots(5) == 1 % the user selects FIT1 and EQDX2
                        % axes(handles.axes_left_plot)                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot)    % Enable its interactivity
                        % fit1(file_names1, data1, Bounds1);

                        cla(handles.axes_right_plot, 'reset');
                        axes(handles.axes_right_plot);                          % Select axes_right_plot
                        enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        EQDX(file_names2,data2,p2,2,tauValues(4),dValue,XValues(2));

                    elseif listPlots(3) == 1 && listPlots(6) == 1 % the user selects FIT1 and FIT2
                        return;
                        % cla(handles.axes_left_plot, 'reset');
                        % axes(handles.axes_left_plot);                          % Select axes_left_plot
                        % enableDefaultInteractivity(handles.axes_left_plot);    % Enable its interactivity
                        % fit1(file_names1, data1, Bounds1); 
                        % 
                        % cla(handles.axes_right_plot, 'reset');
                        % axes(handles.axes_right_plot);                          % Select axes_right_plot
                        % enableDefaultInteractivity(handles.axes_right_plot);    % Enable its interactivity
                        % fit2(file_names2, data2, Bounds2);

                    end
                end
            end
        end
    end
                    
     
%----------                                                     ----------%
%--------------------------------------------------------------------------
% "Results" PANEL 
%--------------------------------------------------------------------------
handles.panel_Results = uipanel('Parent', mainFig, ...
    'Tag',              'panel_Results', ...
    'Title',            'Results', ...
    'Units',            'normalized', ...
    'Position',         [.01 .01 .38 .30],...
    'HighlightColor',   '#D95319',...
    'ForegroundColor',  'k',...
    'FontSize',         12);

%--------------------------------------------------------------------------
% "Results" PANEL - Fit1
%--------------------------------------------------------------------------
% handles.panel_ResultsFit1 = uipanel('Parent', mainFig, ...
%     'Tag',              'panel_ResultsFit1', ...
%     'Title',            'Results', ...
%     'Units',            'normalized', ...
%     'Position',         [.01 .01 .38 .30],...
%     'HighlightColor',   '#D95319',...
%     'ForegroundColor',  'k',...
%     'FontSize',         12);

%----------------------------
% "Results" UITABLES - Fit1
%----------------------------
handles.uitable_ResultFit1 = uitable(handles.panel_Results,...
    'Tag',              'uitable_ResultFit1',...
    'ColumnFormat',     {'' '' '' '' '' '' '' '' ''},...
    'Data',             FitData,...
    'Units',            'normalized', ...
    'Position',         [0.01 .1 .99 .9],...
    'Visible',          'on',...
    'ColumnEditable',   false,...
    'ColumnWidth',      {65 65 65 65 65 65 65 65 65},...
    'ColumnName',       {'K' ...
                         '<html><center />&alpha <br /> [Gy<sup>-1</sup>]</html>' ...
                         '<html><center />&beta <br /> [Gy<sup>-2</sup>]</html>' ...
                         '<html>&alpha<span>&#47;</span>&beta<br />[Gy]</html>' ...
                         '<html><center>&gamma <br /> [day<sup>-1</sup>]</center></html>' ...
                         '<html><center>T<sub>d</sub><br />[day]</html>' ...
                         '<html><center />a <br /> [mo<sup>-1</sup>]</html>' ...
                         '<html>&delta</html>'...
                         '<html>&chi<sup>2</sup><span>&#47;</span>dof<br /></html>'},...
    'RowName',           {'Results' 'Lower uncty.' 'Upper uncty.'},...
    'Userdata',          FitData,...
    'Tooltip',           {'Results of the fited parameters with lower and upper bound uncertainties.'},...
    'CellEditCallback',  @fiteduitable_Callback);

%--------------------------------------------------------------------------
% "Results" PANEL - Fit2
%--------------------------------------------------------------------------
% handles.panel_ResultsFit2 = uipanel('Parent', mainFig, ...
%     'Tag',              'panel_ResultsFit2', ...
%     'Title',            'Results', ...
%     'Units',            'normalized', ...
%     'Position',         [.01 .01 .38 .30],...
%     'HighlightColor',   '#D95319',...
%     'ForegroundColor',  'k',...
%     'FontSize',         12);

%----------------------------
% "Results" UITABLES - Fit2
%----------------------------
handles.uitable_ResultFit2 = uitable(handles.panel_Results,...
    'Tag',              'uitable_ResultFit2',...
    'ColumnFormat',     {'char' 'char' 'char' 'char' 'char' 'char' 'char' 'char' 'char'},...
    'Data',             FitData,...
    'Units',            'Normalized', ...
    'Position',         [0.01 .1 .99 .9],...
    'Visible',          'off',...
    'ColumnEditable',   false,...
    'ColumnWidth',      {65 65 65 65 65 65 65 65 65},...
    'ColumnName',       {'<html>K<sub>50</sub><span>&#47;</span>K<sub>0</sub></html>' ...
                         '<html><center />&alpha<br /> [Gy<sup>-1</sup>]</html>' ...
                         '<html><center />&beta<br />[Gy<sup>-2</sup>]</html>' ...
                         '<html>&alpha<span>&#47;</span>&beta<br />[Gy]</html>' ...
                         '<html><center>&gamma <br /> [day<sup>-1</sup>]</center></html>' ...
                         '<html><center>T<sub>d</sub><br />[day]</html>' ...
                         '<html><center /> &sigma<sub>k</sub> <span>&#47;</span>K<sub>0</sub></html>' ...
                         '<html>&delta</html>'...
                         '<html>&chi<sup>2</sup><span>&#47;</span>dof<br /></html>'},...
    'RowName',           {'Results' 'Lower uncty.' 'Upper uncty.'},...
    'Userdata',          FitData,...
    'Tooltip',           {'Results of the fited parameters with lower and upper bound uncertainties.'});

    
%--------------------------
% "Delete Table Row" Button
%--------------------------
    function delete_count_row(eventData)
    % function used by the delete table row button to delete individual rows, 
    % and also to count the number of rows selected by the user

        if isempty(eventData.Indices)
            return;
        end

        % Get the uitable handle from the eventData
        uitableHandle = eventData.Source;

        % Get the current data from the uitable
        data = uitableHandle.Data;

        % Count the number of selected files ( = number of selected rows)
        % global numnumFiles;
        numFiles = sum([data{:,1}])+ 1; % The check column is the first column
        
         % Store the number of files in the handles structure
        handles.numFiles = numFiles;

        % Display the count 
        % disp(['Number of selected rows: ', num2str(numSelectedRows)]);

        numColumns = size(eventData.Source.Data, 2); % number of columns
        if eventData.Indices(2) == numColumns
            qst = 'Are you sure you want to delete the selected data?';
            button = questdlg(qst, 'WARNING DELETE', 'Yes', 'No', 'No');
            if strcmp(button, 'Yes')
                % fprintf('Clicked Row %d\n', eventData.Indices(1));
                row = eventData.Indices(1);
                % disp(row);
            
                % Get the uitable handle from the eventData
                uitableHandle = eventData.Source;

                % Get the current data from the uitable
                data = uitableHandle.Data;

                % Remove the specified row from the data
                data(row, :) = [];

                % Update the table data
                uitableHandle.Data = data; 

                % Set the flag to true to prevent further processing
                deletedRow = true;
            end
        end
    end

%-----------------------------------
% "Select All/Unselect All" Button
%----------------------------------
% Callback function for select/unselect all button
function selectAllCallback(~, ~)
    % Get current data from the table
    tableData = get(handles.uitable, 'Data');
    
    % Toggle the selection state for all checkboxes
    for i = 1:size(tableData, 1)
        tableData{i, 1} = ~tableData{i, 1}; % Toggle the checkbox value
    end
    
    % Count the number of selected files
    numberfiles = sum(cell2mat(tableData(:, 1)));
    handles.numFiles = numberfiles;
    
    % Update table data
    set(handles.uitable, 'Data', tableData);
    
    % Manually trigger a cell selection event
    eventdata.Indices = [1, 1]; % Dummy indices
    eventdata.NewData = tableData;
    datauitable_Callback(handles.uitable, eventdata);
end


%-----------------------------------
% Plot Data
%----------------------------------
% Function to plot the data files when these are selected
function PltData(~,~)
    
    data = get(handles.uitable,'Userdata');
    tmp = get(handles.uitable, 'Rowname');  % Get data stored in the Data Details table as "Userdata" 
    select = data(:,1);                     % Selection state of the data


    % cla(handles.axes_Time, 'reset')         % Reset plot
    % axes(handles.axes_Time);                % Select "Time" axes

    cla(handles.axes_left_plot, 'reset');
    axes(handles.axes_left_plot);

    if numel(tmp) == 0                      % If there are no data
        warndlg('No data to show!', 'Plot Warning')
    else
        for k = 1:numel(tmp)
            if cell2mat(select(k)) == 1 
                InputData = load(strcat('./Data/',string(tmp(k)),'.m')); 
                Time = InputData(:, 1);
                SR = InputData(:, 2);
    
                if numel(InputData(1,:))==2
                    errhigh = zeros(numel(Time),1);
                    errlow = zeros(numel(Time),1);
                elseif numel(InputData(1,:))==4
                    errhigh = InputData(:,3);
                    errlow = InputData(:,4);
                end
                hold on

                selectedColor = data(:, 7);
                colors = {'red' 'electric green' 'blue' 'cyan' 'magenta' 'yellow' 'black'...
                    'orange' 'purple' 'pink' 'gray' 'bordeaux' 'dark green' 'dark yellow' 'brown'};
                colorsHex = {'#FF0000' '#00FF00' '#0000FF' '#00FFFF' '#FF00FF' '#FFFF00'...
                    '#000000' '#D95319' '#7E2F8E' '#FFC0CB' '#808080' '#A2142F' '#006400'...
                    '#EDB120' '#A52A2A'};
                colorMap = [colors; colorsHex];
             
                colorIndex = find(strcmp(colorMap(1, :), selectedColor{k})); 
                % Find the index of the selected color on the list
                if ~isempty(colorIndex)
                    SelectedHex = colorMap{2, colorIndex};
                end

                selectedMarker = data(:, 8);
                markers = {'circle' 'plus sign' 'asterisk' 'point' 'cross' 'horizontal line' ... 
                    'vertical line' 'square' 'diamond' 'upward-pointing triangle' ... 
                    'downward-pointing triangle' 'right-pointing triangle' ...
                    'left-pointing triangle' 'pentagram' 'hexagram'};
                markersSym = {'o' '+' '*' '.' 'x' '_' '|' 'square' 'diamond' ...
                    '^' 'v' '>' '<' 'pentagram' 'hexagram'};
               
                markerMap = [markers; markersSym];
                markerIndex = find(strcmp(markerMap(1, :), selectedMarker{k}));
                % Find the index of the selected marker on the list
                if ~isempty(markerIndex)
                    SelectedMark = markerMap{2, markerIndex};
                
                   
                    plot(Time, SR, ...
                        'LineStyle',    'none', ...
                        'Marker',       SelectedMark,...
                        'LineWidth',    2, ...
                        'Color',        SelectedHex, ...
                        'MarkerSize',   6, ...
                        'DisplayName',  string(tmp(k)))             % Uses the name of the file
                    errorbar(Time,SR,errlow,errhigh, ...
                             'Color',            SelectedHex, ...
                             'LineStyle',        'none', ...
                             'HandleVisibility', 'off');
                    legend('Location',  'northeast')
                    legend('boxoff')
                    xlabel('Time (months)')
                    ylabel('SR (%)')
                    axis([0 inf 0 100])
                    title('Clinical Data') 
                end
            end
        end    
    end
end

%-----------------------------------
% Save Plot
%----------------------------------

function SavePlot (~,~)
    choice = menu('Axes to save:','SR vs Time','SR vs BED', 'Both');
    FileName = inputdlg('Enter file name and extension (.png, .pdf, .jpg, .fig, .jpeg, .svg):');
    
    if choice == 1      % If axes time selected
        fignew = figure('Visible','off','WindowState', 'maximized');    % Invisible figure
        newAxes = copyobj(handles.axes_left_plot,fignew);                    % Copy the appropriate axes
        set(newAxes,'Position', [.1 .1 .88 .88], 'Units', 'normalized');  % The original position is copied too, so adjust it.
    elseif choice == 2  % If axes BED selected
        fignew = figure('Visible','off','WindowState', 'maximized');    
        newAxes = copyobj(handles.axes_right_plot,fignew);                     
        set(newAxes,'Position', [.1 .1 .88 .88], 'Units', 'normalized'); 
    elseif choice == 3  % If both is selected
        fignew = figure('Visible', 'off', 'WindowState','maximized');
        newAxesTime = copyobj(handles.axes_left_plot, fignew);
        newAxesBED = copyobj(handles.axes_right_plot, fignew);
        set(newAxesTime);
        set(newAxesBED);
    end
    set(fignew,'CreateFcn','set(gcbf,''Visible'',''on'')');             % Make it visible upon loading
    saveas(fignew,string(FileName));
    delete(fignew);
end

%------------------------------------------------
% "CLEAR AXES" FUNCTION
%------------------------------------------------
function ClearAxes(~,~)

    cla(handles.axes_left_plot, 'reset')                 % Clear the axes of the left plot
    axes(handles.axes_left_plot);                        % Selects it again
    xlabel('x1')                                         % Set labels (the x axis depends on the user plot choices)
    ylabel('SR (%)')
    axis([0 inf 0 100])                             % Axis limits [x_min x_max y_min y_max] inf means it fits to the content
    title(' ')                                      % No title when cleared
    hold on;
    enableDefaultInteractivity(handles.axes_left_plot)   % Enables intereactivity+

    cla(handles.axes_right_plot, 'reset')                % Clear the axes of the right plot
    axes(handles.axes_right_plot);                       % Selects it again
    xlabel('x2')                                         % Set labels (the x axis depends on the user plot choices)
    ylabel('SR (%)')
    axis([0 inf 0 100])
    title(' ') 
    hold on;
    enableDefaultInteractivity(handles.axes_right_plot) 

end

%----------                                                     ----------%


end %main