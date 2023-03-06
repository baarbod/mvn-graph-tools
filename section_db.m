
clear, clc, close all

% Add required paths
addpath(genpath(pwd))

% load full network with pials
dat = load('networks/db_with_pial');
G0 = dat.G;
figure, plotgraph(G0)

% get a section of the full network
xrange = [0, 700];
yrange = [0, 800];
zrange = [-1000, 0];
G = getsection(G0, xrange, yrange, zrange);
figure, plotgraph(G)

% label vessel generations 
subG = subfromedge(G, find(G.Edges.Type == 1));
figure, plotgraph(subG)
n1 = 1;
n2 = 96;
artnodes = findnodepath(G, subG, n1, n2);
ngen = 4;
G = labelgenerations(G, ngen, artnodes);
figure, plotgennodes(G)
figure, plotgenedges(G)

