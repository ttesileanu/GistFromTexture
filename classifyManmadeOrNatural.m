function idx = classifyManmadeOrNatural(fileName, category, blockAF, patchSize, numLevels, threshold)
% classifyManmadeOrNatural
%
% Uses a Gaussian mixture distribution object to classify an image as
% depicting either a manmade or natural scene, based on a threshold for
% percentage of patches belonging to a single category. 
%
% fileName = file name
% blockAF = block averaging factor
% patchSize = size of image patch. If patchSize = x, then the patch of the 
% original photo over which texture stats will be run will be x by x pixels
% numLevels = the number of levels to quantize the image to. We usually
% specify the number of levels as 2 levels i.e. binarize the image.
% theshold = fraction (between 0 and 1) of patches necessary for the image
% to be classified accordingly. For example, if the threshold = 0.5 and 26
% out of 50 patches are classified as 'manmade', then the fraction of
% manmade patches surpasses the threshold, and the composite image can be 
% deemed as 'manmade.'

%% Add paths to necessary directories
% Paths to functions
baseDir = fullfile('/Users', 'anniesu', 'Documents', 'MATLAB');

% You may need to edit this path to fit with your matlab file configuration
pathToTextureAnalysisFiles = fullfile(baseDir, 'projects', 'Analysis', 'TextureAnalysis');
addpath(pathToTextureAnalysisFiles);

% Paths to images
pathToManmade = getpref('GistFromTexture', 'manmadeScene');
pathToNatural = getpref('GistFromTexture', 'naturalScene');

% Add path to all subfolders in GistFromTexture project
pathToThisProj = pwd;
addpath(genpath(pathToThisProj));

%% Load variables
switch blockAF
    case 1
        if (patchSize == 256)
            load 'gmix1x256.mat';
            load 'FfilterManmade1x256.mat';
            load 'FfilterNatural1x256.mat';
        else 
            % throw an error (or maybe something more flexible)
        end
    case 2
        if (patchSize == 128)
            load 'gmix2x128.mat';
            load 'FfilterManmade2x128.mat';
            load 'FfilterNatural2x128.mat';
        else 
            % throw an error 
        end
    otherwise
        % throw an error
end

%% Preprocess image
rawImage = imread(fileName);
imageDouble = im2double(rawImage);
imageGreyscale = rgb2gray(imageDouble);

% Load appropriate filter based on manmade or natural
if (strcmp(category, 'manmade'))
    filter = FfilterManmade;
else
    filter = FfilterNatural;
end

% Apply filter and quantization. Plot images for testing purposes.
[finalImage, origImage, logImage, averagedImage, filteredImage] = preprocessImage(imageGreyscale, blockAF, filter, numLevels, [], 'filterType', 'full');
subplot(1, 4, 1) , imshow(origImage);
subplot(1, 4, 2) , imagesc(averagedImage); axis image;
subplot(1, 4, 3) , imagesc(filteredImage); axis image; colormap('gray');
subplot(1, 4, 4) , imshow(finalImage);

%% Calculate texture statistics for each patch of the image
res = analyzePatches(finalImage, numLevels, patchSize);
textureStats = res.ev;
[totalPatches, N] = size(textureStats);
numManmadePatches = 0;
numNaturalPatches = 0;

for ii = 1:totalPatches
    classification = gmix.cluster(textureStats(ii, :));
    if (classification == 1) 
        numManmadePatches = numManmadePatches + 1;
    else
        numNaturalPatches = numNaturalPatches + 1;
    end
end

%% Classify image
if (totalPatches / numManmadePatches > threshold)
    idx = 'manmade';
elseif (totalPatches / numNaturalPatches > threshold)
    idx = 'natural';
else
    error('Image does not meet threshold and cannot be classified as manmade nor natural');
end

