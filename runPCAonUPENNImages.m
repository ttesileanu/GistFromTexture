% runPCAonUPENNImages
%
% Run principal component analysis on the texture statistics from both the
% UPenn images, comparing natural scenes, taken in Botswana, and humanmade
% scenes, taken in Philadelphia.
%

%% Clear
close all; clear;

%% Add path to texture analysis functions in separate directory from the TextureAnalysis repo
% Note: you will need to download this repo. See https://github.com/ttesileanu/TextureAnalysis
baseDir = fullfile('/Users', 'anniesu', 'Documents', 'MATLAB');

% You may need to edit this path to fit with your matlab file configuration
pathToTextureAnalysisFiles = fullfile(baseDir, 'projects', 'Analysis', 'TextureAnalysis');
addpath(pathToTextureAnalysisFiles);

% Add path to Annie's scripts. Note: add this into the GistFromTexture
% folder eventually.
pathToAnnieScripts = fullfile(baseDir, 'purm_scripts');
addpath(pathToAnnieScripts);

%% Parameters
blockAF = 8;
patchSize = 32;

%% Process the image set directories. You can customize this.
baseDir = fullfile(filesep,'/Volumes', 'Annie');
manmadeDirectory = fullfile(baseDir, 'manmade');
naturalDirectory = fullfile(baseDir, 'natural');

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
        
        naturalPortionOfResults = plotCommands(naturalSubDirFileNames, naturalSubDir, blockAF, patchSize);
        naturalStructs = [naturalStructs; naturalPortionOfResults];
    end
end

for ii = 1:size(naturalStructs, 1)
    naturalResults = [naturalResults; naturalStructs(ii).ev];
end

% Calculate the texture statistics for manmade scene images
manmadeResults = plotCommands(fileNamesManmade, manmadeDirectory, blockAF, patchSize);
%naturalResults = plotCommands(fileNamesNatural, naturalDirectory, blockAF, patchSize);

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
legend('manmade', 'natural');

