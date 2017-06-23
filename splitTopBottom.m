% splitTopBottom
% 
% Split up each picture from Oliva and Torralba image database into its top
% half and bottom half. Store inside new folders like so: top_category and
% bottom_category

%% Configure folders
foldersOfCategories = {fileNamesCity, fileNamesCoast, fileNamesHighway, ...
    fileNamesForest, fileNamesStreet, fileNamesMountain, ...
    fileNamesTallBuilding, fileNamesOpencountry;
    'inside_city', 'coast', 'highway', 'forest', 'street', ...
    'mountain', 'tallbuilding', 'Opencountry'};

[M, N] = size(foldersOfCategories);

%% Loop through each category
for sceneType = 1:N
    currentFileNames = foldersOfCategories{1, sceneType};
    currentPath = foldersOfCategories{2, sceneType};
    [row, numImages] = size(currentFileNames);
    
    % create new directories for top halves and bottom halves
    topDir = strcat('top_', currentPath);
    topDir = char(topDir);
    mkdir(topDir);
    bottomDir = char(strcat('bottom_', currentPath));
    mkdir(bottomDir);
    
    % extract top and bottom halves of each image
    for im = 1:numImages
        currentImage = fullfile(char(currentPath), currentFileNames{1, im});
        fullImage = imread(char(currentImage));
        [rows, columns, colors] = size(fullImage);
        
        topRect = [1 1 columns rows/2];
        top = imcrop(fullImage, topRect);
        bottomRect = [1 rows/2 + 1 columns rows/2];
        bottom = imcrop(fullImage, bottomRect);
        
        % write images for top halves to topDir and bottom halves to bottomDir
        currentImage = currentFileNames{1, im};
        fullFileNameTop = fullfile(topDir, currentImage);
        fullFileNameBottom = fullfile(bottomDir, currentImage);
        imwrite(top, fullFileNameTop, 'jpg');
        imwrite(bottom, fullFileNameBottom, 'jpg');
    end
end
