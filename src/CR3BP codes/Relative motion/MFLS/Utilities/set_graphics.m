%% Project: Shape-based optimization for low-thrust transfers %%
% Sergio Cuevas del Valle
% Date: 08/02/2022 

%% Set graphics %% 
% This script provides a function to define the user desired graphical format

function set_graphics()
    %Set graphical properties
    set(groot, 'defaultAxesTickLabelInterpreter', 'latex'); 
    set(groot, 'defaultAxesFontSize', 11); 
    set(groot, 'defaultAxesGridAlpha', 0.3); 
    set(groot, 'defaultAxesLineWidth', 0.75);
    set(groot, 'defaultAxesXMinorTick', 'on');
    set(groot, 'defaultAxesYMinorTick', 'on');
    set(groot, 'defaultFigureRenderer', 'painters');
    set(groot, 'defaultLegendBox', 'off');
    set(groot, 'defaultLegendInterpreter', 'latex');
    set(groot, 'defaultLegendLocation', 'best');
    set(groot, 'defaultLineLineWidth', 1); 
    set(groot, 'defaultLineMarkerSize', 3);
    set(groot, 'defaultTextInterpreter','latex');
end