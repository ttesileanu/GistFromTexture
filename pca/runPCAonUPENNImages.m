% runPCAonUPENNImages
%
% Run principal component analysis on the texture statistics from both the
% UPenn images, comparing natural scenes, taken in Botswana, and humanmade
% scenes, taken in Philadelphia.
%
% Typical parameters:
% blockAF = 1; patchSize = 256
% blockAF = 2; patchSize = 128
% blockAF = 4; patchSize = 64
% blockAF = 8; patchSize = 32
%

%% Clear
close all; clear;

%% Parameters
blockAF = 1;
patchSize = 64;

%% Add path to texture analysis functions in the TextureAnalysis directory
% Note: you will need to download the scripts. See https://github.com/ttesileanu/TextureAnalysis
% You may need to edit the baseDir to fit with your matlab file configuration
baseDir = fullfile('/Users', 'anniesu', 'Documents', 'MATLAB');
pathToTextureAnalysisFiles = fullfile(baseDir, 'projects', 'Analysis', 'TextureAnalysis');
addpath(fullfile(pathToTextureAnalysisFiles, 'preprocess'));
addpath(genpath(pathToTextureAnalysisFiles));

% Add path to all subfolders in GistFromTexture project
pathToThisProj = pwd;
addpath(genpath(pathToThisProj));

%% Fetch the image set directories. You can customize this.
baseDir = fullfile(filesep,'/Volumes', 'Annie');
manmadeDirectory = getpref('GistFromTexture', 'manmadeScene');
naturalDirectory = getpref('GistFromTexture', 'naturalScene');

%% List file names in cell. Note we only want the JPG's
fileNamesManmade = direcNames(manmadeDirectory);

% Natural directory is split into sub-directories, which we enumerate
[fileNamesNatural, subDirectoryNamesNatural] = direcNames(naturalDirectory);

% Parse for JPG files only. Delete cells that aren't JPG file names.
for ii = 1:size(fileNamesManmade, 2)
    [pathstr, name, ext] = ...
        fileparts(fullfile(manmadeDirectory, fileNamesManmade{ii}));
    type = name(end - 2:end);
    if (~strcmp(ext, '.JPG') || strcmp(fileNamesManmade{ii}(1:2), '._'))
        fileNamesManmade{ii} = [];
    end
end
fileNamesManmade(cellfun(@(fileNamesManmade) isempty(fileNamesManmade), fileNamesManmade)) = [];

%% Calculate texture statistics
naturalStructs = [];
naturalResults = [];
% Calculate natural scene texture statistics by iterating through each subdirectory
for ii = 1:size(subDirectoryNamesNatural, 2)
    if (subDirectoryNamesNatural{ii}(1) ~= '.')
        naturalSubDir = fullfile(naturalDirectory, subDirectoryNamesNatural{ii});
        naturalSubDirFileNames = direcNames(naturalSubDir);
        
        % Parse for correctly formatted files
        for jj = 1:size(naturalSubDirFileNames, 2)
            [pathstr, name, ext] = ...
                fileparts(fullfile(naturalDirectory, naturalSubDirFileNames{jj}));
            type = name(end - 2:end);
            if (~strcmp(ext, '.JPG') || strcmp(naturalSubDirFileNames{jj}(1:2), '._'))
                naturalSubDirFileNames{jj} = [];
            end
        end
        naturalSubDirFileNames(cellfun(@(naturalSubDirFileNames) isempty(naturalSubDirFileNames), naturalSubDirFileNames)) = [];
        
        [naturalPortionOfResults, filterForNaturalScenes] = plotCommands(naturalSubDirFileNames, naturalSubDir, blockAF, patchSize);
        naturalStructs = [naturalStructs; naturalPortionOfResults];
    end
end

for ii = 1:size(naturalStructs, 1)
    naturalResults = [naturalResults; naturalStructs(ii).ev];
end

% Calculate the texture statistics for manmade scene images
[manmadeResults, filterForManmadeScenes] = plotCommands(fileNamesManmade, manmadeDirectory, blockAF, patchSize);

% Compile manmade and natural scene statistics
allResults = [manmadeResults.ev; naturalResults];

%% Run PCA on the texture statistics
% blue: manmade scenes, green: natural scenes

% Mean-center the results, find singular value decomposition.
mu = mean(allResults, 1);
allResultsCentered = bsxfun(@minus, allResults, mu);
[svdU, svdS, svdV] = svd(allResultsCentered, 0);

% Project the data onto the principal components
allResultsProj = allResultsCentered * svdV;

%% Plot the first two PC's, with the blue color for manmade scenes and green for natural
colorsForManmade = repmat([0 1 1], size(manmadeResults.ev, 1), 1);
colorsForNatural = repmat([0 1 0], size(naturalResults, 1), 1);
allColors = [colorsForManmade; colorsForNatural];

figure;
scatter(allResultsProj(:, 1), allResultsProj(:, 2), [], allColors, ...
    'filled', 'MarkerFaceAlpha', .4, 'MarkerEdgeAlpha', .4);
xlabel('PC #1');
ylabel('PC #2');
legend({'manmade is blue', 'natural is green'}); % legend doesn't label properly
titleLabel = strcat('block AF=', int2str(blockAF), ', patch size=', int2str(patchSize));
title(titleLabel);

