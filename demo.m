

    f = figure('Position',[100 100 350 300], 'Name','Menu');

    % Buttons
    uicontrol('Style','pushbutton','String','Load First Image',...
              'Position',[75 230 200 40],...
              'Callback',@loadImage1);
          
    uicontrol('Style','pushbutton','String','Load Second Image',...
              'Position',[75 170 200 40],...
              'Callback',@loadImage2);

    uicontrol('Style','pushbutton','String','Perform Fourier Transform',...
              'Position',[75 100 200 40],...
              'Callback',@submitImages);

    % Storage for images
    setappdata(f,'img1',[]);
    setappdata(f,'img2',[]);

% Colects the first image
function loadImage1(hObject,~)
    f = ancestor(hObject,'figure');
    [file,path] = uigetfile({'*.jpg;*.jpeg'});
    if isequal(file,0), return; end
    img = imread(fullfile(path,file));
    setappdata(f,'img1',img);
end

% Collects the second image
function loadImage2(hObject,~)
    f = ancestor(hObject,'figure');
    [file,path] = uigetfile({'*.jpg;*.jpeg'});
    if isequal(file,0), return; end
    img = imread(fullfile(path,file));
    setappdata(f,'img2',img);
end

% Submits to a new GUI
function submitImages(hObject,~)
    f = ancestor(hObject,'figure');
    I1 = getappdata(f,'img1');
    I2 = getappdata(f,'img2');

    if isempty(I1) || isempty(I2)
        errordlg('Please load BOTH images first');
        return;
    end

    if isempty(findobj('Tag','GUI2'))
        %GUI2;
        fourier(I1, I2);
    end

    f2 = findobj('Tag','GUI2');

    ax1 = findobj(f2,'Tag','ImageAxes1');
    ax2 = findobj(f2,'Tag','ImageAxes2');

    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fourier(I1, I2)
s1 = size(I1);
s2 = size(I2);

if ismatrix(I1)
    I1 = im2gray(I1);
else
    I1 = rgb2gray(I1);
end
if ismatrix(I2)
    I2 = im2gray(I2);
else
    I2 = rgb2gray(I2);
end


function shapeBlendGUI(I1, I2)
% SHAPEBLENDGUI - Interactive Fourier shape blending GUI

    fig = uifigure('Name', 'Fourier Shape Blending', ...
                   'Position', [100 100 1200 600]);

    % Alpha slider
    uilabel(fig, 'Text', 'Alpha (blend %)', ...
        'Position', [555 80 120 20]);
    alphaSlider = uislider(fig, ...
        'Position', [300 50 590 3], ...
        'Limits', [0 1], ...
        'Value', 0.1, ...
        'ValueChangedFcn', @(s,~) updatePlot());

    % N resampling
    uilabel(fig, 'Text', 'N (resampling points)', ...
        'Position', [350 180 150 20]);
    NField = uieditfield(fig, 'numeric', ...
        'Position', [350 160 120 25], ...
        'Value', 200, ...
        'ValueChangedFcn', @(s,~) updatePlot());

    % Percentage of Fourier coefficients kept
    uilabel(fig, 'Text', 'Fourier Coefficients (%)', ...
        'Position', [650 180 200 20]);
    keepField = uieditfield(fig, 'numeric', ...
        'Position', [650 160 120 25], ...
        'Limits', [1 100], ...
        'Value', 100, ...
        'ValueChangedFcn', @(s,~) updatePlot());

    % Axes for images
    ax1 = uiaxes(fig, 'Position', [100 320 300 250]);
    ax1.Title.String = 'Contour 1';

    ax2 = uiaxes(fig, 'Position', [400 320 300 250]);
    ax2.Title.String = 'Contour 2';

    ax3 = uiaxes(fig, 'Position', [700 320 300 250]);
    ax3.Title.String = 'Blended Output';

    % Morph Level (Contour 1)
    uilabel(fig, 'Text', 'Morph Levels (Contour 1)', ...
        'Position', [350 280 200 20]);

    morphField1 = uieditfield(fig, 'numeric', ...
        'Position', [350 260 120 25], ...
        'Limits', [0 20], ...                % min/max levels
        'RoundFractionalValues', true, ...      % force integer
        'ValueDisplayFormat', '%.0f', ...       % display as integer
        'Value', 0, ...
        'ValueChangedFcn', @(s,~) updatePlot());

    % Morph Level (Contour 2)
    uilabel(fig, 'Text', 'Morph Levels (Contour 2)', ...
        'Position', [650 280 200 20]);
    morphField2 = uieditfield(fig, 'numeric', ...
        'Position', [650 260 120 25], ...
        'Limits', [0 20], ...
        'RoundFractionalValues', true, ...
        'ValueDisplayFormat', '%.0f', ...
        'Value', 0, ...
        'ValueChangedFcn', @(s,~) updatePlot());




    updatePlot();

    function updatePlot()
        alpha = alphaSlider.Value;
        N = round(NField.Value);
        keepPercent = keepField.Value / 100;

        morph1 = morphField1.Value;   
        morph2 = morphField2.Value;   
        
        % Recompute contours with morph strength
        contour1 = getContour(I1, morph1);
        contour2 = getContour(I2, morph2);

        z1 = preprocess(contour1, N);
        z2 = preprocess(contour2, N);

        Z1 = fft(z1);
        Z2 = fft(z2);

        % Retain only a portion of the Fourier coefficients
        K = round((N/2) * keepPercent);
        mask = false(size(Z1));
        mask(1:K) = true;
        mask(end-K+1:end) = true;

        Z1(~mask) = 0;
        Z2(~mask) = 0;

        Z_blend = (1 - alpha) * Z1 + alpha * Z2;
        z_rec = ifft(Z_blend);
        
        % Assume image size
        imgSize = [256 256];
        z = z_rec - mean(z_rec);
        z = z / max(abs(z));

        [x, y] = scaleToImage(z, imgSize);

        [x1, y1] = scaleToImage(z1, [256 256]);
        [x2, y2] = scaleToImage(z2, [256 256]);

        cla(ax1); cla(ax2); cla(ax3);

        h = imgSize(1); % image height
        plot(ax1, x1, h-y1, 'LineWidth', 2); axis(ax1, 'equal'); axis(ax1, 'off');
        plot(ax2, x2, h-y2, 'LineWidth', 2); axis(ax2, 'equal'); axis(ax2, 'off');
        plot(ax3, x, h-y, 'LineWidth', 2); axis(ax3, 'equal'); axis(ax3, 'off');
    end
end

function contour = getContour(I, level)
% getContour - Extracts the largest boundary contour from an image
%
% Syntax: contour = getContour(I)
%
% Inputs:
%   I - input image (grayscale or RGB)
%
% Outputs:
%   contour - Nx2 array of [row, col] points of the largest boundary
    
    % Canny edges
    edges = edge(I, 'Canny');
    
    % Morphological functions to ensure boundary is closed
    se = strel('disk', 2);
    for i = 1:level
        edges = imdilate(edges, se);
        edges = imclose(edges, se);
    end
    % Dilate edges
    % se = strel('disk', 2);
    % edges2 = imdilate(edges, se);
    % 
    % % Close gaps more aggressively
    % edges3 = imclose(edges2, strel('disk', 3));
    
    % Fill interior
    filled = imfill(edges, 'holes');
    boundaryMask = bwperim(filled);
    
    % Extract contour points
    B = bwboundaries(boundaryMask); % pass boundary mask if using morphological functions to enclose edges
    [~, idx] = max(cellfun(@length, B)); % largest/outer boundary
    contour = B{idx};
end



function z_resampled = preprocess(contour, N)
    % contour: [row, col] coordinate list (y, x)
    % N: number of points you want in the Fourier representation

    % Extract x, y and create z
    x = contour(:,2);   % column = x
    y = contour(:,1);   % row = y
    z = x + 1i*y;

    % Ensure counterclockwise orientation
    if ispolycw(x, y)
        z = flip(z);
    end

    % Anchor the shape
    % Move the Left-most point to the start
    [~, idx_min] = min(real(z));   % smallest x
    z = circshift(z, -idx_min + 1);

    % Arc-length parameterization
    d = abs(diff(z));             % distances between samples
    s = [0; cumsum(d)];           % cumulative arc length
    s = s / s(end);               % normalize to [0,1]

    % Resample at N equally spaced arc-length points
    s_new = linspace(0, 1, N);
    z_resampled = interp1(s, z, s_new, 'linear');

    % Translation normalization
    z_resampled = z_resampled - mean(z_resampled);

    % Scale normalization
    z_resampled = z_resampled / max(abs(z_resampled));


    % Re-anchor leftmost point 
    % This stabilizes orientation completely.

    [~, idx_min] = min(real(z_resampled));
    z_resampled = circshift(z_resampled, -idx_min + 1);
end




function [x,y] = scaleToImage(z, imgSize)

    % Get x and y coordinates
    x = real(z);
    y = imag(z);

    % Scale to fit inside the image 
    minX = min(x);  maxX = max(x);
    minY = min(y);  maxY = max(y);

    width  = maxX - minX;
    height = maxY - minY;

    % Compute scale factor to fit within image
    s = 0.9 * min(imgSize(2) / width, imgSize(1) / height); % 0.9 = margin

    x = (x - minX) * s;
    y = (y - minY) * s;

    % Now center inside the image
    X_center = (imgSize(2) - max(x)) / 2;
    Y_center = (imgSize(1) - max(y)) / 2;

    x = x + X_center;
    y = y + Y_center;

end




shapeBlendGUI(I1, I2);
end

