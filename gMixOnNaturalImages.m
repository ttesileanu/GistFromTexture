% runGMixDistribution
%
% test for gmix.cluster -- seems to only return "1"?
%
% See also classifyManmadeOrNatural.m and generateGMixtureDistributionObj.m
%

% Parameters
threshold = 0.5;
blockAF = 1;
patchSize = 256;

% Configure directory of natural scene images
naturalDirectory = getpref('GistFromTexture', 'naturalScene');
[fileNamesNatural, subDirectoryNamesNatural] = direcNames(naturalDirectory);

% Add path to all subfolders in GistFromTexture project
pathToThisProj = pwd;
addpath(genpath(pathToThisProj));

% Keep count of # of photos that are categorized as 'manmade' and 'natural'
numManmadeIds = 0;
numNaturalIds = 0;

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
        
        % Pass in and classify each photo
        for kk = 1:size(naturalSubDirFileNames, 2)
            fileName = fullfile(naturalDirectory, subDirectoryNamesNatural{ii}, naturalSubDirFileNames{kk});
            idx = classifyManmadeOrNatural(fileName, 'natural', blockAF, patchSize, 2, threshold);
            if (strcmp(idx, 'manmade'))
                numManmadeIds = numManmadeIds + 1;
            else
                numNaturalIds = numNaturalIds + 1;
            end
        end
    end
end

% Weird: all 81 photos are classified as 'manmade.' Something is wrong with
% the gmix object, I believe.
