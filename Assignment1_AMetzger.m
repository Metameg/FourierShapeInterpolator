function Assignment1_AMetzger(img1_path, img2_path)
    % This is the driver function to run the program. In the matlab command
    % window, run:
    % 
    %  'Assignment1_AMetzger(img1_path, img2_path)'

    %  where:
    %
    %  -- img1_path: string - path to first img (reference in hist_match)
    %
    %  -- img2_path: string - path to second img (source in hist_match)
    %
    % The program will display a new window for each section in the
    % assignment instructions. You can press any key to continue and view 
    % the image of the next section. The final image generated from 
    % histogram matching is saved in the project's root as:
    %  'image_matched.jpeg'.
    %
    % The program supports jpeg images, single or 3 channeled.


    % Read and show image
    figure('Name','Original','NumberTitle','off', 'WindowStyle', 'normal');
    img1 = imread(img1_path);
    img2 = imread(img2_path);
    imshow(img1);
    disp("Showing INITIAL img");
    disp('Press ANY KEY to continue...');
    pause;  % waits until any key is pressed

    
    % Convert to hsv format (hue, saturation, value)
    figure('Name','HSV Channels','NumberTitle','off', 'WindowStyle', 'normal');
    imgHSV = rgb2hsv(img1);
    
    tiledlayout(1,3)
    
    nexttile
    % Show Hue (1st channel)
    imshow(imgHSV(:,:,1));
    title('Hue')
    
    nexttile
    % Show Saturation (2nd channel)
    imshow(imgHSV(:,:,2));
    title('Saturation')
    
    nexttile
    % Show Value (3rd channel)
    imshow(imgHSV(:,:,3));
    title('Value');
    disp("Showing HSV images");
    disp('Press ANY KEY to continue...');
    pause;  % waits until any key is pressed
    
    
    % Re-scale image to double dimensions
    figure('Name','Scaled','NumberTitle','off', 'WindowStyle', 'normal');
    img2X = imresize(img1, 2.0);
    imshow(img2X);
    disp("Showing SCALED img");
    disp('Press ANY KEY to continue...');
    pause;  % waits until any key is pressed 

    
    % Convert to grayscale
    figure('Name','Grayscale','NumberTitle','off', 'WindowStyle', 'normal');
    imgGRY = rgb2gray(img1);
    imshow(imgGRY);
    disp("Showing GRAYSCALE img");
    disp('Press ANY KEY to continue...');
    pause;  % waits until any key is pressed
    

    % plot histogram of grayscale pixels
    figure('Name','Histogram','NumberTitle','off', 'WindowStyle', 'normal');
    imhist(imgGRY);
    disp("Showing HISTOGRAM img");
    disp('Press ANY KEY to continue...');
    pause;  % waits until any key is pressed

    % Call histogram matching helper function
    matched = hist_match(img1_path, img2_path);
    figure('Name','Image Matching','NumberTitle','off', 'WindowStyle', 'normal');
    subplot(1,3,1); imshow(img1); title('Reference');
    subplot(1,3,2); imshow(img2); title('Source');
    subplot(1,3,3); imshow(matched); title('Matched');

    % Saves images 
    imwrite(img1, "reference_img.jpeg");
    imwrite(img2, "source_img.jpeg");
    imwrite(matched, "image_matched.jpeg");

    disp('Image saved to image_matched.jpeg');
    disp("FINISHED");
end

function matched = hist_match(img1_path, img2_path)
    
    img1 = imread(img1_path);   % reference image
    img2 = imread(img2_path);       % source image

    % Necessary for color image to be converted to single channel since
    % imhist will only create the hist of a single channel (r,g,or b) if a
    % colored image is passed
    img1GRY = rgb2gray(img1);

    hist1 = imhist(img1GRY);
    
    % -- START Revision --

    % normalize to probabilities
    %hist1 = hist1 / sum(hist1);   

    % Calculate cumulative distribution
    %cdfRef = cumsum(hist1);

    % -- END Revision --

    % This aims to match the cdf of the reference image (img1) to that of 
    % the source image (img2). The brightness/contrast of img2 is adjusted 
    % so that the statistical distribution of gray levels in img2 resembles
    % that of img1.
    matched = histeq(img2, hist1);

end