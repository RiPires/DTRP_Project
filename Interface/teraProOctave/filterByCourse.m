function filterByCourse(course)

% recover the table data stored in the Userdata of uitable_age
uitable = findobj('Tag','uitable'); 
% this variable exists only inside this function
data = get(uitable,'Userdata');

listbox_students = findobj('Tag','listbox_students');
list=get(listbox_students,'String');
n=find(strcmp(data(:,7),course));

set(uitable,'Data',data(n,:),'Rowname',list(n));
