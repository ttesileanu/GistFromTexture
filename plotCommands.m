function [res, filter] = plotCommands(fileNames, path, blockAvgFactor, patchSize)
% plotCommands streamlines the process of analyzing folders of images
% (see analyzePatches.m for more info on 'res') 

%% Generate whitening filter from image set to remove lower-level correlations
[M, N] = size(fileNames);
filter = generateFourierWhitenFilter(fileNames(1:N), path, ...
    blockAvgFactor, patchSize);

%% Analyze block averaged, filtered, binarized image set for texture statistics
res = analyzeImageSet(fileNames(1:N), path, blockAvgFactor, filter, 2);

% plot
%plotStatisticsBars(res.ev);
%title(path);
