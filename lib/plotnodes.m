function H = plotnodes(G)

set(gcf,'Color','w')
type1 = find(G.Nodes.Type == 1);
type2 = find(G.Nodes.Type == 2);
type3 = find(G.Nodes.Type == 3);
type4 = find(G.Nodes.Type == 4);
H = plot(G,'XData',G.Nodes.X,'YData',G.Nodes.Y,'ZData',G.Nodes.Z,...
    'Marker','none', 'EdgeColor', 'none');
highlight(H,type1,'MarkerSize',4,'Marker','.','NodeColor','r')
highlight(H,type2,'MarkerSize',4,'Marker','.','NodeColor','b')
highlight(H,type3,'MarkerSize',6,'Marker','o','NodeColor','r')
highlight(H,type4,'MarkerSize',6,'Marker','o','NodeColor','b')

ax = gca;
ax.FontWeight = 'bold';
ax.FontName = 'arial';
ax.FontSize = 16;
ax.XGrid = 'off';
ax.YGrid = 'off';
ax.ZGrid = 'off';
ax.LineWidth = 2;
ax.XAxis.Label.String = 'x (\mum)';
ax.YAxis.Label.String = 'y (\mum)';

axis equal
ax.XLim = [0.9*min(G.Nodes.X), 1.1*max(G.Nodes.X)];
ax.YLim = [0.9*min(G.Nodes.Y), 1.1*max(G.Nodes.Y)];

if isfield(table2struct(G.Nodes),'Z')
    ax.ZAxis.Label.String = 'z (\mum)';
    if min(G.Nodes.Z) >= 0
        ax.ZLim = [0.9*min(G.Nodes.Z), 1.1*max(G.Nodes.Z)];
    else
        ax.ZLim = [1.1*min(G.Nodes.Z), 0.9*max(G.Nodes.Z)];
    end
end

box off