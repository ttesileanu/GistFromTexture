% plotOlivaData
%
% Plot the texture statistics of the 8 image sets from the Oliva and 
% Torralba image database 

%% Configure folders
figure;
folders = {fileNamesCity, fileNamesCoast, fileNamesHighway, ...
    fileNamesForest, fileNamesStreet, fileNamesMountain, ...
    fileNamesTallBuilding, fileNamesOpencountry;
    'inside_city', 'coast', 'highway', 'forest', 'street', ...
    'mountain', 'tallbuilding', 'Opencountry'};

[M, N] = size(folders);

%% Loop through each scene type and plot texture statistics on same plot
for sceneType = 1:N
     subplot(4, 2, sceneType);
     plotCommands(folders{1, sceneType}, folders{2, sceneType}, 3, 8);
end
suptitle('texture analysis, block avg factor 3, patch size 8');

