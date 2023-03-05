function subG = subfromedge(G, edgeInd)
% function [subG,nodeList] = subFromEdge(G, edgeInd)
% DESCRIPTION:
% Make a subgraph from edge indicies

% INPUT: 
% G - graph object
% edgeInd - index of edges to keep 

% OUTPUT:
% subG - subgraph
% nodeList - node indicies of the original graph used for the subgraph

ind = find(~ismember(1:numedges(G), edgeInd));
subG = rmedge(G, ind);

if isa(subG,'digraph')
    EdgeTable = subG.Edges;
    NodeTable = subG.Nodes;
    subG = graph(EdgeTable,NodeTable);
end

degList = degree(subG);
subG = rmnode(subG, find(degList == 0));

% figure 
% hold on
% H = plotgraph(G); H.EdgeAlpha = 0.1;
% H = plotgraph(subG); H.EdgeAlpha = 0.8;


