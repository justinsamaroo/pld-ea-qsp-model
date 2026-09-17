function [t,Y] = qsp_run(p,opt)
% QSP_RUN Simulate the canonical 20-state model with discrete dosing events.

if ~isfield(opt,'dox_on'), opt.dox_on = true; end
if ~isfield(opt,'ea_dose'), opt.ea_dose = 0; end
if ~isfield(opt,'eta_form'), opt.eta_form = 1; end
if ~isfield(opt,'ec50_ea'), opt.ec50_ea = p.EC50_EA; end
if ~isfield(opt,'npts'), opt.npts = 2000; end

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

% Combine a uniform trajectory grid with the same dense grid after every
% scheduled PLD or EA dosing time, whether or not that treatment is active
% in this arm. Using one reporting grid keeps treatment-group arrays aligned
% and prevents peak estimates from depending on the phase of npts.
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
solver_options = odeset('RelTol',1e-7,'AbsTol',1e-10,'MaxStep',4, ...
    'NonNegative',1:19);

for segment = 1:numel(bounds)-1
    t0 = bounds(segment);
    t1 = bounds(segment+1);

    for event_index = find(abs(times-t0)<1e-9)
        if kinds(event_index)==1
            cohort = find(abs(p.DOX_times-t0)<1e-9,1,'first');
            y(cohort) = y(cohort)+p.DOX_dose/(p.Vp*1000);
        else
            y(17) = y(17)+opt.ea_dose;
        end
    end

    te = t(t>=t0 & t<=t1);
    if isempty(te) || te(1)>t0
        te = [t0;te];
    end
    % Integrate to the exact next event even when it is not a reporting time.
    if te(end)<t1
        te = [te;t1];
    end

    [ts,ys] = ode15s(@(tt,yy) qsp_rhs(tt,yy,p,opt.eta_form,opt.ec50_ea,ea_on), ...
        te,y,solver_options);

    [is_output,output_index] = ismember(ts,t);
    Y(output_index(is_output),:) = ys(is_output,:);
    filled(output_index(is_output)) = true;
    y = ys(end,:)';
end

if ~all(filled)
    error('qsp_run:IncompleteOutput','One or more requested output times were not filled.');
end
end
