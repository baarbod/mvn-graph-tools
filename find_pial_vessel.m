
clear, clc, close all

% Add required paths
addpath(genpath(pwd))

%% Load raw kleinfeld data
% load('au');
% load('co');
load('co')
% load('db')

data = co;

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

function Gnew = autofindpial(Gfull)
%% Identify pial vessels based on diving vessel tips

G = Gfull;

% loop through edges
for iedge = 1:G.numedges
    
    % capillaries and pial vessels are type 0 at this stage
    if G.Edges.Type(iedge) == 0
        
        % grab endnodes and their coordinates
        nodes = G.Edges{iedge, 1};
        n1 = nodes(1);
        n2 = nodes(2);
        z1 = G.Nodes{n1, 3};
        z2 = G.Nodes{n2, 3};
        
        % pial vessels are at the surface
        if mean([z1, z2]) > -300
            
            % find connected edges for each pial vessel endnode
            eid1 = outedges(G,n1);
            eid2 = outedges(G,n2);
            connected_types = G.Edges.Type([eid1;eid2]);
            
            % assign the edge type based on type of these connected edges
            if any(connected_types == 1)
                G.Edges.Type(iedge) = 3; % pial arteries
            end
            
            if any(connected_types == 2)
                G.Edges.Type(iedge) = 4; % pial veins
            end
        end
        
    end
end

figsize = [0.2063, 0.1903, 0.4977, 0.7083];

figure, set(gca, 'Color', 'w')
set(gcf, 'Units', 'Normalized')
set(gcf, 'Position', figsize)

%% Create a subgraph of the identified pial vessels
subG = subfromedge(G, find(G.Edges.Type > 2));
subplot(2, 2, 1), plotgraph(subG)
view(2)
title('Step 1 - First pass')

%% Create another cleaned up subgraph without small diameter vessels
subG2 = subfromedge(subG, find(subG.Edges.D > 6));
subplot(2, 2, 2), plotgraph(subG2);
view(2)
title('Step 2 - Small diameter vessels removed')

%% Remove the small connected components
[bins, binsizes] = conncomp(subG2);
nod2rem = [];
for ii = 1:numel(binsizes)
    bsize = binsizes(ii);
    if bsize < 4
        small_bin_nodes = find(bins == ii);
        nod2rem = [nod2rem, small_bin_nodes];
    end
end
subG_small_comp_rem = rmnode(subG2, nod2rem);
subplot(2, 2, 3), plotgraph(subG_small_comp_rem);
view(2)
title('Step 3 - Smaller connected components removed')

%% Redefine pial vessel types in full graph
Gnew = Gfull;
CN_pial_art = subG2.Edges.CN(subG2.Edges.Type == 3);
CN_pial_ven = subG2.Edges.CN(subG2.Edges.Type == 4);
CN_orig = Gfull.Edges.CN;
[~, ~, pial_art_ind_full_graph] = intersect(CN_pial_art, CN_orig);
[~, ~, pial_ven_ind_full_graph] = intersect(CN_pial_ven, CN_orig);
Gnew.Edges.Type(pial_art_ind_full_graph) = 3;
Gnew.Edges.Type(pial_ven_ind_full_graph) = 4;
subplot(2, 2, 4), plotgraph(Gnew);
view(2)
title('Step 4 - Reregistered to original full graph')

figure, set(gca, 'Color', 'w')
set(gcf, 'Units', 'Normalized')
set(gcf, 'Position', figsize)
sgtitle('Network plots for visual inspection')

%% Create subgraph of surface to visually inspect

% ranges for cutting out the surface
xrange = [];
yrange = [];
zrange = [-400, 0];
subGnew_surface_art = getsection(Gnew, xrange, yrange, zrange);
cond1 = subGnew_surface_art.Edges.Type ~= 2; % omit venules
cond2 = subGnew_surface_art.Edges.Type ~= 4; % omit veins
cond3 = subGnew_surface_art.Edges.D > 6; % keep larger vessels
ind2keep = find(cond1 & cond2 & cond3);
subGnew_surface_art = subfromedge(subGnew_surface_art, ind2keep);
subplot(2, 1, 1), plotgraph(subGnew_surface_art);
view(2)

% ranges for cutting out the surface
xrange = [];
yrange = [];
zrange = [-400, 0];
subGnew_surface_ven = getsection(Gnew, xrange, yrange, zrange);
cond1 = subGnew_surface_ven.Edges.Type ~= 1; % omit arterioles
cond2 = subGnew_surface_ven.Edges.Type ~= 3; % omit arteries
cond3 = subGnew_surface_ven.Edges.D > 6; % keep larger vessels
ind2keep = find(cond1 & cond2 & cond3);
subGnew_surface_ven = subfromedge(subGnew_surface_ven, ind2keep);
subplot(2, 1, 2), plotgraph(subGnew_surface_ven);
view(2)

end

