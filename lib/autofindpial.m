function [Gnew, Gart, Gven] = autofindpial(Gfull)
% DESCRIPTION:
% Automatically identify pial vessels

% INPUT: 
% Gfull - graph object from the output of formatkleinfeld

% OUTPUT: 
% Gnew - graph object with updated vessel types


% Identify pial vessels based on diving vessel tips
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
                G.Nodes.Type(n1) = 3;
                G.Nodes.Type(n2) = 3;
            end
            
            if any(connected_types == 2)
                G.Edges.Type(iedge) = 4; % pial veins
                G.Nodes.Type(n1) = 4;
                G.Nodes.Type(n2) = 4;
            end
        end
        
    end
end

figsize = [0.2063, 0.1903, 0.4977, 0.7083];

% Create figure for plotting results of processing steps
figure, set(gca, 'Color', 'w')
set(gcf, 'Units', 'Normalized')
set(gcf, 'Position', figsize)

% Create a subgraph of the identified pial vessels
subG = subfromedge(G, find(G.Edges.Type > 2));
subplot(2, 2, 1), plotgraph(subG)
view(2)
title('Step 1 - First pass')

% Create another cleaned up subgraph without small diameter vessels
subG2 = subfromedge(subG, find(subG.Edges.D > 6));
subplot(2, 2, 2), plotgraph(subG2);
view(2)
title('Step 2 - Small diameter vessels removed')

% Remove the small connected components
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

% Redefine pial vessel types in full graph
Gnew = Gfull;
CN_orig_edges = Gfull.Edges.CN;
CN_pial_art_edges = subG2.Edges.CN(subG2.Edges.Type == 3);
CN_pial_ven_edges = subG2.Edges.CN(subG2.Edges.Type == 4);
[~, ~, art_edges] = intersect(CN_pial_art_edges, CN_orig_edges);
[~, ~, ven_edges] = intersect(CN_pial_ven_edges, CN_orig_edges);
Gnew.Edges.Type(art_edges) = 3;
Gnew.Edges.Type(ven_edges) = 4;
CN_orig_nodes = Gfull.Nodes.CN;
CN_pial_art_nodes = subG2.Nodes.CN(subG2.Nodes.Type == 3);
CN_pial_ven_nodes = subG2.Nodes.CN(subG2.Nodes.Type == 4);
[~, ~, art_nodes] = intersect(CN_pial_art_nodes, CN_orig_nodes);
[~, ~, ven_nodes] = intersect(CN_pial_ven_nodes, CN_orig_nodes);
Gnew.Nodes.Type(art_nodes) = 3;
Gnew.Nodes.Type(ven_nodes) = 4;
subplot(2, 2, 4), plotgraph(Gnew);
view(2)
title('Step 4 - Reregistered to original full graph')

figure, set(gca, 'Color', 'w')
set(gcf, 'Units', 'Normalized')
set(gcf, 'Position', figsize)
sgtitle('Network plots for visual inspection')

% Create subgraph of pial arteries to visually inspect 
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

% Create subgraph of pial veins to visually inspect 
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

Gart = subGnew_surface_art;
Gven = subGnew_surface_ven;

end

