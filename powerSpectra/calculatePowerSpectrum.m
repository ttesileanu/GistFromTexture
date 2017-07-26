% calculatePowerSpectrum
%
% calculates and plots the contours of the average power spectra corresponding to each 
% component of the 10D texture statistics, manmade vs. natural

% parameters. make sure to load proper filter.
clear;
blockAF = 2;
patchSize = 32;
numLevels = 2;
overlapStep = 8;
load Ffilter2x32.mat;

fileNamesNatural = parseImageNameFile('newNaturalDirectory.txt');
fileNamesManmade = parseImageNameFile('newManmadeDirectory.txt');

powerSpectraNatural = cell(10, size(fileNamesNatural, 2)); 
powerSpectraManmade = cell(10, size(fileNamesManmade, 2));

%% preprocess each natural image, calculate texture statistics, power spectrum
for ii = 1:size(powerSpectraNatural, 2)
    rawImage = imread(fileNamesNatural{1, ii});
    imageDouble = im2double(rawImage);
    imageGreyscale = rgb2gray(imageDouble);
    
    % apply filter and quantization
    finalImage = preprocessImage(imageGreyscale, blockAF, Ffilter, numLevels, patchSize, ...
        'quantType', 'perpixel', 'filterType', 'full');
    res = analyzePatches(finalImage, numLevels, patchSize, [], 'overlapping', overlapStep);
    
    % find first occurrence of column 2, so we know how many rows are
    % enumerated by the patches (sometimes, it's not necessarily = to the
    % number of rows in the original image)
    for jj = 1:size(res.patchLocations, 1)
        if (res.patchLocations(jj, 2) ~= 1)
            numRows = jj - 1;
            break;
        end
    end
    numColumns = size(res.patchLocations, 1) / numRows;
    
    % reshape each texture component into a matrix with the image's
    % dimensions corresponding to the patch locations and find the power
    % spectrum for EACH texture component. store in cell array. 
    for jj = 1:10
        texture = reshape(res.ev(:, jj), numRows, numColumns);
        fourierResult = fft2(texture);
        powerSpectrum = abs(fourierResult).^2;
        powerSpectraNatural{jj, ii} = powerSpectrum;
    end
end

% for each texture stat, average the power spectra across all the natural
% images, so we're left with 10. 
avgPowerSpectraNatural = cell(10, 1);
for ii = 1:size(powerSpectraNatural, 1)
    summedPowerSpectraNatural = zeros(size(powerSpectraNatural{ii, 1}));
    for jj = 1:size(powerSpectraNatural, 2)
        summedPowerSpectraNatural = summedPowerSpectraNatural + powerSpectraNatural{ii, jj};
        theAverage = summedPowerSpectraNatural / size(powerSpectraNatural, 2);
        avgPowerSpectraNatural{ii, 1} = theAverage;
    end
end


%% Repeat process for manmade
for ii = 1:size(powerSpectraManmade, 2)
    rawImage = imread(fileNamesManmade{1, ii});
    imageDouble = im2double(rawImage);
    imageGreyscale = rgb2gray(imageDouble);
    
    % apply filter and quantization
    finalImage = preprocessImage(imageGreyscale, blockAF, Ffilter, numLevels, patchSize, ...
        'quantType', 'perpixel', 'filterType', 'full');
    res = analyzePatches(finalImage, numLevels, patchSize, [], 'overlapping', overlapStep);
    
    % find first occurrence of a patch at column 2, so we know how many rows are
    % enumerated by the patches (sometimes, it's not necessarily = to the
    % number of rows in the original image)
    for jj = 1:size(res.patchLocations, 1)
        if (res.patchLocations(jj, 2) ~= 1)
            numRows = jj - 1;
            break;
        end
    end
    numColumns = size(res.patchLocations, 1) / numRows;
    
    % reshape each texture component into a matrix with the image's
    % dimensions corresponding to the patch locations and find the power
    % spectrum for each texture component
    for jj = 1:10
        texture = reshape(res.ev(:, jj), numRows, numColumns);
        fourierResult = fft2(texture);
        powerSpectrum = abs(fourierResult).^2;
        powerSpectraManmade{jj, ii} = powerSpectrum;
    end
end

% average all the power spectra
avgPowerSpectraManmade = cell(10, 1);
for ii = 1:size(powerSpectraManmade, 1)
    summedPowerSpectraManmade = zeros(size(powerSpectraManmade{ii, 1}));
    for jj = 1:size(powerSpectraManmade, 2)
        summedPowerSpectraManmade = summedPowerSpectraManmade + powerSpectraManmade{ii, jj};
        theAverage = summedPowerSpectraManmade / size(powerSpectraManmade, 2);
        avgPowerSpectraManmade{ii, 1} = theAverage;
    end
end

%% Visualizations

% specify the name of each texture statistic, to be used in figures
textureNames = {'\gamma', '\beta_{|}', '\beta_{--}', '\beta_{\\}', '\beta_{/}', ...
     '\theta_{\lceil}', '\theta_{\rfloor}', '\theta_{\rceil}', '\theta_{\lfloor}', '\alpha'};
 
figure; 

% plot natural image contours on top row
for ii = 1:10
    subplot(2, 10, ii); contour(fftshift(avgPowerSpectraNatural{ii, 1})); axis equal;
    title(textureNames{1, ii});
end

% plot manmade image contours on bottom row
for ii = 1:10
    subplot(2, 10, ii + 10); contour(fftshift(avgPowerSpectraManmade{ii, 1})); axis equal;
    title(textureNames{1, ii});
end

suptitle('Power Spectrum Contours - ');

% visualize the power spectrum (ripped this off matlab documentation :-)
figure; imagesc(abs(fftshift(fourierResult)))
