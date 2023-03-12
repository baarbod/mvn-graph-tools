
clear, clc, close all

% Add required paths
addpath(genpath(pwd))

% load graph object
dat = load('data/graphs/db_with_pial.mat');
G = dat.G;

% plot with colored edges
figure, plotgraph(G)

% plot the nodes with types colored
figure, plotnodes(G)


