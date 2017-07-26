% analyzeDenim 
%
% Analyzes the given image using various block averaging
% factors, blockAF from 1 - 24. For the boxplot figures, note that texture 
% statistics are calculated over patches of size N such that 
% blockAF * N = 128. N is rounded up to the nearest integer. 
%
% Note: image isn't necessarily the denim texture. You can change the file
% name and analyze any texture file. I didn't want to name this
% 'analyzeTexture' and create confusion.

%% Clear and load the image sets
close all;
load('olivaFiles');

%% Parameters
file = 'brick.jpg';
rawImage = imread(file);
imageDouble = im2double(rawImage);
imageGreyscale = rgb2gray(imageDouble);
prod = 128; % the product of the block averaging factor and patch size
numLevels = Inf; % number of levels to quantize the images to

%% Generate whitening filter from arbitrary Oliva & Torralba dataset: 'highway'
[M, N] = size(fileNamesHighway);
filter = generateFourierWhitenFilter(fileNamesHighway(1:N), 'highway', ...
    1, 32);

%% Display texture stats alongside a patch of the image at various blockAF's
figure;
blocks = [1; 4; 7; 10; 13; 16];
xAxis = 1:10;
for range = 1:size(blocks)
    blockAvg = blocks(range);
    finalImage = preprocessImage(imageGreyscale, blockAvg, filter, numLevels, [], 'filterType', 'full');
    res = analyzePatches(finalImage, numLevels, []);
    subplot(6, 3, range * 3 - 2), imshow(finalImage(1:23, 1:23)); axis image;
    subplot(6, 3, (range * 3 - 1):(range*3)), scatter(xAxis, res.ev);
    ylim([-.4 .4]);
    xticks(1:10);
    xticklabels({'\gamma', '\beta_{|}', '\beta_{--}', '\beta_{\\}', '\beta_{/}', ...
     '\theta_{\lceil}', '\theta_{\rfloor}', '\theta_{\rceil}', '\theta_{\lfloor}', '\alpha'});
    title(['block AF ' num2str(blockAvg)]);
    
end
    
%% Analyze image with blockAF's of 1-24 and patch sizes such that patchSize * blockAF = prod
figure;
for blockAF = 2:2:22
    % preprocess the image and get stats
    [finalImage, origImage, logImage, averagedImage, filteredImage] = ...
        preprocessImage(imageGreyscale, blockAF, filter, numLevels, 'filterType', 'full');
    patchSize = ceil(prod / blockAF);
    res = analyzePatches(finalImage, numLevels, patchSize);
        
    % plot every even blockAF
    subplot(4, 3, blockAF/2);
    plotStatisticsBars(res.ev);
    ylim([-.3 .3]);
    title(['block AF ' num2str(blockAF) ' with Inf levels']);
end

% closely examine range where stats look meaningful
figure;
for blockAF = 2:13
    % preprocess the image and get stats
    [finalImage, origImage, logImage, averagedImage, filteredImage] = ...
        preprocessImage(imageGreyscale, blockAF, filter, numLevels, 'filterType', 'full');
    patchSize = ceil(prod / blockAF);
    res = analyzePatches(finalImage, numLevels, patchSize);
    
    % plot every blockAF
    subplot(4, 3, blockAF - 1);
    plotStatisticsBars(res.ev);
    ylim([-0.3 0.3]);
    title(['block AF ' num2str(blockAF) ' with Inf levels']);
end

%% Plot the mean value of the 10 texture stats as a function of blockAF with patchSize * blockAF = prod

allResultsPatched = zeros(24, 10);
for blockAF = 1:23
    % preprocess the image and get stats
    [finalImage, origImage, logImage, averagedImage, filteredImage] = ...
        preprocessImage(imageGreyscale, blockAF, filter, numLevels, 'filterType', 'full');
    patchSize = ceil(prod / blockAF);
    res = analyzePatches(finalImage, numLevels, patchSize);
    
    % store the average of the 10 texture stats in 'allResultsPatched'
    for texture = 1:10
        allResultsPatched(blockAF, texture) = mean(res.ev(:, texture));
    end
end

% plot
figure;
for cols = 1:9
    xAxis = 1:24;
    plot(xAxis, allResultsPatched(:, cols));
    hold on;
end
legend('\gamma', '\beta_{|}', '\beta_{--}', '\beta_{\\}', '\beta_{/}', ...
    '\theta_{\lceil}', '\theta_{\rfloor}', '\theta_{\rceil}', '\theta_{\lfloor}');
title('texture stats with varying patch sizes with Inf levels');

%% Plot the mean value of the 10 texture stats as a function of blockAF over entire image (patch size = entire image)
allResultsFixed = zeros(24, 10);
for blockAF = 1:24
    % preprocess the image and get stats
    [finalImage, origImage, logImage, averagedImage, filteredImage] = ...
        preprocessImage(imageGreyscale, blockAF, filter, numLevels, 'filterType', 'full');
    res = analyzePatches(finalImage, numLevels, []);
    
    % store the average of the 10 texture stats in 'allResultsPatched'
    for texture = 1:10
        allResultsFixed(blockAF, texture) = mean(res.ev(:, texture));
    end
end

% plot
figure;
for cols = 1:9
    x = 1:24;
    plot(x, allResultsFixed(:, cols));
    hold on;
end
legend('\gamma', '\beta_{|}', '\beta_{--}', '\beta_{\\}', '\beta_{/}', ...
    '\theta_{\lceil}', '\theta_{\rfloor}', '\theta_{\rceil}', '\theta_{\lfloor}');
title('texture stats over entire image (no patches) with Inf levels');


