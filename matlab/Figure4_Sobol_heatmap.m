function Figure4_Sobol_heatmap(N)
% FIGURE4_SOBOL_HEATMAP Sobol sensitivity analysis for Figure 4.
% The publication run uses N = 1024 and 30,720 model evaluations.

if nargin<1, N = 1024; end
close all;
seed = 1;
rng(seed,'twister');

p = qsp_parameters();
parameter_names = p.sobol_names;
nominal = p.sobol_nom;
n_parameters = numel(nominal);
lower = nominal*0.8;
upper = nominal*1.2;

A = lower+rand(N,n_parameters).*(upper-lower);
B = lower+rand(N,n_parameters).*(upper-lower);

fprintf('Evaluating base matrices A and B (%d runs each)...\n',N);
YA = evaluate_block(A,p,parameter_names);
YB = evaluate_block(B,p,parameter_names);
n_outputs = size(YA,2);
variance = var([YA;YB],0,1);

S1 = zeros(n_parameters,n_outputs);
ST = zeros(n_parameters,n_outputs);
YAB_all = zeros(N,n_outputs,n_parameters);
for parameter = 1:n_parameters
    AB = A;
    AB(:,parameter) = B(:,parameter);
    YAB = evaluate_block(AB,p,parameter_names);
    YAB_all(:,:,parameter) = YAB;
    for output = 1:n_outputs
        if variance(output)>0
            S1(parameter,output) = mean(YB(:,output).*(YAB(:,output)-YA(:,output))) ...
                /variance(output);
            ST(parameter,output) = mean((YA(:,output)-YAB(:,output)).^2) ...
                /(2*variance(output));
        else
            S1(parameter,output) = NaN;
            ST(parameter,output) = NaN;
        end
    end
    fprintf('  parameter %2d/%d (%s) done\n',parameter,n_parameters, ...
        parameter_names{parameter});
end

outputs = {'Peak C_p','Peak C_{heart}','Peak cTnI','Cum ROS excess','AUC_{heart}'};
matlab_version = version;
save('Figure4_sobol.mat','ST','S1','parameter_names','outputs','N','seed', ...
    'nominal','lower','upper','matlab_version','A','B','YA','YB', ...
    'YAB_all','variance','p');

data = struct('ST',ST,'N',N,'parameter_names',{parameter_names});
fig = qsp_main_figure(4,data);
qsp_export_figure(fig,pwd,'Figure4',86,195,false);
[~,top_parameter] = max(mean(ST,2,'omitnan'));
fprintf('Saved Figure4.pdf and Figure4_sobol.mat | top mean ST: %s\n', ...
    parameter_names{top_parameter});
end

function outputs = evaluate_block(X,p,parameter_names)
n = size(X,1);
outputs = zeros(n,5);
for row = 1:n
    pp = apply_parameter_vector(p,parameter_names,X(row,:));
    opt = struct('ea_dose',50000,'eta_form',1,'ec50_ea',pp.EC50_EA,'npts',1000);
    [time,states] = qsp_run(pp,opt);
    excess_ROS = max(states(:,16)-pp.ROSss,0);
    outputs(row,:) = [max(states(:,6)),max(states(:,9)),max(states(:,11)), ...
        trapz(time,excess_ROS),states(end,20)];
end
end

function pp = apply_parameter_vector(p,parameter_names,values)
pp = p;
for parameter = 1:numel(parameter_names)
    switch parameter_names{parameter}
        case 'ktox_cTnI'
            pp.ktox(1) = values(parameter);
        case 'krep_cTnI'
            pp.krep(1) = values(parameter);
        otherwise
            pp.(parameter_names{parameter}) = values(parameter);
    end
end
pp.kROSbasal = pp.kROSclear*pp.ROSss;
end

