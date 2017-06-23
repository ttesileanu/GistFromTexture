function [fileNamesForDirectory, directoryNamesForDirectory] = direcNames(path)
% direcNames
%
% extracts file names for specified folder and saves in a cell
% fileNamesForDirectory - cell listing file names inside specified directory
% directoryNamesForDirectory - cell listening directory names in inside
% specified directory

directoryInfo = dir(path);
isDirectory = [directoryInfo.isdir];

directoryNamesForDirectory = {directoryInfo(isDirectory).name};
fileNamesForDirectory = {directoryInfo(~isDirectory).name};


