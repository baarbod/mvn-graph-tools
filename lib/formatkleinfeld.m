function G = formatkleinfeld(data, segperart, segperven, segperother)
% DESCRIPTION:
% Converts original data from kleinfeld into a graph object.

% INPUT:
% data - original kleinfeld data structure
% segperart - number of segments in each arteriole strand
% segperother - number of segments in all other strand

% OUTPUT:
% G - graph object

dbstop if error

name = inputname(1);
network = data;
xyz = double(network.vectorizedStructure.Vertices.AllVerts);

% if strcmp(name,'au')
%     structcol = 3;
% else
    structcol = 4;
% end

temp = struct2cell(network.vectorizedStructure.Strands.').';
strandList = struct('StartToEndIndices', temp(:,structcol));
clear temp

artStrandList = unique(network.vectorizedStructure.allPlungingArterioleList)';
venStrandList = unique(network.vectorizedStructure.allPlungingVenuleList)';
otherStrandList = [1:numel(strandList)]';
otherStrandList([artStrandList;venStrandList]) = [];

f = waitbar(0,'Generating reduced structure...');

nnod = length(xyz);
row = zeros(nnod,1);
col = zeros(nnod,1);
L = zeros(nnod,1);
D = zeros(nnod,1);
TYPE = zeros(nnod,1);
X = zeros(nnod,1);
Y = zeros(nnod,1);
Z = zeros(nnod,1);
CN_node = zeros(nnod,1);
CN_edge = zeros(nnod,1);

nstrand = length(strandList);
iedge = 0;

nodlist = [];
for i = [artStrandList' venStrandList' otherStrandList']
    nodes = cell2mat(struct2cell(strandList(i)))';
    nodlist = [nodlist;nodes];
end
[ordered,~,~] = unique(nodlist);

for istrand = 1:nstrand
    nodes = cell2mat(struct2cell(strandList(istrand)))';
    rc = network.vectorizedStructure.effectiveStrandRadiusList(istrand);
    
    if ismember(istrand,artStrandList)
        if ~isempty(segperart)
            strandNodList = nodes;
            if length(strandNodList) ~= (segperart + 1) % strand reduction needed
                indJumpSize = ceil(length(strandNodList)/segperart);
                nodToKeep = strandNodList(1:indJumpSize:end);
                strandNodList = [nodToKeep;strandNodList(end)];
            end
                nodes = strandNodList';
        end
    elseif ismember(istrand,venStrandList)
        if ~isempty(segperven)
            strandNodList = nodes;
            if length(strandNodList) ~= (segperven + 1) % strand reduction needed
                indJumpSize = ceil(length(strandNodList)/segperven);
                nodToKeep = strandNodList(1:indJumpSize:end);
                strandNodList = [nodToKeep;strandNodList(end)];
            end
            nodes = strandNodList';
        end
    elseif ismember(istrand,otherStrandList)
        if ~isempty(segperother)
            strandNodList = nodes;
            if length(strandNodList) ~= (segperother + 1) % strand reduction needed
                indJumpSize = ceil(length(strandNodList)/segperother);
                nodToKeep = strandNodList(1:indJumpSize:end);
                strandNodList = [nodToKeep;strandNodList(end)];
            end
            nodes = strandNodList';
        end
    end
    
    for ii = 1:length(nodes)-1
        
        inod = find(ismember(ordered,nodes(ii)));
        next = find(ismember(ordered,nodes(ii+1)));
        
        if isempty(nodes) == 1
            break
        end
        iedge = iedge + 1;
        if iedge > nnod
            break
        end
        row(iedge) = inod;
        col(iedge) = next;
        L(iedge) = norm(xyz(inod,:)-xyz(next,:));
        D(iedge) = 2*rc;
        CN_edge(iedge) = encodecn(inod,next);
          
        P1 = xyz(inod,:);
        P2 = xyz(next,:);
        x1 = P1(1); y1 = P1(2); z1 = P1(3);
        X(inod) = x1;
        Y(inod) = y1;
        Z(inod) = z1;
        
        CN_node(inod) = encodecn(x1,y1,z1);
        
        x2 = P2(1); y2 = P2(2); z2 = P2(3);
        X(next) = x2;
        Y(next) = y2;
        Z(next) = z2;
        
        CN_node(next) = encodecn(x2,y2,z2);
        
        if ismember(istrand,artStrandList)
            TYPE(iedge) = 1;
        elseif ismember(istrand,venStrandList)
            TYPE(iedge) = 2; 
        elseif ismember(istrand,otherStrandList)
            TYPE(iedge) = 0;
        end
        
    end
    waitbar(istrand/nstrand,f)
end
close(f)

remInd = ~any(row, 2);
row(remInd) = [];
col(remInd) = [];
L(remInd) = [];
D(remInd) = [];
TYPE(remInd) = [];
CN_edge(remInd) = [];

allnod = [row;col];
allnod = unique(allnod);
XYZ = xyz(allnod,:);
X = XYZ(:,1); Y = XYZ(:,2); Z = XYZ(:,3);

CN_node(CN_node==0) = [];

rowlen = length(row);
[~,~,rename] = unique([row;col]);
row = rename(1:rowlen);
col = rename(rowlen+1:end);

EdgeTable = table([row col],ones(numel(row),1),L,D,TYPE,CN_edge,...
    'VariableNames',{'EndNodes' 'Weight' 'L' 'D' 'Type' 'CN'});

NodeTable = table(X,Y,Z,CN_node, 'VariableNames',{'X' 'Y' 'Z' 'CN'});

G = graph(EdgeTable,NodeTable);

