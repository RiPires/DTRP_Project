    function pushbutton_Fit_Callback(hObject,~)
        
        data = get(handles.uitable,'Userdata')
        DataFiles = strings
        tmp = get(hObject, 'String');
        val = get(hObject, 'Value');
        if isempty(data)
            disp('No data to show')
        else
        Selected = data(:,1)
            for i = 1:numel(Selected)
                if strcmp(Selected(i), '1')
                    DataFiles = DataFiles + strcat('.\',string(tmp(val)),'.m') 
                end
            end
        end
    end