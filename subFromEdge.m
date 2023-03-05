function subG = subFromEdge(G, edgeInd)
% function [subG,nodeList] = subFromEdge(G, edgeInd)
% DESCRIPTION:
% Make a subgraph from edge indicies

% INPUT: 
% G - graph object
% edgeInd - index of edges to keep 

% OUTPUT:
% subG - subgraph
% nodeList - node indicies of the original graph used for the subgraph

% edgelist = G.Edges{:,1};
% 
% edgeToKeep = edgelist(edgeInd,:);
% 
% span = 2*length(edgeToKeep);
% 
% nodeList = unique(reshape(edgeToKeep,[span 1]));
% 
% subG = subgraph(G, nodeList);

% figure 
% hold on
% H = plotgraph(G); H.EdgeAlpha = 0.1;
% H = plotgraph(subG); H.EdgeAlpha = 0.8;

ind = find(~ismember(1:numedges(G), edgeInd));
subG = rmedge(G, ind);

if isa(subG,'digraph')
    EdgeTable = subG.Edges;
    NodeTable = subG.Nodes;
    subG = graph(EdgeTable,NodeTable);
end

degList = degree(subG);
subG = rmnode(subG, find(degList == 0));




