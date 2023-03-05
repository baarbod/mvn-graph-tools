function H = plotgraph(varargin)

G = varargin{1};

if nargin > 1
    ax = varargin{2};
else
    ax = gca;
end

% plots a graph object in a sexy way

set(gcf,'Color','w')

if isfield(table2struct(G.Nodes),'Z')
    H = plot(ax, G,'XData',G.Nodes.X,'YData',G.Nodes.Y,'ZData',G.Nodes.Z,...
        'Marker','none');
%         H = plot(ax, G,'XData',G.Nodes.X,'YData',G.Nodes.Y,'ZData',G.Nodes.Z);
else
    H = plot(ax, G,'XData',G.Nodes.X,'YData',G.Nodes.Y,'Marker','none');
end

H.ShowArrows = 'off';
H.NodeLabel = {};

if isfield(table2struct(G.Edges),'Type')
    iart = find(G.Edges.Type == 1);
    iven = find(G.Edges.Type == 2);
    icap = find(G.Edges.Type == 0);
    iArtery = find(G.Edges.Type == 3);
    iVein = find(G.Edges.Type == 4);
    iUnlabeled = find(G.Edges.Type == 5);
    highlight(H,'Edges',iart,'EdgeColor','r','LineWidth',3)
    highlight(H,'Edges',iven,'EdgeColor','b','LineWidth',3)
    highlight(H,'Edges',icap,'EdgeColor',[0.65, 0.65, 0.65],'LineWidth',1)
    highlight(H,'Edges',iArtery,'EdgeColor','r','LineWidth',5)
    highlight(H,'Edges',iVein,'EdgeColor','b','LineWidth',5)
    highlight(H,'Edges',iUnlabeled,'EdgeColor','g','LineWidth',5)
end

ax = gca;
ax.FontWeight = 'bold';
ax.Color = 'w';
ax.FontName = 'arial';
ax.FontSize = 12;
ax.XGrid = 'off';
ax.YGrid = 'off';
ax.ZGrid = 'off';
ax.LineWidth = 2;
ax.XAxis.Label.String = 'x (\mum)';
ax.YAxis.Label.String = 'y (\mum)';

lb = 0.9;
ub = 1.1;

axis equal
ax.XLim = [lb*min(G.Nodes.X), ub*max(G.Nodes.X)];
ax.YLim = [lb*min(G.Nodes.Y), ub*max(G.Nodes.Y)];

if isfield(table2struct(G.Nodes),'Z')
    ax.ZAxis.Label.String = 'z (\mum)';
    if min(G.Nodes.Z) + max(G.Nodes.Z) > 0
        if min(G.Nodes.Z) >= 0
            ax.ZLim = [lb*min(G.Nodes.Z), ub*max(G.Nodes.Z)];
        else
            ax.ZLim = [ub*min(G.Nodes.Z), lb*max(G.Nodes.Z)];
        end
    end
end

box off







