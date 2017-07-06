% generateGMixtureDistributionObj
%
% Generate a Gaussian mixture distribution object that will classify a 
% patch as either belonging to a natural scene or a manmade scene by
% returning 1 or 2. 
%
% To use this object, simply feed the object the coordinates of a patch 
% (10-D texture statistics i.e. 1 by 10 row vector) using the command
% gmix.cluster(patch_coords)
%
% 1 = manmade;
% 2 = natural;
%

function gmix = generateGMixtureDistributionObj(blockAF, patchSize)

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

% Add path to all subfolders in GistFromTexture project
pathToThisProj = pwd;
addpath(genpath(pathToThisProj));

%% Define a training set of images to generate the Gaussian mixture (use the first half of photos (~40))
% To see how training set is defined, refer to runPCAonUPENNImages.mat. We
% take the first 3157 rows from both the manmade and natural stats 
% (these rows correspond with the texture stats of the first 41
% images; each image has 77 patches)
switch blockAF
    case 1
        if (patchSize == 256)
            load 'trainingSetForManmade1x256.mat';
            load 'trainingSetForNatural1x256.mat';
        else 
            % generate training set...
        end
    case 2
        if (patchSize == 128)
            load 'trainingSetForManmade2x128.mat';
            load 'trainingSetForNatural2x128.mat';
        else 
            % generate training set...
        end
    otherwise
        % generate training set...
end


%% Calculate the means 
meanManmade = mean(trainingSetForManmade, 1);
meanNatural = mean(trainingSetForNatural, 1);
meanBoth = [meanManmade; meanNatural];

% Calculate the covariances and assemble into a 3D array
sigmaBoth = cov(trainingSetForManmade);
sigmaBoth(:, :, 2) = cov(trainingSetForNatural);

% The gmdistribution function returns an object that you can use to
% classify patches.
gmix = gmdistribution(meanBoth, sigmaBoth);


