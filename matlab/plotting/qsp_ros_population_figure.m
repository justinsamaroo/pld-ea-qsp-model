function fig = qsp_ros_population_figure(P)
% QSP_ROS_POPULATION_FIGURE Redraw S8 from the stored virtual population.
idx = find(strcmp(P.names,'kROSgen'),1);
assert(~isempty(idx),'Stored population lacks kROSgen.');
x = P.theta(:,idx); y = P.PeakROS(:);
c = corrcoef(x,y);
fig = figure('Name','Figure S8 - ROS distribution','NumberTitle','off', ...
    'Color','w','Units','centimeters','Position',[2 2 17.8 8]);
if isprop(fig,'Theme'), fig.Theme = 'light'; end
layout = tiledlayout(fig,1,2,'Padding','compact','TileSpacing','compact');
ax = nexttile(layout); histogram(ax,y,25,'FaceColor',[.47 .67 .19]);
hold(ax,'on'); xline(ax,median(y),'r-','LineWidth',1);
xlabel(ax,'Peak ROS (\muM)'); ylabel(ax,'Count');
title(ax,'A  Peak ROS distribution','FontSize',8);
ax = nexttile(layout); scatter(ax,x,y,12,'filled'); hold(ax,'on');
coef = polyfit(x,y,1); xx = linspace(min(x),max(x),50);
plot(ax,xx,polyval(coef,xx),'r-','LineWidth',1);
xlabel(ax,'k_{ROS,gen} (\muM mL \mug^{-1} h^{-1})');
ylabel(ax,'Peak ROS (\muM)');
title(ax,sprintf('B  ROS generation and peak ROS (r = %.2f)',c(1,2)), ...
    'FontSize',8);
set(findall(fig,'Type','axes'),'FontName','Arial','FontSize',8, ...
    'LineWidth',.75,'Box','on','TitleFontSizeMultiplier',1, ...
    'LabelFontSizeMultiplier',1);
end
