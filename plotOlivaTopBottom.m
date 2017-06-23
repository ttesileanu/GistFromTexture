% plotOlivaTopBottom
% 
% Plots top-half vs. bottom-half image statistics for each
% image directory/category from the Oliva and Torralba image database

%% Clear and load the image sets 
clear;
close all;
load('olivaFiles');

%% Parameters
patchSize = 32;
blockAF = 1;

%% Configure the folders
folders = {fileNamesCity, fileNamesCoast, fileNamesHighway, ...
    fileNamesForest, fileNamesStreet, fileNamesMountain, ...
    fileNamesTallBuilding, fileNamesOpencountry;
    'inside_city', 'coast', 'highway', 'forest', 'street', ...
    'mountain', 'tallbuilding', 'Opencountry'};

[M, N] = size(folders);

% Specify colors for top (blue) and bottom (red) statistic plots
col1 = {[0.1 0.1 1.0]}; % blue
col2 = {[0.8 0.2 0.2]}; % red

%% Calculate texture statistics for the 4 human-made categories: 
%  'inside_city', 'highway', 'street', 'tallbuilding'
for sceneType = 1:2:N
    subplot(2, 2, ceil(sceneType / 2));
    top = strcat('bottom_', folders{2, sceneType});
    bottom = strcat('top_', folders{2, sceneType});
    
    % calculate texture statistics
    resTop = plotCommands(folders{1, sceneType}, top, blockAF, patchSize);
    resBottom = plotCommands(folders{1, sceneType}, bottom, blockAF, patchSize);
    
    % plot texture statistics on same plot; top = blue; bottom = red;
    plotStatisticsBars(resTop.ev, 'colors', col1);
    hold on;
    plotStatisticsBars(resBottom.ev, 'colors', col2);
    title(folders{2, sceneType});
    alpha(0.5);
end

%% Calculate texture statistics for the 4 natural scene categories:
%  'coast', 'forest', 'mountain', 'Opencountry'
figure;
for sceneType = 2:2:N
    subplot(2, 2, ceil(sceneType / 2));
    top = strcat('bottom_', folders{2, sceneType});
    bottom = strcat('top_', folders{2, sceneType});
    
    % calculate texture statistics
    resTop = plotCommands(folders{1, sceneType}, top, 1, patchSize);
    resBottom = plotCommands(folders{1, sceneType}, bottom, 1, patchSize);
    
    % plot texture statistics on same plot; top = blue; bottom = red;
    plotStatisticsBars(resTop.ev, 'colors', col1);
    hold on;
    plotStatisticsBars(resBottom.ev, 'colors', col2);
    title(folders{2, sceneType});
end
