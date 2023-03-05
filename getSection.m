function subG = getSection(G, xrange, yrange, zrange)
% DESCRIPTION: 
% Make subgraph from nodes within XYZ ranges specified

% INPUT:
% x/y/z range - two element vector of min/max ranges 

% OUTPUT:
% subG - subgraph of G

X = G.Nodes.X; Y = G.Nodes.Y; Z = G.Nodes.Z;

if isempty(xrange)
    xrange = [min(G.Nodes.X), max(G.Nodes.X)];
end

if isempty(yrange)
    yrange = [min(G.Nodes.Y), max(G.Nodes.Y)];
end

if isempty(zrange)
    zrange = [min(G.Nodes.Z), max(G.Nodes.Z)];
end

X(X <= xrange(1)) = 0;
X(X >= xrange(2)) = 0;

Y(Y <= yrange(1)) = 0;
Y(Y >= yrange(2)) = 0;

Z(Z <= zrange(1)) = 0;
Z(Z >= zrange(2)) = 0;

XYZ = [X, Y, Z];

trashnod = any(XYZ==0,2);

keepnod = 1:numnodes(G);
keepnod(trashnod) = [];

isKeepEdgeNode = zeros(numedges(G), 2);
edgelist = G.Edges{:,1};
for i = 1:numedges(G)
    nodes = edgelist(i, :);
    isKeepEdgeNode(i, :) = ismember(nodes, keepnod);
end

sumList = sum(isKeepEdgeNode,2); 
ind = find(sumList == 1);
for i = 1:numel(ind)
   nodes = edgelist(ind(i),:); 
   a = isKeepEdgeNode(ind(i),:);
   shouldBeKeep = a == 0;
   keepnod = [keepnod, nodes(shouldBeKeep)];
end


keepnod = unique(keepnod);

subG = subgraph(G,keepnod);

if isa(subG,'graph')
    deglist = degree(subG);
elseif isa(subG,'digraph')
    deglist = indegree(subG) + outdegree(subG);
else
    error('Invalid input graph!')
end

subG = rmnode(subG,find(deglist==0));
subG = rmedge(subG, 1:numnodes(subG), 1:numnodes(subG));
edgelist = subG.Edges{:,1};
[~,bi,~] = unique(edgelist, 'rows');
remedgeind = find(~ismember(1:numedges(subG),bi));
subG = rmedge(subG, remedgeind);

if isa(subG,'graph')
    deglist = degree(subG);
elseif isa(subG,'digraph')
    deglist = indegree(subG) + outdegree(subG);
else
    error('Invalid input graph!')
end

% xyz = [subG.Nodes.X, subG.Nodes.Y, subG.Nodes.Z];
% figure, H = plot(subG,'XData',xyz(:,1),'YData',xyz(:,2),'ZData',xyz(:,3));
% highlight(H,find(deglist==1),'MarkerSize',5,'Marker','s','NodeColor','g')
% title("Degree 1 nodes labeled green")
% 
% figure 
% hold on
% H = plotgraph(G); H.EdgeAlpha = 0.1;
% H = plotgraph(subG); H.EdgeAlpha = 0.8;
% 
% figure, plotgraph(subG);










