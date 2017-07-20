% plotPowerSpectrum
%
% Plots the contours of the loaded average power spectra of the natural
% images and manmade images. Each of the 10 texture statistics is plotted

% first, load the desired versions of avgPowerSpectraNatural and 
% avgPowerSpectraManmade!
%load avgPowerSpectraManmade2x32.mat
%load avgPowerSpectraNatural2x32.mat

% specify the name of each texture statistic, to be used in figures
textureNames = {'\gamma', '\beta_{|}', '\beta_{--}', '\beta_{\\}', '\beta_{/}', ...
     '\theta_{\lceil}', '\theta_{\rfloor}', '\theta_{\rceil}', '\theta_{\lfloor}', '\alpha'};
 
figure; 

% plot natural image contours along first row
for ii = 1:10
    h = subplot(2, 10, ii); 
    contour(fftshift(avgPowerSpectraNatural{ii, 1})); 
    axis equal;
    xlim([88 98]);
    ylim([50 70]);
    title(textureNames{1, ii});
end

% plot manmade image contours along second row
for ii = 1:10
    h = subplot(2, 10, ii + 10); 
    contour(fftshift(avgPowerSpectraManmade{ii, 1})); 
    axis equal;
    xlim([88 98]);
    ylim([50 70]);
    title(textureNames{1, ii});
end

% remove excess margins from figures
% see http://www.mathworks.com/matlabcentral/fileexchange/34055-tightfig
tightfig;

suptitle('Power Spectrum Contours - ');
