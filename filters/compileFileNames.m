% compile file names of natural and manmade images

fileNamesManmade = parseImageNameFile('newManmadeDirectory.txt');
fileNamesNatural = parseImageNameFile('newNaturalDirectory.txt');

allFileNames = [cellfun(@(s) fullfile('manmade', s), fileNamesManmade, ...
    'uniform', false) cellfun(@(s) fullfile('natural', s), fileNamesNatural, 'uniform', false)];
