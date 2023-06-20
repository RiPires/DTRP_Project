function Equations

    d = dialog('Position',[300 300 600 350], ...
               'Name','Models');

    fit1 = uicontrol('Parent',d,...
                     'Style','text',...
                     'Position',[200 300 50 20],...
                     'String','Model 1:');

    % myimage = imread('./AddFileIcon.png');
    % myIcon = imresize(myimage, [64, 64]);
    % userPrompt = sprintf('It is equal to 0!\nClick OK to exit.\nHere is my custom icon');
    % msgbox(userPrompt, 'LOOK!!!', 'custom', myIcon); % Note: custom is arg 3 now!
    % 

    i = axes(d,'Units','Normalized',...
     'Position',[.2 .2 .2 .2]);
    axes(i)
    myimage = imread('./AddFileIcon.png');
    %myIcon = imresize(myimage, [64, 64]);
    imshow(myimage);



    fit2 = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 40 210 40],...
               'String','Model 2:');


    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');

end