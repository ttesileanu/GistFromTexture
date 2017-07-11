% runGMixDistribution
%
% test for gmix.cluster -- seems to only return "1"?
%
% See also classifyManmadeOrNatural.m and generateGMixtureDistributionObj.m
%

% Clear
close all; clear;

% Parameters
threshold = 0.5;
blockAF = 1;
patchSize = 256;

% Configure directory of natural scene images
naturalDirectory = getpref('GistFromTexture', 'manmadeScene');
%[fileNamesNatural, subDirectoryNamesNatural] = direcNames(naturalDirectory);

% Load filter and gmix
load 'Ffilter1x256.mat';
load 'gmix1x256.mat';

% Keep count of # of photos that are categorized as 'manmade' and 'natural'
numManmadeIds = 0;
numNaturalIds = 0;

fileNames = parseImageNameFile('newManmadeDirectory.txt');

for ii = 1:size(fileNames, 2)
    % Pass in and classify each photo
    fileName = fileNames{ii};
    idx = classifyManmadeOrNatural(fileName, gmix, Ffilter, blockAF, patchSize, 2, threshold);
    if (strcmp(idx, 'manmade'))
        numManmadeIds = numManmadeIds + 1;
    else
        numNaturalIds = numNaturalIds + 1;
    end
end


% Weird: all 81 photos are classified as 'manmade.' Something is wrong with
% the gmix object, I believe.
