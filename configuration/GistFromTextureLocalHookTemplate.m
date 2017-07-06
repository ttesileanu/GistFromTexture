function GistFromTextureLocalHook
% GistFromTextureLocalHook - Configure for the project
% 
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by default,
% ~/localToolboxHooks) and delete "Template" from the filename,
% this will get run when you execute:
%     tbUseProject('GistFromTexture','reset','full')
% to set up for this project.  You then edit your local copy to match your local machine.
% The call to tbUseProject will do the copy, if there is no local hook
% already present on your machine.
%
% You will need to edit the project prefs to point at the data on your
% computer.

% 6/24/17  dhb      Created.  Removed reliance on BLTB GetComputerInfo.
% 7/6/17 as Updated. baseDir points to GistFromTexture project. Added
% preferences. 

% Define project
theProject = 'GistFromTexture';

%% Say hello
fprintf('Running %s hook\n',theProject);

%% Clear prefs
if (ispref(theProject))
    rmpref(theProject);
end

%% Setup basedir with good guesses
% Get the local host name.
[~, localHostName] = system('scutil --get LocalHostName');
sysInfo.localHostName = localHostName(1:end-1);
[~, userShortName] = system('id -un');
sysInfo.userShortName = userShortName(1:end-1);
switch (sysInfo.localHostName)
    case 'eagleray'
        % DHB's desktop
        baseDir = fullfile(filesep,'Volumes','Users1','DropboxLab/GistFromTexture');
    case 'Annies-MacBook-Pro-2'
        % Annie's laptop
        baseDir = fullfile(filesep,'/Volumes','Annie','GistFromTexture');
    otherwise
        % Some unspecified machine, try user specific customization
        switch(sysInfo.userShortName)
            % Could put user specific things in, but at the moment generic
            % is good enough.
            otherwise
                baseDir = ['/Users/' sysInfo.userShortName 'DropboxLab/GistFromTexture'];
        end
end

%% Set preferences

% Botswana database
setpref(theProject,'botswanaDatabase',fullfile(baseDir,'BotswanaImagesOrig'));

% Philly database
setpref(theProject,'phillyDatabase',fullfile(baseDir,'PhillyImages'));

% Natural scene images
setpref(theProject, 'naturalScene', fullfile(baseDir, 'natural'));

% Manmade scene images
setpref(theProject, 'manmadeScene', fullfile(baseDir, 'manmade'));


