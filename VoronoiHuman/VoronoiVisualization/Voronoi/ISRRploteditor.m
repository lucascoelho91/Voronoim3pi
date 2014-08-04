function ISRRploteditor(name,savename)

% Script to make ISRR plots into pretty PDFs
% Instructions from: http://stackoverflow.com/questions/5150802/how-to-save-a-plot-into-a-pdf-file-without-a-large-margin-around

% INPUT: name of the file to open, saves as that name

close all;

% Create directory name
fullname = ['./ISRR Final/' name '.fig'];
% Now, open figure
openfig(fullname);

% Set the figure as the current property
h = figure(1);


% Adjust the text size
set(gca, 'FontSize', 16);                           % Axis font
set(findall(gcf,'type','text'),'Fontsize',14);      % Marker font
set(findall(gcf,'type','line'),'MarkerSize',10);    % Marker Size
set(findall(gcf,'type','line'),'LineWidth',1.25);      % Line Width
    
% Adjust all the margins
tightInset = get(gca,'TightInset');
position(1) = tightInset(1);
position(2) = tightInset(2);
position(3) = 1 - tightInset(1) - tightInset(3);
position(4) = 1 - tightInset(2) - tightInset(4);
set(gca,'Position',position);

% Create save name and save
fullsave = ['./ISRR Final/' savename '.pdf'];
saveas(h, fullsave);