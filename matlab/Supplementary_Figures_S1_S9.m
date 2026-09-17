function Supplementary_Figures_S1_S9
% SUPPLEMENTARY_FIGURES_S1_S9
% Generates Supplementary Figures S1-S9 as tightly cropped vector PDFs.
% 20-state MATLAB ODE model with ka = 14.52 h^-1.
% Add the complete matlab folder to the path for the shared plotting helpers.
% SimBiology is not required.

clear;
close all;

p = params();
mg = 250;  % mg/kg -> ug for a 250 g rat

% Treatment-group simulations
[t,Yc] = qsp_run(p,struct( ...
    'ea_dose',0, ...
    'dox_on',false, ...
    'npts',2000));

[~,Yd] = qsp_run(p,struct( ...
    'ea_dose',0, ...
    'npts',2000));

[~,Yl] = qsp_run(p,struct( ...
    'ea_dose',100*mg, ...
    'npts',2000));

[~,Yh] = qsp_run(p,struct( ...
    'ea_dose',200*mg, ...
    'npts',2000));

td = t/24;

G = {Yc,Yd,Yl,Yh};

gname = { ...
    'Control', ...
    'PLD alone', ...
    'PLD + EA 100 mg/kg', ...
    'PLD + EA 200 mg/kg'};

gc = [ ...
    0.50 0.50 0.50
    0.93 0.49 0.19
    0.18 0.55 0.55
    0.49 0.18 0.56];


%% S1: PLD PK profiles

f = figure( ...
    'Color','w', ...
    'Units','centimeters', ...
    'Position',[1 1 17.8 13]);

tl = tiledlayout(f,2,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');

ax = nexttile(tl);
plot(ax,td,Yd(:,6),'k','LineWidth',1.1);
style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'Free DOX C_p (\mug/mL)');
title(ax,'A  Free DOX plasma');

ax = nexttile(tl);
plot(ax,td,sum(Yd(:,1:5),2), ...
    'Color',[0.18 0.46 0.71], ...
    'LineWidth',1.1);
style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'Liposomal DOX (\mug/mL)');
title(ax,'B  Total liposomal DOX');

ax = nexttile(tl);
plot(ax,td,Yd(:,8),'r','LineWidth',1.1);
style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'Tumor DOX (\mug/mL)');
title(ax,'C  Tumor DOX');

ax = nexttile(tl);
plot(ax,td,Yd(:,9), ...
    'Color',[0.18 0.46 0.71], ...
    'LineWidth',1.1);
style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'Cardiac DOX (\mug/mL)');
title(ax,'D  Cardiac DOX');

export_figure(f,'FigureS1.pdf');


%% S2: Nominal KP release and the release-only ODE implementation
[f,release] = qsp_release_figure(p);
qsp_export_figure(f,pwd,'FigureS2',178,80,false);
save('FigureS2_release_results.mat','-struct','release');

%% S3: Tumor, cTnI, EF and FS

f = figure( ...
    'Color','w', ...
    'Units','centimeters', ...
    'Position',[1 1 17.8 13]);

tl = tiledlayout(f,2,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');

ax = nexttile(tl);
hold(ax,'on');

for g = 1:4
    plot(ax,td,G{g}(:,10), ...
        'Color',gc(g,:), ...
        'LineWidth',1);
end

set(ax,'YScale','log');
style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'Viable tumor cells (cells/mL)');
title(ax,'A  Tumor dynamics');

legend(ax,gname, ...
    'FontSize',6.5, ...
    'Location','southwest', ...
    'Box','off');

ax = nexttile(tl);
hold(ax,'on');

for g = 2:4
    plot(ax,td,G{g}(:,11), ...
        'Color',gc(g,:), ...
        'LineWidth',1);
end

style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'cTnI (ng/mL)');
title(ax,'B  Cardiac troponin I');

ax = nexttile(tl);
hold(ax,'on');

for g = 2:4
    EF = qsp_efs(p,G{g}(:,20));
    plot(ax,td,EF, ...
        'Color',gc(g,:), ...
        'LineWidth',1);
end

yline(ax,50,'k:');
style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'EF (%)');
title(ax,'C  Ejection fraction');

ax = nexttile(tl);
hold(ax,'on');

for g = 2:4
    [~,FS] = qsp_efs(p,G{g}(:,20));
    plot(ax,td,FS, ...
        'Color',gc(g,:), ...
        'LineWidth',1);
end

yline(ax,25,'k:');
style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'FS (%)');
title(ax,'D  Fractional shortening');

export_figure(f,'FigureS3.pdf');


%% S4: ROS concentration and cumulative burden

f = figure( ...
    'Color','w', ...
    'Units','centimeters', ...
    'Position',[1 1 17.8 6.8]);

tl = tiledlayout(f,1,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');

ax = nexttile(tl);
hold(ax,'on');

for g = 1:4
    plot(ax,td,G{g}(:,16), ...
        'Color',gc(g,:), ...
        'LineWidth',1);
end

style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'ROS (\muM)');
title(ax,'A  Cardiac ROS concentration');

legend(ax,gname, ...
    'FontSize',6.5, ...
    'Box','off');

ax = nexttile(tl);
hold(ax,'on');

for g = 1:4
    b = cumtrapz(t,max(G{g}(:,16)-p.ROSss,0));

    plot(ax,td,b, ...
        'Color',gc(g,:), ...
        'LineWidth',1);
end

style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'Cumulative ROS excess (\muM\cdoth)');
title(ax,'B  Oxidative stress burden');

export_figure(f,'FigureS4.pdf');


%% S5: EA plasma PK

f = figure( ...
    'Color','w', ...
    'Units','centimeters', ...
    'Position',[1 1 12 8]);

ax = axes(f);
hold(ax,'on');

plot(ax,td,Yh(:,18), ...
    'Color',[0.49 0.18 0.56], ...
    'LineWidth',1.2);

plot(ax,td,Yl(:,18), ...
    'Color',[0.18 0.55 0.55], ...
    'LineWidth',1.2);

style(ax);
xlabel(ax,'Time (days)');
ylabel(ax,'EA plasma concentration (\mug/mL)');

legend(ax,{ ...
    sprintf('200 mg/kg (C_{max}=%.3f)',max(Yh(:,18))), ...
    sprintf('100 mg/kg (C_{max}=%.3f)',max(Yl(:,18)))}, ...
    'Box','off', ...
    'FontSize',8);

title(ax, ...
    'Ellagic acid plasma pharmacokinetics (k_a = 14.52 h^{-1})', ...
    'FontSize',9);

export_figure(f,'FigureS5.pdf');


%% S6-S9: Virtual population

fprintf('Running 200-rat virtual population (S6-S9)...\n');

population_seed = 12345;
P = population(p,200,population_seed);
pe = @(x,q) local_pctl(x,q);

save('FigureS6_S9_population.mat','P','population_seed');

fprintf('EA plasma Cmax: 100 mg/kg %.3f | 200 mg/kg %.3f ug/mL\n', ...
    max(Yl(:,18)),max(Yh(:,18)));
fprintf('Peak free plasma DOX %.3f | tumor DOX %.3f | cardiac DOX %.4f ug/mL\n', ...
    max(Yd(:,6)),max(Yd(:,8)),max(Yd(:,9)));
fprintf('Cumulative cardiac exposure %.3f ug*h/mL\n',Yd(end,20));
fprintf('Population seed %d | N %d\n',population_seed,numel(P.FinalEF));
fprintf('Peak Cp median %.3f | 90%% PI %.3f-%.3f ug/mL\n', ...
    median(P.PeakCp),pe(P.PeakCp,5),pe(P.PeakCp,95));
fprintf('Final EF median %.3f | 90%% PI %.3f-%.3f percent\n', ...
    median(P.FinalEF),pe(P.FinalEF,5),pe(P.FinalEF,95));


%% S6: Peak Cp

f = figure( ...
    'Color','w', ...
    'Units','centimeters', ...
    'Position',[1 1 11 8]);

ax = axes(f);

histogram(ax,P.PeakCp,25, ...
    'FaceColor',[0.18 0.46 0.71]);

hold(ax,'on');

xline(ax,median(P.PeakCp), ...
    'r-','LineWidth',1.3);

xline(ax,pe(P.PeakCp,5),'k--');
xline(ax,pe(P.PeakCp,95),'k--');

style(ax);
xlabel(ax,'Peak C_p (\mug/mL)');
ylabel(ax,'Count');

title(ax,sprintf( ...
    'Peak C_p: median %.2f, 90%% PI %.2f-%.2f (CV %.1f%%)', ...
    median(P.PeakCp), ...
    pe(P.PeakCp,5), ...
    pe(P.PeakCp,95), ...
    100*std(P.PeakCp)/mean(P.PeakCp)), ...
    'FontSize',8.5);

export_figure(f,'FigureS6.pdf');


%% S7: Heart DOX and Pheart correlation

jPh = find(strcmp(P.names,'Pheart'));

f = figure( ...
    'Color','w', ...
    'Units','centimeters', ...
    'Position',[1 1 17.8 7]);

tl = tiledlayout(f,1,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');

ax = nexttile(tl);

histogram(ax,P.PeakCheart,25, ...
    'FaceColor',[0.18 0.46 0.71]);

hold(ax,'on');

xline(ax,median(P.PeakCheart), ...
    'r-','LineWidth',1.3);

style(ax);
xlabel(ax,'Peak C_{heart} (\mug/mL)');
ylabel(ax,'Count');
title(ax,'A  Heart DOX distribution');

ax = nexttile(tl);

scatter(ax, ...
    P.theta(:,jPh), ...
    P.PeakCheart, ...
    12,'filled');

hold(ax,'on');

local_fitline( ...
    ax, ...
    P.theta(:,jPh), ...
    P.PeakCheart');

style(ax);
xlabel(ax,'P_{heart} (h^{-1})');
ylabel(ax,'Peak C_{heart} (\mug/mL)');

title(ax,sprintf( ...
    'B  P_{heart} vs Peak C_{heart} (r = %.2f)', ...
    local_corr(P.theta(:,jPh),P.PeakCheart')));

export_figure(f,'FigureS7.pdf');


%% S8: Peak ROS and the ROS generation coefficient
f = qsp_ros_population_figure(P);
qsp_export_figure(f,pwd,'FigureS8',178,80,false);

%% S9: EF distribution

f = figure( ...
    'Color','w', ...
    'Units','centimeters', ...
    'Position',[1 1 11 8]);

ax = axes(f);

histogram(ax,P.FinalEF,25, ...
    'FaceColor',[0.49 0.18 0.56]);

hold(ax,'on');

xline(ax,50, ...
    'k--','LineWidth',1.3);

xline(ax,median(P.FinalEF), ...
    'r-','LineWidth',1.3);

style(ax);
xlabel(ax,'Final EF (%)');
ylabel(ax,'Count');

title(ax,sprintf( ...
    'Final EF: median %.1f, 90%% PI %.1f-%.1f', ...
    median(P.FinalEF), ...
    pe(P.FinalEF,5), ...
    pe(P.FinalEF,95)), ...
    'FontSize',8.5);

export_figure(f,'FigureS9.pdf');

fprintf('Saved FigureS1.pdf ... FigureS9.pdf\n');

end


%% Helper functions

function style(ax)

set(ax, ...
    'FontName','Arial', ...
    'FontSize',8, ...
    'LineWidth',0.75, ...
    'Box','on');

end


function export_figure(f,name)
% Export the figure itself, tightly cropped, at its specified width.

drawnow;

oldUnits = f.Units;
f.Units = 'centimeters';

widthCm = f.Position(3);

f.Units = oldUnits;

exportgraphics(f,name, ...
    'ContentType','vector', ...
    'BackgroundColor','white', ...
    'Units','centimeters', ...
    'Width',widthCm, ...
    'Padding','tight');

end


function P = population(p,Nrats,seed)

rng(seed,'twister');

specs = { ...
    'CLp',p.CLp,0.20
    'Vp',p.Vp,0.20
    'kKP',p.kKP,0.25
    'nKP',p.nKP,0.15
    'Pheart',p.Pheart,0.40
    'kelim_heart',p.kelim_heart,0.30
    'kROSgen',p.kROSgen,0.40
    'kROSclear',p.kROSclear,0.25
    'ktox_cTnI',p.ktox(1),0.30
    'krep_cTnI',p.krep(1),0.30};

np = size(specs,1);

P.names = specs(:,1)';
P.PeakCp = zeros(1,Nrats);
P.PeakCheart = zeros(1,Nrats);
P.PeakROS = zeros(1,Nrats);
P.FinalEF = zeros(1,Nrats);
P.theta = zeros(Nrats,np);
P.seed = seed;
P.Nrats = Nrats;
P.matlab_version = version;

for r = 1:Nrats

    pp = p;

    for j = 1:np

        m = specs{j,2};
        cv = specs{j,3};

        s = sqrt(log(1+cv^2));
        mu = log(m)-s^2/2;
        val = exp(mu+s*randn);

        P.theta(r,j) = val;

        switch specs{j,1}

            case 'ktox_cTnI'
                pp.ktox(1) = val;

            case 'krep_cTnI'
                pp.krep(1) = val;

            otherwise
                pp.(specs{j,1}) = val;

        end

    end

    pp.kROSbasal = pp.kROSclear*pp.ROSss;

    [~,S] = qsp_run(pp,struct( ...
        'ea_dose',0, ...
        'npts',1200));

    P.PeakCp(r) = max(S(:,6));
    P.PeakCheart(r) = max(S(:,9));
    P.PeakROS(r) = max(S(:,16));
    P.FinalEF(r) = qsp_efs(pp,S(end,20));

end

end


function q = local_pctl(x,pct)

x = sort(x(:));
n = numel(x);

if n == 1
    q = x;
    return;
end

pos = min(max(pct/100*n+0.5,1),n);

lo = floor(pos);
hi = ceil(pos);

if lo == hi
    q = x(lo);
else
    q = x(lo)+(pos-lo)*(x(hi)-x(lo));
end

end


function r = local_corr(a,b)

a = a(:);
b = b(:);

c = corrcoef(a,b);
r = c(1,2);

end


function local_fitline(ax,x,y)

x = x(:);
y = y(:);

c = polyfit(x,y,1);
xx = linspace(min(x),max(x),50);

plot(ax, ...
    xx, ...
    polyval(c,xx), ...
    'r-', ...
    'LineWidth',1.2);

end


%% Model functions

function [EF,FS] = qsp_efs(p,AUC)

g = p.gamma;

EF = p.EF_base ...
    -(p.EF_base-p.EF_nadir).*AUC.^g ...
    ./(p.AUC50_EF^g+AUC.^g);

FS = p.FS_base ...
    -(p.FS_base-p.FS_nadir).*AUC.^g ...
    ./(p.AUC50_FS^g+AUC.^g);

end


function p = params()

p.Vp = 0.0097;
p.CLp = 0.0005;
p.kclr_lip = 0.029;
p.kRES = 0.013;
p.krel_RES = 0.010;

p.Ptum = 0.003;
p.Pheart = 0.0005;
p.kelim_tum = 0.007;
p.kelim_heart = 0.019;
p.kEPR = 0.005;

p.kKP = 0.06;
p.nKP = 0.43;
p.tau_floor = 1e-3;  % h, regularizes the KP derivative at cohort age zero

p.kprolif = 0.0231;
p.Kmax = 1e8;
p.kDOXkill = 0.075;
p.IC50 = 0.065;
p.EEA_pot = 1.0;
p.EC50_EA = 11.1;

p.Bss = [0.005 0.010 0.050 1.000 0.300];

p.ktox = [0.52 1.25 3.33 3.78 2.22]/24;
p.krep = [20.8 16.6 33.3 30.2 5.5]/24;

p.EEA_j = [1.5 1.5 1.0 1.2 1.0];
p.EC50_j = [0.20 0.20 0.20 0.20 0.15];

p.kROSgen = 0.15;
p.kROSclear = 1.0;
p.kROSscav = 0.5;
p.KM_ROS = 10;
p.ROSss = 1.0;
p.kROSbasal = 1.0;

p.K10 = 0.54;
p.k12 = 1.90;
p.k21 = 0.47;
p.F = 0.01;
p.ka = 14.52;
p.VEA_p = 506.611;

p.EF_base = 75;
p.EF_nadir = 45;
p.FS_base = 40;
p.FS_nadir = 20;
p.gamma = 2;
p.AUC50_EF = 15;
p.AUC50_FS = 12;

p.DOX_dose = 937.5;
p.DOX_times = (0:4)*168;
p.EA_times = (0:34)*24;
p.TEND = 42*24;

end


function [t,Y] = qsp_run(p,opt)

if ~isfield(opt,'dox_on')
    opt.dox_on = true;
end

if ~isfield(opt,'eta_form')
    opt.eta_form = 1;
end

if ~isfield(opt,'ec50_ea')
    opt.ec50_ea = p.EC50_EA;
end

ea_on = opt.ea_dose > 0;

y = zeros(20,1);
y(10) = 1e6;
y(11:15) = p.Bss(:);
y(16) = p.ROSss;

times = [];
kinds = [];

if opt.dox_on
    times = [times p.DOX_times];
    kinds = [kinds ones(1,numel(p.DOX_times))];
end

if ea_on
    times = [times p.EA_times];
    kinds = [kinds 2*ones(1,numel(p.EA_times))];
end

[times,ix] = sort(times);
kinds = kinds(ix);

% Use the same reporting grid in every treatment arm. Dense samples are
% included after all scheduled PLD and EA times even when a treatment is off.
base_t = linspace(0,p.TEND,opt.npts)';
event_offsets = unique([0 p.tau_floor 0.001 0.005 0.01 0.02 0.05 ...
    0.10 0.12 0.14 0.15 0.16 0.18 0.20 0.25 0.50 1 2 4]);
sample_times = unique([p.DOX_times p.EA_times]);
event_t = [];
for event_index = 1:numel(sample_times)
    candidate = sample_times(event_index)+event_offsets;
    event_t = [event_t candidate(candidate<=p.TEND)]; %#ok<AGROW>
end
t = unique([base_t;event_t(:)]);
Y = zeros(numel(t),20);
filled = false(numel(t),1);

bounds = unique([0 times p.TEND]);

o = odeset( ...
    'RelTol',1e-7, ...
    'AbsTol',1e-10, ...
    'MaxStep',4, ...
    'NonNegative',1:19);

for s = 1:numel(bounds)-1

    t0 = bounds(s);
    t1 = bounds(s+1);

    for k = find(abs(times-t0)<1e-9)

        if kinds(k) == 1

            cohort = find(abs(p.DOX_times-t0)<1e-9,1,'first');

            y(cohort) = y(cohort) ...
                +p.DOX_dose/(p.Vp*1000);

        else
            y(17) = y(17)+opt.ea_dose;
        end

    end

    te = t(t>=t0 & t<=t1);

    if isempty(te) || te(1)>t0
        te = [t0;te];
    end

    % Always integrate to the exact next event boundary. The reporting grid
    % usually does not contain t1, so omitting it skips dynamics before a dose.
    if te(end)<t1
        te = [te;t1];
    end

    [ts,ys] = ode15s( ...
        @(tt,yy) qsp_rhs( ...
            tt,yy,p,opt.eta_form,opt.ec50_ea,ea_on), ...
        te, ...
        y, ...
        o);

    [is_output,output_index] = ismember(ts,t);
    Y(output_index(is_output),:) = ys(is_output,:);
    filled(output_index(is_output)) = true;

    y = ys(end,:)';

end

if ~all(filled)
    error('qsp_run:IncompleteOutput','One or more requested output times were not filled.');
end

end


function dy = qsp_rhs(tt,y,p,eta_form,ec50_ea,ea_on)
% Complete right-hand side for the 20-state QSP model.
%
% States:
%  1:5   Liposomal DOX cohorts
%  6     Free DOX plasma
%  7     RES DOX
%  8     Tumor DOX
%  9     Cardiac DOX
%  10    Viable tumor cells
%  11:15 Cardiac biomarkers
%  16    Cardiac ROS
%  17    EA gastrointestinal depot
%  18    EA plasma
%  19    EA peripheral tissue
%  20    Cumulative cardiac DOX exposure

dy = zeros(20,1);

Clip = max(y(1:5),0);
Cp = max(y(6),0);
CRES = max(y(7),0);
Ctum = max(y(8),0);
Cheart = max(y(9),0);
Cell = max(y(10),0);
B = max(y(11:15),0);
ROS = max(y(16),0);
AGI = max(y(17),0);
CEA_p = max(y(18),0);
CEA_t = max(y(19),0);


% Cohort-specific Korsmeyer-Peppas release

tau = tt-p.DOX_times(:);
active = tau>0;
tau_safe = max(tau,p.tau_floor);

krel = zeros(5,1);

krel(active) = p.kKP*p.nKP ...
    .*tau_safe(active).^(p.nKP-1);

release_total = sum(krel.*Clip);
total_lip = sum(Clip);


% PLD/free-DOX pharmacokinetics

dy(1:5) = -krel.*Clip ...
    -p.kclr_lip.*Clip;

dy(6) = -(p.CLp/p.Vp)*Cp ...
    +release_total ...
    -p.kRES*Cp ...
    -p.Ptum*(Cp-Ctum) ...
    -p.Pheart*(Cp-Cheart);

% Despite its historical name, krel_RES is implemented as an untracked
% first-order loss from the RES. No matching return flux enters plasma.
dy(7) = p.kRES*Cp ...
    +p.kclr_lip*total_lip ...
    -p.krel_RES*CRES;

% The EPR input is not subtracted from the liposomal cohorts. The manuscript
% identifies this concentration-transfer approximation as a limitation.
dy(8) = p.Ptum*(Cp-Ctum) ...
    +p.kEPR*total_lip ...
    -p.kelim_tum*Ctum;

dy(9) = p.Pheart*(Cp-Cheart) ...
    -p.kelim_heart*Cheart;


% Pharmacologically available plasma EA exposure

if ea_on
    CEA_eff = eta_form*CEA_p;
else
    CEA_eff = 0;
end


% Tumor pharmacodynamics

kill_rate = p.kDOXkill ...
    *(1+p.EEA_pot*CEA_eff/(ec50_ea+CEA_eff));

dy(10) = p.kprolif*Cell ...
    *(1-Cell/p.Kmax) ...
    -kill_rate*Ctum*Cell/(p.IC50+Ctum);


% Cardiac biomarker dynamics

kin = p.krep(:).*p.Bss(:);

krep_eff = p.krep(:) ...
    .*(1+p.EEA_j(:).*CEA_eff ...
    ./(p.EC50_j(:)+CEA_eff));

dy(11:15) = kin ...
    +p.ktox(:)*Cheart ...
    -krep_eff.*B;


% Cardiac ROS
% EA affects only the scavenging term.

dy(16) = p.kROSbasal ...
    +p.kROSgen*Cheart ...
    -p.kROSclear*ROS ...
    -p.kROSscav*CEA_eff*ROS ...
    /(p.KM_ROS+ROS);


% Ellagic-acid pharmacokinetics

dy(17) = -p.ka*AGI;

dy(18) = p.ka*p.F*AGI/p.VEA_p ...
    -p.K10*CEA_p ...
    -p.k12*CEA_p ...
    +p.k21*CEA_t;

dy(19) = p.k12*CEA_p ...
    -p.k21*CEA_t;


% Cumulative cardiac DOX exposure

dy(20) = Cheart;

end
