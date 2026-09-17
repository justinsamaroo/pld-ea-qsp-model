function fig = qsp_main_figure(number,data)
% QSP_MAIN_FIGURE Draw a main figure without running a model simulation.
% Uses the revised manuscript layouts at 8 pt or larger at final size.
if nargin<2, data = struct(); end
switch number
    case 1
        fig = draw_model_schematic();
    case 2
        fig = draw_exposure(data.eta_form,data.effective_Cmax);
    case 3
        fig = draw_biomarkers(data.doses,data.ratio,data.attenuation,data.names);
    case 4
        assert(isequal(size(data.ST),[28 5]) && all(isfinite(data.ST(:))), ...
            'Expected 28 by 5 finite Sobol indices.');
        fig = draw_sobol(data);
    otherwise
        error('qsp_main_figure:UnknownFigure','Expected a figure number from 1 to 4.');
end
end

function f = new_figure(name,widthMM,heightMM)
f = figure('Name',name,'NumberTitle','off','Color','w', ...
    'Units','centimeters','Position',[2 2 widthMM/10 heightMM/10], ...
    'PaperUnits','centimeters','PaperSize',[widthMM/10 heightMM/10], ...
    'PaperPosition',[0 0 widthMM/10 heightMM/10], ...
    'PaperPositionMode','manual','MenuBar','none','ToolBar','none');
if isprop(f,'Theme'), f.Theme = 'light'; end
end

function ax = plot_axes(f,position)
ax = axes('Parent',f,'Position',position,'FontName','Arial','FontSize',8, ...
    'LineWidth',0.75,'Box','on','TickDir','out','XColor','k','YColor','k', ...
    'Color','w','TitleFontSizeMultiplier',1,'LabelFontSizeMultiplier',1);
hold(ax,'on');
end

function f = draw_model_schematic()
f = new_figure('Figure 1 - Model structure',178,179);
ax = axes(f,'Position',[0 0 1 1],'XLim',[0 178],'YLim',[0 179],'YDir','reverse');
axis(ax,'off'); hold(ax,'on');
black = [0.12 0.12 0.12]; blue = [0 0.36 0.65];
state = [0.94 0.94 0.94]; derived = [1 1 1];

panel(ax,[2 2 174 63],'A  PLD and doxorubicin pharmacokinetics (9 states)');
node(ax,[8 21 37 12],{'Liposomal DOX','5 dose cohorts'},state);
node(ax,[60 21 35 12],{'Free plasma DOX','C_p'},state);
node(ax,[113 12 30 11],{'RES DOX','C_{RES}'},state);
node(ax,[113 31 30 11],{'Cardiac DOX','C_{heart}'},state);
node(ax,[113 50 30 11],{'Tumor DOX','C_{tumor}'},state);
txt(ax,26.5,14.5,{'PLD','5 weekly IV doses'},black);
flow(f,[26.5 19;26.5 21],black,'-');
flow(f,[45 27;60 27],black,'-');
txt(ax,52.5,23.5,'Release',black);
flow(f,[43 21;43 17;113 17],black,'-');
txt(ax,77.5,13.5,'Liposomal clearance',black);
flow(f,[95 23;106 23;106 20;113 20],black,'-');
txt(ax,103.5,26,'Uptake',black);
flow(f,[95 29;113 35],black,'-',true);
flow(f,[95 32;100 32;100 53;113 53],black,'-',true);
flow(f,[26.5 33;26.5 58;113 58],black,':');
txt(ax,66,54.5,'EPR input*',black);
flow(f,[77.5 33;77.5 42],black,'-');
txt(ax,77.5,45.5,'Plasma clearance',black);
flow(f,[143 17.5;149 17.5],black,'-');
txt(ax,151,17.5,{'Untracked','RES loss'},black,'left');
flow(f,[143 36.5;149 36.5],black,'-');
txt(ax,151,36.5,{'Cardiac','elimination'},black,'left');
flow(f,[143 55.5;149 55.5],black,'-');
txt(ax,151,55.5,{'Tumor','elimination'},black,'left');

panel(ax,[2 68 174 28],'B  Ellagic acid pharmacokinetics (3 states)');
node(ax,[40 79 28 10],{'GI depot','A_{GI}'},state);
node(ax,[88 79 30 10],{'Plasma EA','C_{EA,p}'},state);
node(ax,[136 79 32 10],{'Peripheral EA','C_{EA,t}'},state);
txt(ax,18,78.5,{'EA','Once daily oral'},blue);
flow(f,[30 84;40 84],blue,'-');
flow(f,[68 84;88 84],blue,'-');
txt(ax,78,80,'k_a, F',blue);
flow(f,[118 84;136 84],blue,'-',true);
txt(ax,127,80,'k_{12}, k_{21}',blue);
flow(f,[103 89;103 91.5],blue,'-');
txt(ax,103,94,'Central elimination',blue);

panel(ax,[2 99 174 58],'C  Pharmacodynamics (8 states) and cardiac function');
node(ax,[10 115 43 12],{'Viable tumor cells','Growth and DOX killing'},state);
node(ax,[68 115 47 12],{'Five cardiac biomarkers','Production and turnover'},state);
node(ax,[131 115 36 12],{'Cardiac ROS','Production and removal'},state);
txt(ax,31.5,110,'C_{tumor}',black);
txt(ax,91.5,110,'C_{heart}',black);
txt(ax,149,110,'C_{heart}',black);
flow(f,[31.5 112;31.5 115],black,'-');
flow(f,[91.5 112;91.5 115],black,'-');
flow(f,[149 112;149 115],black,'-');
node(ax,[61 133 58 9],{'C_{EA,eff} = \eta_{form} C_{EA,p}'},derived);
flow(f,[61 137.5;31.5 137.5;31.5 127],blue,'--');
flow(f,[91.5 133;91.5 127],blue,'--');
flow(f,[119 137.5;149 137.5;149 127],blue,'--');
txt(ax,33,130.5,'DOX killing \uparrow',blue,'left');
txt(ax,93,130,'Turnover \uparrow',blue,'left');
txt(ax,150.5,130.5,'Scavenging \uparrow',blue,'left');
txt(ax,20,149.5,'C_{heart}',black);
node(ax,[47 145 55 9],{'Cumulative cardiac DOX','AUC_{heart}'},state);
node(ax,[127 145 35 9],{'EF and FS','Calculated outputs'},derived);
flow(f,[29 149.5;47 149.5],black,'-');
flow(f,[102 149.5;127 149.5],black,'-');

% Key: fills, line styles and color. Each effect line has an arrowhead.
node(ax,[4 160 4 3],{''},state);
txt(ax,10,161.5,'ODE states',black,'left');
node(ax,[39 160 4 3],{''},derived);
txt(ax,45,161.5,'Calculated quantities',black,'left');
flow(f,[88 161.5;98 161.5],black,'-');
txt(ax,101,161.5,'Transfer or DOX effect',black,'left');
flow(f,[4 166;14 166],black,':');
txt(ax,17,166,'EPR input*',black,'left');
flow(f,[74 166;84 166],blue,'-');
txt(ax,87,166,'EA transfer',black,'left');
flow(f,[126 166;136 166],blue,'--');
txt(ax,139,166,'EA modulation',black,'left');
txt(ax,4,171,'*EPR input is not subtracted from the liposomal cohorts.',black,'left');
txt(ax,4,175,'Repeated concentration labels connect pharmacokinetics to pharmacodynamics.',black,'left');
end

function panel(ax,p,str)
rectangle(ax,'Position',p,'EdgeColor',[0.65 0.65 0.65],'LineWidth',0.5);
h = txt(ax,p(1)+3,p(2)+4,str,[0 0 0],'left');
h.FontWeight = 'bold';
end

function node(ax,p,str,fill)
rectangle(ax,'Position',p,'FaceColor',fill,'EdgeColor',[0.25 0.25 0.25], ...
    'LineWidth',0.75,'Curvature',0.08);
txt(ax,p(1)+p(3)/2,p(2)+p(4)/2,str,[0 0 0]);
end

function h = txt(ax,x,y,str,color,align)
if nargin<6, align = 'center'; end
h = text(ax,x,y,str,'FontName','Arial','FontSize',8,'Color',color, ...
    'HorizontalAlignment',align,'VerticalAlignment','middle','Interpreter','tex');
end

function flow(f,points,color,style,both)
if nargin<5, both = false; end
points(:,1) = points(:,1)/178;
points(:,2) = 1-points(:,2)/179;
n = size(points,1);
for k = 1:n-1
    p = points(k:k+1,:);
    kind = 'line';
    if k==n-1, kind = 'arrow'; end
    if both && k==1
        if n==2, kind = 'doublearrow'; else, kind = 'arrow'; p = flipud(p); end
    end
    h = annotation(f,kind,p(:,1).',p(:,2).','Color',color, ...
        'LineWidth',0.75,'LineStyle',style);
    if strcmp(kind,'arrow'), set(h,'HeadLength',3.5,'HeadWidth',3.5); end
    if strcmp(kind,'doublearrow')
        set(h,'Head1Length',3.5,'Head1Width',3.5,'Head2Length',3.5,'Head2Width',3.5);
    end
end
end

function f = draw_exposure(eta,peaks)
f = new_figure('Figure 2 - EA exposure',86,92);
ax = plot_axes(f,[0.24 0.29 0.72 0.67]);
ax.YScale = 'log';
b = bar(ax,1:4,peaks,0.62,'FaceColor','flat','EdgeColor','none','BaseValue',0.1);
b.CData = [0.65 0.65 0.65;0.55 0.72 0.86;0.17 0.46 0.69;0.07 0.28 0.45];
h1 = yline(ax,0.20,'--','Color',[0.10 0.48 0.20],'LineWidth',0.85);
h2 = yline(ax,11.1,'--','Color',[0.75 0.17 0.12],'LineWidth',0.85);
for k = 1:4
    valueLabel = sprintf('%.2f',peaks(k));
    if k==1, valueLabel = sprintf('%.3f',peaks(k)); end
    text(ax,k,peaks(k)*1.18,valueLabel, ...
        'HorizontalAlignment','center','FontName','Arial','FontSize',8,'Color','k');
end
set(ax,'XTick',1:4,'XTickLabel',string(eta),'YTick',[0.1 1 10 100]);
xlim(ax,[0.4 4.6]); ylim(ax,[0.1 100]);
xlabel(ax,'EA exposure multiplier, \eta_{form}');
ylabel(ax,'Effective EA C_{max} (\mug/mL)');
lg = legend(ax,[h1 h2],{'Biomarker EC_{50}: 0.20 \mug/mL', ...
    'EA benchmark: 11.1 \mug/mL'},'FontName','Arial','FontSize',8, ...
    'Box','off','Interpreter','tex','TextColor','k');
set(lg,'Units','normalized','Position',[0.06 0.025 0.93 0.145]);
end

function f = draw_biomarkers(doses,ratio,attenuation,names)
f = new_figure('Figure 3 - Biomarker response',178,90);
axesA = plot_axes(f,[0.075 0.255 0.385 0.67]);
axesB = plot_axes(f,[0.585 0.255 0.385 0.67]);
colors = [0.68 0.08 0.12;0.89 0.42 0.08;0.08 0.38 0.68;0.18 0.53 0.32;0.50 0.21 0.62];
markers = {'o','s','^','d','v'};
linesA = gobjects(5,1);
for j = 1:5
    linesA(j) = plot(axesA,doses,ratio(j,:),'-','Marker',markers{j}, ...
        'Color',colors(j,:),'MarkerFaceColor',colors(j,:),'MarkerSize',3.5,'LineWidth',0.9);
    plot(axesB,doses,attenuation(j,:),'-','Marker',markers{j}, ...
        'Color',colors(j,:),'MarkerFaceColor',colors(j,:),'MarkerSize',3.5,'LineWidth',0.9);
end
yline(axesA,1,'k:','LineWidth',0.75);
for ax = [axesA axesB]
    xlim(ax,[0 400]); set(ax,'XTick',0:100:400);
    xlabel(ax,'Oral EA dose (mg/kg/day)');
end
ylabel(axesA,'Peak concentration / baseline');
ylabel(axesB,'Decrease in peak concentration (%)');
title(axesA,'A  Normalized biomarker peaks','FontSize',8,'FontWeight','bold');
title(axesB,'B  Change relative to PLD alone','FontSize',8,'FontWeight','bold');
lg = legend(axesA,linesA,names,'Orientation','horizontal','FontSize',8, ...
    'FontName','Arial','Box','off','TextColor','k');
set(lg,'Units','normalized','Position',[0.10 0.025 0.82 0.08]);
end

function f = draw_sobol(s)
% Draw every heatmap cell as a vector rectangle, not a raster imagesc object.
f = new_figure('Figure 4 - Sobol total order indices',86,195);
ax = plot_axes(f,[0.295 0.18 0.53 0.755]);
upper = max(0.35,ceil(max(s.ST(:))*20)/20);
lower = min(0,floor(min(s.ST(:))*20)/20);
cmap = flipud(bone(256));
for r = 1:28
    for c = 1:5
        v = s.ST(r,c);
        idx = 1+round(255*(v-lower)/(upper-lower));
        idx = max(1,min(256,idx));
        color = cmap(idx,:);
        rectangle(ax,'Position',[c-0.5 r-0.5 1 1], ...
            'FaceColor',color,'EdgeColor','none');
        txt = [0 0 0];
        if dot(color,[0.2126 0.7152 0.0722])<0.45, txt = [1 1 1]; end
        text(ax,c,r,sprintf('%.2f',v),'HorizontalAlignment','center', ...
            'FontName','Arial','FontSize',8,'Color',txt);
    end
end
set(ax,'YDir','reverse','XLim',[0.5 5.5],'YLim',[0.5 28.5], ...
    'TickLength',[0 0],'YTick',1:28,'YTickLabel',sobol_labels(s.parameter_names), ...
    'XTick',1:5,'XTickLabel',{'Peak C_p','Peak C_{heart}','Peak cTnI', ...
    'Cum ROS excess','AUC_{heart}'},'XTickLabelRotation',60,'TickLabelInterpreter','tex');
colormap(ax,cmap); clim(ax,[lower upper]);
cb = colorbar(ax,'Position',[0.858 0.18 0.025 0.755]);
cb.FontName = 'Arial'; cb.FontSize = 8; cb.Color = 'k';
ax.Position = [0.295 0.18 0.53 0.755];
annotation(f,'textbox',[0.827 0.937 0.09 0.025], ...
    'String','S_T','Interpreter','tex','EdgeColor','none','Margin',0, ...
    'HorizontalAlignment','center','FontName','Arial','FontSize',8,'Color','k');
annotation(f,'textbox',[0.08 0.971 0.88 0.022], ...
    'String',sprintf('Sobol total order sensitivity, N = %d',s.N),'Margin',0,'EdgeColor','none', ...
    'FontName','Arial','FontSize',8,'FontWeight','bold','Color','k', ...
    'HorizontalAlignment','center');
end

function labels = sobol_labels(names)
keys = {'Vp','CLp','kclr_lip','kRES','krel_RES','Ptum','Pheart','kEPR', ...
    'kelim_tum','kelim_heart','kKP','nKP','kprolif','Kmax','kDOXkill','IC50', ...
    'EC50_EA','EEA_pot','ka','K10','k12','k21','kROSgen','kROSclear', ...
    'kROSscav','KM_ROS','ktox_cTnI','krep_cTnI'};
values = {'V_p','CL_p','k_{clr,lip}','k_{RES}','k_{rel,RES}','P_{tum}', ...
    'P_{heart}','k_{EPR}','k_{elim,tum}','k_{elim,heart}','k_{KP}','n', ...
    'k_{prolif}','K_{max}','k_{DOX,kill}','IC_{50}','EC_{50,EA}','E_{EA,pot}', ...
    'k_a','k_{10}','k_{12}','k_{21}','k_{ROS,gen}','k_{ROS,clear}', ...
    'k_{ROS,scav}','K_{M,ROS}','k_{tox,cTnI}','k_{turn,cTnI}'};
[ok,index] = ismember(names,keys);
assert(all(ok) && numel(unique(index))==28,'Unexpected Sobol parameter names.');
labels = values(index);
end

