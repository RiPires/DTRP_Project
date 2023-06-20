function ImageBox

f = figure('Units','Normalized',...
     'Position',[.4 .4 .3 .3],...
     'NumberTitle','off',...
     'Name','Info');
     
e = uicontrol('Style','Edit',...
     'Units','Normalized',...
     'Position',[.1 .4 .3 .1],...
     'Tag','myedit');
p = uicontrol('Style','PushButton',...
     'Units','Normalized',...
     'Position',[.6 .4 .3 .1],...
     'String','Done',...
     'CallBack','uiresume(gcbf)');
i = axes(f,'Units','Normalized',...
     'Position',[.2 .2 .4 .4]);
axes(i)
myimage = imread('./AddFileIcon.png');
%myIcon = imresize(myimage, [64, 64]);
imshow(myimage);

uiwait(f)
out = str2num(get(e,'String'));

end