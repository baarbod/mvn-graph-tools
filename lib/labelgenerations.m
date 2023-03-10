function G = labelgenerations(G, ngen, artnodes)
% DESCRIPTION: 
% Assign value to nodes and edges representing number of generations from
% arteriole nodes

% INPUT:
% G - graph object
% ngen - number of generations
% artnodes - arteriole nodes from which generations will be found 

% OUTPUT:
% G - graph object same as input with added generation information

indType1 = G.Edges.Type == 0;
edgelist = G.Edges{indType1,1};
span = 2*length(edgelist);
capnodes = unique(reshape(edgelist,[span 1]));
deglist = degree(G);

nextsourceList = [];
nodeGenList = [];
G.Nodes.Gen = zeros(numnodes(G),1);

f = waitbar(0, 'Labeling generations...');
for i = 1:numel(artnodes)
    isource = artnodes(i);
    [stack, nextsource] = getStack(G, isource, capnodes, artnodes, deglist);
    nextsourceList = unique([nextsourceList; nextsource]);
    nodeGenList = [nodeGenList; stack];
    waitbar(i/numel(artnodes), f)
end
close(f)
G.Nodes.Gen(unique(nodeGenList)) = 1;
 
for i = 2:ngen
    nodeGenList = [];
    sourceList = nextsourceList;
    nextsourceList = [];
    for k = 1:numel(sourceList)
        isource = sourceList(k);
        [stack, nextsource] = getStack(G, isource, capnodes, artnodes, deglist);
        nodeGenList = [nodeGenList; stack];
        nextsourceList = unique([nextsourceList; nextsource]); 
    end
    ind = G.Nodes.Gen(nodeGenList) > 0;
    nodeGenList(ind) = [];
    G.Nodes.Gen(unique(nodeGenList)) = i;
end

%%
G.Edges.Gen = zeros(numedges(G),1);

for igen = 1:ngen
    for iedge = 1:numedges(G)
        [n1, n2] = findedge(G, iedge);
        type1_unsorted = G.Nodes.Gen(n1);
        type2_unsorted = G.Nodes.Gen(n2);
        typeList = sort([type1_unsorted;type2_unsorted]);
        type1 = typeList(1);
        type2 = typeList(2);
        if type1 == igen-1 && type2 == igen
            G.Edges.Gen(iedge) = igen;
        elseif type1 == igen && type2 == igen
            G.Edges.Gen(iedge) = igen;
        elseif type1 == igen && type2 == igen+1
            G.Edges.Gen(iedge) = igen+1;
        end
    end
end

end

function [stack, nextsource] = getStack(G, source, capnodes, artnodes, deglist)
stack = source;
cond1 = 1;
cond2 = 1;
cond3 = 1;
exit_cond_count = 0;
while (cond1 && cond2 && cond3)
    N = neighbors(G, source);
    N(~ismember(N, capnodes)) = [];
    N(ismember(N, artnodes)) = [];
    N(ismember(N, stack)) = [];
    stack = [stack; N];
    if isempty(stack)
        nextsource = [];
        return
    end
    source = stack(end);
    cond1 = deglist(source) < 3;
    cond2 = deglist(source) ~= 1;
    cond3 = ~isequal(stack, source);
    if sum([cond1, cond2, cond3]) == 3
        exit_cond_count = exit_cond_count + 1;
    end
    if exit_cond_count > 20
        % skip
        break
    end
end
nextsource = neighbors(G, source);
nextsource(~ismember(nextsource, capnodes)) = [];
nextsource(ismember(nextsource, artnodes)) = [];
nextsource(ismember(nextsource, stack)) = [];
stack(ismember(stack, artnodes)) = [];
end




