function setUpPaths
% SETUPPATHS Temporarily add GistFromTexture folders to Matlab's path.
%   SETUP_PATHS adds all the subfolders in this project onto Matlab's path. 
%   The change will only stay in effect until Matlab
%   quits, so SETUPPATHS needs to be called every time Matlab is
%   restarted.

% add current folder
PWD = pwd;
addpath(PWD);

addpath(genpath(PWD));

% % add subfolders
% addpath(fullfile(PWD, 'configuration'));
% addpath(fullfile(PWD, 'filters'));
% addpath(fullfile(PWD, 'gmix'));
% addpath(fullfile(PWD, 'indices'));
% addpath(fullfile(PWD, 'olivaAndTorralba'));
% addpath(genpath(fullfile(PWD, 'sample_images')));
% addpath(fullfile(PWD, 'trainingSets'));
% end
