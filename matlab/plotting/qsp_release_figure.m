function [fig,data] = qsp_release_figure(p)
% QSP_RELEASE_FIGURE Compare nominal KP release with the implemented law.
% Release is the only loss process in this single-cohort calculation.
% H is the exact integral of the coefficient with the cohort-age floor.
tau = unique([0;logspace(-6,log10(168),1600)';linspace(0,168,500)']);
tf = p.tau_floor;
H = p.kKP*(max(tau,tf).^p.nKP+(p.nKP-1)*tf^p.nKP);
early = tau<tf;
H(early) = p.kKP*p.nKP*tf^(p.nKP-1)*tau(early);
nominal = p.kKP*tau.^p.nKP;
released = -expm1(-H);
rate_age = logspace(log10(tf),log10(168),1200)';
rate = p.kKP*p.nKP*max(rate_age,tf).^(p.nKP-1);
data = struct('tau_h',tau,'nominal_fraction',nominal, ...
    'ODE_fraction_regularized',released,'coefficient_age_h',rate_age, ...
    'coefficient_per_h',rate,'kKP',p.kKP,'nKP',p.nKP,'tau_floor_h',tf);

fig = figure('Name','Figure S2 - Release comparison','NumberTitle','off', ...
    'Color','w','Units','centimeters','Position',[2 2 17.8 8]);
if isprop(fig,'Theme'), fig.Theme = 'light'; end
layout = tiledlayout(fig,1,3,'Padding','compact','TileSpacing','compact');
ax = nexttile(layout); hold(ax,'on');
plot(ax,tau,nominal,'k-','LineWidth',1);
plot(ax,tau,released,'--','Color',[0.18 0.46 0.71],'LineWidth',1);
xlim(ax,[0 168]); ylim(ax,[0 .65]);
xlabel(ax,'Cohort age (h)'); ylabel(ax,'Fraction');
title(ax,'A  Release comparison','FontSize',8);
legend(ax,{'Nominal KP law','ODE, release only'},'Location','northwest', ...
    'FontSize',8,'Box','off');
ax = nexttile(layout);
plot(ax,rate_age,rate,'k-','LineWidth',1);
xlim(ax,[0 168]); xlabel(ax,'Cohort age (h)');
ylabel(ax,'k_{rel} (h^{-1})'); title(ax,'B  Release coefficient','FontSize',8);
ax = nexttile(layout);
loglog(ax,rate_age,rate,'k-','LineWidth',1);
xlim(ax,[tf 168]); xlabel(ax,'Cohort age (h)');
ylabel(ax,'k_{rel} (h^{-1})'); title(ax,'C  Coefficient (log-log)','FontSize',8);
set(findall(fig,'Type','axes'),'FontName','Arial','FontSize',8, ...
    'LineWidth',.75,'Box','on','TitleFontSizeMultiplier',1, ...
    'LabelFontSizeMultiplier',1);
end
