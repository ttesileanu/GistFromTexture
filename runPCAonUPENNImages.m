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

%% Process the image set directories
baseDir = fullfile(filesep,'/Volumes', 'Annie');
manmadeDirectory = fullfile(baseDir, 'manmade');
naturalDirectory = fullfile(baseDir, 'UPENNNaturalImageProject', 'BotswanaImagesCheck_061617', 'out', 'cd59A');

%% List file names in cell. Note we only want the JPG's
fileNamesManmade = direcNames(manmadeDirectory);
fileNamesNatural = direcNames(naturalDirectory);

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

for ii = 1:size(fileNamesNatural, 2)
    [pathstr, name, ext] = ...
        fileparts(fullfile(naturalDirectory, fileNamesNatural{ii}));
    type = name(end - 2:end);
    if (~strcmp(ext, '.JPG') || strcmp(fileNamesNatural{ii}(1:2), '._'))
        fileNamesNatural{ii} = [];
    end
end
fileNamesManmade(cellfun(@(fileNamesManmade) isempty(fileNamesManmade), fileNamesManmade)) = [];
fileNamesNatural(cellfun(@(fileNamesNatural) isempty(fileNamesNatural), fileNamesNatural)) = [];

%% Calculate the texture statistics
manmadeResults = plotCommands(fileNamesManmade, manmadeDirectory, blockAF, patchSize);
naturalResults = plotCommands(fileNamesNatural, naturalDirectory, blockAF, patchSize);

% Compile manmade and natural scene statistics
allResults = [manmadeResults.ev; naturalResults.ev];

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
colorsForNatural = repmat([0 1 0], size(naturalResults.ev, 1), 1);
allColors = [colorsForManmade; colorsForNatural];

figure;
scatter(allResultsProj(:, 1), allResultsProj(:, 2), [], allColors, ...
    'filled', 'MarkerFaceAlpha', .4, 'MarkerEdgeAlpha', .4);
xlabel('PC #1');
ylabel('PC #2');
legend('manmade', 'natural');

