function FigureS10_benchmark_sweep
% FIGURES10_BENCHMARK_SWEEP
% Supplementary Figure S10. Sensitivity sweep of the EA-alone
% antiproliferative benchmark used in the assumed doxorubicin-effect modifier.

clear; close all;
p = qsp_parameters();

benchmark_sweep = [5 11.1 20 50];
eta_form_levels = [25 50];
ea_high = 200*0.25*1000;
colors = lines(numel(benchmark_sweep));

nE = numel(benchmark_sweep);
trajectories = cell(2,nE);
peak_cTnI = zeros(2,nE);
peak_cTnT = zeros(2,nE);
peak_NTproBNP = zeros(2,nE);
time_to_threshold = zeros(2,nE);
tgrid = [];

for eta_index = 1:2
    for benchmark_index = 1:nE
        opt = struct('ea_dose',ea_high,'eta_form',eta_form_levels(eta_index), ...
            'ec50_ea',benchmark_sweep(benchmark_index),'npts',1500);
        [t,states] = qsp_run(p,opt);
        tgrid = t;
        trajectories{eta_index,benchmark_index} = states(:,10);
        peak_cTnI(eta_index,benchmark_index) = max(states(:,11));
        peak_cTnT(eta_index,benchmark_index) = max(states(:,12));
        peak_NTproBNP(eta_index,benchmark_index) = max(states(:,13));
        threshold_index = find(states(:,10)<=1e4,1);
        if isempty(threshold_index)
            time_to_threshold(eta_index,benchmark_index) = NaN;
        else
            time_to_threshold(eta_index,benchmark_index) = t(threshold_index)/24;
        end
    end
end
days = tgrid/24;

fig = figure('Color','w','Units','centimeters','Position',[1 1 17.8 19]);
layout = tiledlayout(fig,3,2,'TileSpacing','compact','Padding','compact');

for eta_index = 1:2
    ax = nexttile(layout); hold(ax,'on'); box(ax,'on');
    for benchmark_index = 1:nE
        plot(ax,days,trajectories{eta_index,benchmark_index}, ...
            'Color',colors(benchmark_index,:),'LineWidth',1.0);
    end
    yline(ax,1e4,'k:','LineWidth',0.75);
    set(ax,'YScale','log','FontName','Arial','FontSize',8,'LineWidth',0.75);
    xlim(ax,[0 15]); ylim(ax,[1e3 2e6]);
    xlabel(ax,'Time (days)'); ylabel(ax,'Viable tumor cells (cells/mL)');
    title(ax,sprintf('%c  Tumor response (\\eta_{form} = %d)', ...
        'A'+eta_index-1,eta_form_levels(eta_index)),'FontSize',9);
    if eta_index==2
        legend(ax,arrayfun(@(x)sprintf('EA benchmark = %.1f',x), ...
            benchmark_sweep,'UniformOutput',false),'Location','northeast', ...
            'FontSize',6.5,'Box','off');
    end
end

plot_endpoint(nexttile(layout),benchmark_sweep,peak_cTnI, ...
    'C  Peak cTnI','Peak cTnI (ng/mL)',eta_form_levels);
plot_endpoint(nexttile(layout),benchmark_sweep,peak_cTnT, ...
    'D  Peak cTnT','Peak cTnT (ng/mL)',eta_form_levels);
plot_endpoint(nexttile(layout),benchmark_sweep,peak_NTproBNP, ...
    'E  Peak NT-proBNP','Peak NT-proBNP (ng/mL)',eta_form_levels);

axF = nexttile(layout); hold(axF,'on'); box(axF,'on');
plot(axF,benchmark_sweep,time_to_threshold(1,:),'-o','Color',[0.20 0.46 0.71], ...
    'LineWidth',1.1,'MarkerFaceColor',[0.20 0.46 0.71]);
plot(axF,benchmark_sweep,time_to_threshold(2,:),'-s','Color',[0.12 0.31 0.49], ...
    'LineWidth',1.1,'MarkerFaceColor',[0.12 0.31 0.49]);
set(axF,'FontName','Arial','FontSize',8,'LineWidth',0.75);
xlabel(axF,'EA-alone benchmark (\mug/mL)');
ylabel(axF,'Time to 10^4 cells/mL (days)');
title(axF,'F  Tumor time-to-threshold','FontSize',9);
legend(axF,{'\eta_{form} = 25','\eta_{form} = 50'}, ...
    'Location','southeast','FontSize',7,'Box','off');

exportgraphics(fig,'FigureS10.pdf','ContentType','vector','BackgroundColor','white');
save('FigureS10_benchmark_results.mat','benchmark_sweep','eta_form_levels', ...
    'peak_cTnI','peak_cTnT','peak_NTproBNP','time_to_threshold');
fprintf('Saved FigureS10.pdf and FigureS10_benchmark_results.mat\n');
fprintf('Time-to-1e4, eta_form 25: %s days\n',mat2str(round(time_to_threshold(1,:),2)));
fprintf('Time-to-1e4, eta_form 50: %s days\n',mat2str(round(time_to_threshold(2,:),2)));
end

function plot_endpoint(ax,x,Y,ttl,ylab,eta_form)
hold(ax,'on'); box(ax,'on');
plot(ax,x,Y(1,:),'-o','Color',[0.20 0.46 0.71],'LineWidth',1.1, ...
    'MarkerFaceColor',[0.20 0.46 0.71]);
plot(ax,x,Y(2,:),'-s','Color',[0.12 0.31 0.49],'LineWidth',1.1, ...
    'MarkerFaceColor',[0.12 0.31 0.49]);
set(ax,'FontName','Arial','FontSize',8,'LineWidth',0.75);
xlabel(ax,'EA-alone benchmark (\mug/mL)'); ylabel(ax,ylab); title(ax,ttl,'FontSize',9);
mean_value = mean(Y(:));
if mean_value>0, ylim(ax,[0 1.6*mean_value]); end
legend(ax,{sprintf('\\eta_{form} = %d',eta_form(1)), ...
    sprintf('\\eta_{form} = %d',eta_form(2))}, ...
    'Location','best','FontSize',7,'Box','off');
end
