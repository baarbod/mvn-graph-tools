
clear, clc, close all

% Add required paths
addpath(genpath(pwd))

% load full network with pials
dat = load('networks/db_with_pial');
G = dat.G;
figure, plotgraph(G)

% get a section of the full network
xrange = [0, 700];
yrange = [0, 800];
zrange = [-1000, 0];
G_section = getsection(G, xrange, yrange, zrange);
figure, plotgraph(G_section)

% assign generation number to 