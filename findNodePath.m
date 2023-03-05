function [nodepath, edgepath] = findNodePath(G, subG, n1, n2)
% DESCRIPTION:
% Converts a nodepath of a subgraph into the corresponding nodepath
% of the main graph.

% INPUT:
% G --- Main graph
% subG --- Subgraph
% n1 --- first node in path from the subgraph
% n2 --- second node in path from the subgraph

% OUTPUT:
% nodepath --- vector of node IDs from the main graph

[subpath, ~, subedgepath] = shortestpath(subG, n1, n2);

cnsubpath = subG.Nodes.CN(subpath);
cnedgepath = subG.Edges.CN(subedgepath);

nodepath = zeros(numel(cnsubpath), 1);
for i = 1:numel(cnsubpath)
   iCN = cnsubpath(i);
   nodepath(i) = find(G.Nodes.CN == iCN);
end
% nodepath = find(ismember(G.Nodes.CN, cnsubpath));

if nargout > 1
    edgepath = find(ismember(G.Edges.CN, cnedgepath));
end
