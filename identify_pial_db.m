
clear, clc, close all

% Add required paths
addpath(genpath(pwd))

%% Load raw kleinfeld data
load('db')
data = db;

%% Construct graph object
segperart = 1;
segperven = 1;
segperother = 1;
Gfull = formatkleinfeld(data, segperart, segperven, segperother);
Gfull.Nodes.Z = -Gfull.Nodes.Z;
figure, plotgraph(Gfull)
G = Gfull;

%% Run automatic pial identification routine
[Gnew, Gart, Gven] = autofindpial(G);

%% Manually define the remaining vessels types
n1 = 65;
n2 = 15;
[~, edgepath] = findnodepath(Gnew, Gart, n1, n2);
Gnew.Edges.Type(edgepath) = 3;

n1 = 86;
n2 = 105;
[~, edgepath] = findnodepath(Gnew, Gart, n1, n2);
Gnew.Edges.Type(edgepath) = 3;

figure, plotgraph(Gnew);
view(2)


