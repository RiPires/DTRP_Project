function strdate= isdate(strdate)
% function strdate = isdate(strdate)
%
% INPUT
% * strdate is a string (not cell) and returns the strdate in the format
% adopted dd-mm-yyyy
%
% OUTPUT
% * strdate as dd-mm-yyyy, empty string if no valid date
%
% -------------------------------------------------------------------------
% made by bcf in 06-12-2010
% -------------------------------------------------------------------------

n=strfind(strdate,'-');
if isempty(n)|numel(n)~=2
    strdate=[];
    %set(gco,'String',''); % TODO: this should be removed from here???????????????????????????????????????????
    h=errordlg('Input must be a date with format dd-mm-yyyy','ERROR');
    set(h,'WindowStyle','modal')
    return
end

Day   = str2double(strdate(1:n(1)-1));
Month = str2double(strdate(n(1)+1:n(2)-1));
Year  = str2double(strdate(n(2)+1:end));

% do not change the order because day depends on Year and Month
if Year <1900 | Year >2100 | isempty(Year) | isnan(Year)
    strdate=[];
    h=errordlg('Year is not valid!','Error');set(h,'WindowStyle','modal')
    return
end
if Month <=0 | Month >12 | isempty(Month) | isnan(Month)
    strdate=[];set(gco,'String','')
    h=errordlg('Month is not valid!','Error');set(h,'WindowStyle','modal')
    return
end
if Day <=0 | Day > eomday(Year,Month) | isempty(Day) | isnan(Day)
    strdate=[];set(gco,'String','')
    h=errordlg('Day is not valid!','Error');set(h,'WindowStyle','modal')
    return
end

strdate = [int2str(Month) '-' int2str(Day) '-' int2str(Year)];
strdate = datestr(strdate,'dd-mm-yyyy');

end