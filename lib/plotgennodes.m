function H = plotgennodes(G)

set(gcf,'Color','w')
gen1 = find(G.Nodes.Gen == 1);
gen2 = find(G.Nodes.Gen == 2);
gen3 = find(G.Nodes.Gen == 3);
gen4 = find(G.Nodes.Gen == 4);
gen5 = find(G.Nodes.Gen == 5);
H = plot(G,'XData',G.Nodes.X,'YData',G.Nodes.Y,'ZData',G.Nodes.Z,...
    'Marker','none');
highlight(H,gen1,'MarkerSize',5,'Marker','o','NodeColor','m')
highlight(H,gen2,'MarkerSize',5,'Marker','o','NodeColor','g')
highlight(H,gen3,'MarkerSize',5,'Marker','o','NodeColor','b')
highlight(H,gen4,'MarkerSize',5,'Marker','o','NodeColor','k')
highlight(H,gen5,'MarkerSize',5,'Marker','o','NodeColor','y')
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