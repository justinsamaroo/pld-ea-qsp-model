function results = check_tau_floor_sensitivity
% CHECK_TAU_FLOOR_SENSITIVITY Test the KP derivative initialization floor.

p = qsp_parameters();
tau_floors = [1e-4 1e-3 1e-2];
peak_Cp = zeros(size(tau_floors));
peak_Cheart = zeros(size(tau_floors));
AUC_heart = zeros(size(tau_floors));
final_EF = zeros(size(tau_floors));

for index = 1:numel(tau_floors)
    pp = p;
    pp.tau_floor = tau_floors(index);
    [~,states] = qsp_run(pp,struct('ea_dose',0,'npts',2000));
    peak_Cp(index) = max(states(:,6));
    peak_Cheart(index) = max(states(:,9));
    AUC_heart(index) = states(end,20);
    final_EF(index) = qsp_cardiac_function(pp,AUC_heart(index));
end

results = table(tau_floors(:),peak_Cp(:),peak_Cheart(:),AUC_heart(:),final_EF(:), ...
    'VariableNames',{'tau_floor_h','peak_Cp','peak_Cheart','AUC_heart','final_EF'});
disp(results);
writetable(results,'tau_floor_sensitivity.csv');
save('tau_floor_sensitivity.mat','results');
end

