% identifyNaturalOrManmade
%
% Generate a Gaussian mixture distribution and classify a patch
% as either belonging to a natural scene or a manmade scene. 
%

function idx = identifyNaturalOrManmade(patchCoords, blockAF, patchSize)

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

%% Define a training set of images to generate the Gaussian mixture. We take half the results. 
trainingSetManmade = manmadeResults.ev(1:floor(size(manmadeResults.ev, 1)/2), :);
trainingSetNatural = naturalResults(1:(floor(size(naturalResults, 1)/2)), :);

%% Calculate the means 
meanManmade = mean(trainingSetManmade, 1);
meanNatural = mean(trainingSetNatural, 1);
meanBoth = [meanManmade; meanNatural];

% Calculate the covariances and assemble into a 3D array
sigmaBoth = cov(meanManmade);
sigmaBoth(:, :, 2) = cov(meanNatural);

% The gmdistribution function returns an object that you can use to
% classify patches.
gmix = gmdistribution(meanBoth, sigmaBoth);
idx = gmix.cluster(patchCoords);  % returns 1 or 2, identifying either one or the other of the Gaussians

