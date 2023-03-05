
clear, clc, close all

% Add required paths
addpath(genpath(pwd))

%% Load raw kleinfeld data
load('au');
data = au;

%% Construct graph object
segperart = 1;
segperven = 1;
segperother = 1;
Gfull = formatkleinfeld(data, segperart, segperven, segperother);
Gfull.Nodes.Z = -Gfull.Nodes.Z;
figure, plotgraph(Gfull)
G = Gfull;

%% Run automatic pial identification routine
Gnew = autofindpial(G);

%% Manually define the remaining vessels types
n1 = 31;
n2 = 61;
[nodepath, edgepath] = findnodepath(Gnew, subGnew_surface_art, n1, n2);
Gnew.Edges.Type(edgepath) = 3;
figure, plotgraph(Gnew);
view(2)

