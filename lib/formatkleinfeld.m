function G = formatkleinfeld(data, segperart, segperven, segperother)
% DESCRIPTION:
% Converts original data from kleinfeld into a graph object.

% INPUT:
% data - original kleinfeld data structure
% segperart - number of segments in each arteriole strand
% segperven - number of segments in each venule strand
% segperother - number of segments in all other strand

% OUTPUT:
% G - graph object

dbstop if error

name = inputname(1);
network = data;

% vertex coordinates
xyz = double(network.vectorizedStructure.Vertices.AllVerts);

% the au dataset needs a different index
if strcmp(name,'au')
    structcol = 3;
else
    structcol = 4;
end

% get list of strands
temp = struct2cell(network.vectorizedStructure.Strands.').';
strandList = struct('StartToEndIndices', temp(:,structcol));
clear temp

% get the strands specific to arterioles, venules, and other
artStrandList = unique(network.vectorizedStructure.allPlungingArterioleList)';
venStrandList = unique(network.vectorizedStructure.allPlungingVenuleList)';
otherStrandList = [1:numel(strandList)]';
otherStrandList([artStrandList;venStrandList]) = [];

% number of verticies, i.e. nodes
nnod = length(xyz);
nedge = nnod-1;

% initialize edge properties
end_node1 = zeros(nedge, 1);
end_node2 = zeros(nedge, 1);
L = zeros(nedge, 1);
D = zeros(nedge, 1);
etype = zeros(nedge, 1);
CN_edge = zeros(nedge, 1);

% initialize node properties
X = zeros(nnod, 1);
Y = zeros(nnod, 1);
Z = zeros(nnod, 1);
ntype = zeros(nnod, 1);
CN_node = zeros(nnod, 1);

% number of total strands
nstrand = length(strandList);

% sort the nodes and remove duplicates
nodlist = [];
for i = [artStrandList' venStrandList' otherStrandList']
    nodes = cell2mat(struct2cell(strandList(i)))';
    nodlist = [nodlist;nodes];
end
[ordered,~,~] = unique(nodlist);

% start edge counter
iedge = 0;

% main loop over all strands
for istrand = 1:nstrand
    if mod(istrand, round(nstrand/100)) == 0
        pct = 100*istrand/nstrand;
        fprintf('%.1f percent complete\n', pct); 
    end
   
    % grab nodes for the strand
    nodes = cell2mat(struct2cell(strandList(istrand)))';
    
    % if arteriole strand
    if ismember(istrand,artStrandList)
        nodes = down_sample_strand(nodes, segperart);
        type = 1;
    % if venule strand
    elseif ismember(istrand,venStrandList)
        nodes = down_sample_strand(nodes, segperven);
        type = 2;
    % if neither arteriole nor venule strand
    elseif ismember(istrand,otherStrandList)
        nodes = down_sample_strand(nodes, segperother);
        type = 0;
    end
    
    % get the radius associated for the entire strand
    rc = network.vectorizedStructure.effectiveStrandRadiusList(istrand);
    
    % loop through nodes of the strand
    for iter = 1:length(nodes)-1
        
        % work on current node and next one
        inod = nodes(iter);
        next = nodes(iter+1);

        if isempty(nodes) == 1
            break
        end
        
        iedge = iedge + 1;
        
        if iedge > nnod
            break
        end
        
        % define edge properties
        end_node1(iedge) = inod;
        end_node2(iedge) = next;
        L(iedge) = norm(xyz(inod,:)-xyz(next,:));
        D(iedge) = 2*rc;
        CN_edge(iedge) = encodecn(inod,next);
        
        % define node properties for both nodes
        P1 = xyz(inod,:);
        P2 = xyz(next,:);
        x1 = P1(1); y1 = P1(2); z1 = P1(3);
        X(inod) = x1;
        Y(inod) = y1;
        Z(inod) = z1;
        x2 = P2(1); y2 = P2(2); z2 = P2(3);
        X(next) = x2;
        Y(next) = y2;
        Z(next) = z2;
        CN_node(inod) = encodecn(x1,y1,z1);
        CN_node(next) = encodecn(x2,y2,z2);
      
        % define edge and node types based on strand type        
        etype(iedge) = type;
        ntype(inod) = type;
        ntype(next) = type;
        
    end
end

% trim zeros out of edge properties
ind_to_remove = ~any(end_node1, 2);
end_node1(ind_to_remove) = [];
end_node2(ind_to_remove) = [];
L(ind_to_remove) = [];
D(ind_to_remove) = [];
etype(ind_to_remove) = [];
CN_edge(ind_to_remove) = [];

% trim node properties
allnod = [end_node1;end_node2];
allnod = unique(allnod);
XYZ = xyz(allnod,:);
ntype = ntype(allnod);
X = XYZ(:,1); Y = XYZ(:,2); Z = XYZ(:,3);
CN_node(CN_node==0) = [];
rowlen = length(end_node1);
[~,~,rename] = unique([end_node1;end_node2]);
end_node1 = rename(1:rowlen);
end_node2 = rename(rowlen+1:end);

% use edge and node tables to define the graph object
EdgeTable = table([end_node1 end_node2], ...
    ones(numel(end_node1),1),L,D,etype,CN_edge,...
    'VariableNames',{'EndNodes' 'Weight' 'L' 'D' 'Type' 'CN'});

NodeTable = table(X,Y,Z,ntype, CN_node, ...
    'VariableNames',{'X' 'Y' 'Z' 'Type' 'CN'});

G = graph(EdgeTable,NodeTable);

% remove self-loops
G = rmedge(G, 1:numnodes(G), 1:numnodes(G));
end

function nodes = down_sample_strand(nodes, nseg)
    % if seg parameter given
    if ~isempty(nseg)
        % downsample the nodes based on seg parameter
        strand_nodes = nodes;
        % check if strand reduction needed
        if length(strand_nodes) ~= (nseg + 1) 
            increment = ceil(length(strand_nodes)/nseg);
            nodes_to_keep = strand_nodes(1:increment:end);
            strand_nodes = [nodes_to_keep;strand_nodes(end)];
        end
        nodes = strand_nodes';
    end
end
