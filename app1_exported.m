function GUI1
    f = figure('Position',[100 100 350 300], 'Name','GUI1 - Sender');

    % Buttons
    uicontrol('Style','pushbutton','String','Load Image 1',...
              'Position',[75 230 200 40],...
              'Callback',@loadImage1);
          
    uicontrol('Style','pushbutton','String','Load Image 2',...
              'Position',[75 170 200 40],...
              'Callback',@loadImage2);

    uicontrol('Style','pushbutton','String','Submit to GUI2',...
              'Position',[75 100 200 40],...
              'Callback',@submitImages);

    % Storage for images
    setappdata(f,'img1',[]);
    setappdata(f,'img2',[]);
end


function loadImage1(hObject,~)
    f = ancestor(hObject,'figure');
    [file,path] = uigetfile({'*.jpg;*.png;*.jpeg'});
    if isequal(file,0), return; end
    img = imread(fullfile(path,file));
    setappdata(f,'img1',img);
    disp('Image 1 loaded');
end


function loadImage2(hObject,~)
    f = ancestor(hObject,'figure');
    [file,path] = uigetfile({'*.jpg;*.png;*.jpeg'});
    if isequal(file,0), return; end
    img = imread(fullfile(path,file));
    setappdata(f,'img2',img);
    disp('Image 2 loaded');
end


function submitImages(hObject,~)
    f = ancestor(hObject,'figure');
    img1 = getappdata(f,'img1');
    img2 = getappdata(f,'img2');

    if isempty(img1) || isempty(img2)
        errordlg('Please load BOTH images first');
        return;
    end

    % Open GUI2 if not already open
    if isempty(findobj('Tag','GUI2'))
        GUI2;
    end

    f2 = findobj('Tag','GUI2');

    ax1 = findobj(f2,'Tag','ImageAxes1');
    ax2 = findobj(f2,'Tag','ImageAxes2');

    imshow(img1,'Parent',ax1);
    imshow(img2,'Parent',ax2);
end
function GUI2
    f = figure('Position',[500 100 600 300],...
               'Tag','GUI2',...
               'Name','GUI2 - Receiver');

    % Two axes for two images
    axes('Units','normalized',...
         'Position',[0.05 0.1 0.4 0.8],...
         'Tag','ImageAxes1');
     
    axes('Units','normalized',...
         'Position',[0.55 0.1 0.4 0.8],...
         'Tag','ImageAxes2');
end
