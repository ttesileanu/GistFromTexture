function idx = classifyManmadeOrNatural(fileName, gmix, Ffilter, blockAF, patchSize, numLevels, threshold)
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

%% Preprocess image
rawImage = imread(fileName);
imageDouble = im2double(rawImage);
imageGreyscale = rgb2gray(imageDouble);

% Apply filter and quantization. Plot images for testing purposes.
finalImage = preprocessImage(imageGreyscale, blockAF, Ffilter, numLevels, []);%, 'filterType', 'full');
% subplot(1, 4, 1) , imshow(origImage);
% subplot(1, 4, 2) , imagesc(averagedImage); axis image;
% subplot(1, 4, 3) , imagesc(filteredImage); axis image; colormap('gray');
% subplot(1, 4, 4) , imshow(finalImage);

%% Calculate texture statistics for each patch of the image
res = analyzePatches(finalImage, numLevels, patchSize);
textureStats = res.ev;
[totalPatches, N] = size(textureStats);

%% Determine classifications of each patch 
classes = gmix.cluster(textureStats);
numManmadePatches = sum(classes == 1);
numNaturalPatches = sum(classes == 2);
disp('number of manmade patches = ');
disp(int2str(numManmadePatches));
disp('number of natural patches = ');
disp(int2str(numNaturalPatches));

%% Classify image
if (numManmadePatches / totalPatches > threshold)
    idx = 'manmade';
else 
    idx = 'natural';
end

