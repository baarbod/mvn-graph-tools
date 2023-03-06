function H = plotgenedges(G)

set(gcf,'Color','w')
gen1 = find(G.Edges.Gen == 1);
gen2 = find(G.Edges.Gen == 2);
gen3 = find(G.Edges.Gen == 3);
gen4 = find(G.Edges.Gen == 4);
gen5 = find(G.Edges.Gen == 5);
H = plot(G,'XData',G.Nodes.X,'YData',G.Nodes.Y,'ZData',G.Nodes.Z,...
    'Marker','none');
highlight(H,'Edges',gen1,'EdgeColor','m','LineWidth',3)
highlight(H,'Edges',gen2,'EdgeColor','g','LineWidth',3)
highlight(H,'Edges',gen3,'EdgeColor','b','LineWidth',3)
highlight(H,'Edges',gen4,'EdgeColor','k','LineWidth',3)
highlight(H,'Edges',gen5,'EdgeColor','y','LineWidth',3)

iart = find(G.Edges.Type == 1);
highlight(H,'Edges',iart,'EdgeColor','r','LineWidth',3)

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