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