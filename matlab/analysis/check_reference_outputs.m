function results = check_reference_outputs
% CHECK_REFERENCE_OUTPUTS Recompute the scalar outputs cited in the manuscript.

p = qsp_parameters();
dose_scale = 250;

[t_pld,S_pld] = qsp_run(p,struct('ea_dose',0,'npts',2000));
[t_low,S_low] = qsp_run(p,struct('ea_dose',100*dose_scale,'npts',2000));
[t_high,S_high] = qsp_run(p,struct('ea_dose',200*dose_scale,'npts',2000));

results.EA_Cmax_low = max(S_low(:,18));
results.EA_Cmax_high = max(S_high(:,18));
results.Cp_peak = [max(S_pld(:,6)) max(S_low(:,6)) max(S_high(:,6))];
results.Ctum_peak = [max(S_pld(:,8)) max(S_low(:,8)) max(S_high(:,8))];
results.Cheart_peak = [max(S_pld(:,9)) max(S_low(:,9)) max(S_high(:,9))];
results.AUCheart = [S_pld(end,20) S_low(end,20) S_high(end,20)];

results.cTnI_peak = [max(S_pld(:,11)) max(S_low(:,11)) max(S_high(:,11))];
results.cTnT_peak = [max(S_pld(:,12)) max(S_low(:,12)) max(S_high(:,12))];
results.cTnI_attenuation = 100*(results.cTnI_peak(1)-results.cTnI_peak(2:3)) ...
    /results.cTnI_peak(1);
results.cTnT_attenuation = 100*(results.cTnT_peak(1)-results.cTnT_peak(2:3)) ...
    /results.cTnT_peak(1);

burden_pld = trapz(t_pld,max(S_pld(:,16)-p.ROSss,0));
burden_low = trapz(t_low,max(S_low(:,16)-p.ROSss,0));
burden_high = trapz(t_high,max(S_high(:,16)-p.ROSss,0));
results.ROS_peak = [max(S_pld(:,16)) max(S_low(:,16)) max(S_high(:,16))];
results.ROS_excess_burden = [burden_pld burden_low burden_high];
results.ROS_burden_reduction = 100*(burden_pld-[burden_low burden_high])/burden_pld;

results.time_to_1e4_days = [crossing_time(t_pld,S_pld(:,10),1e4) ...
    crossing_time(t_low,S_low(:,10),1e4) crossing_time(t_high,S_high(:,10),1e4)]/24;
[results.final_EF,results.final_FS] = qsp_cardiac_function(p,results.AUCheart);

save('reference_output_check.mat','results');
disp(results);
fprintf('Tumor-to-heart peak ratio: %.3f\n',results.Ctum_peak(1)/results.Cheart_peak(1));
fprintf('Max PLD-PK scalar difference across EA arms: %.3g\n', ...
    max(abs([results.Cp_peak(2:3)-results.Cp_peak(1) ...
             results.Ctum_peak(2:3)-results.Ctum_peak(1) ...
             results.Cheart_peak(2:3)-results.Cheart_peak(1) ...
             results.AUCheart(2:3)-results.AUCheart(1)])));
end

function crossing = crossing_time(time,values,threshold)
index = find(values<=threshold,1,'first');
if isempty(index)
    crossing = NaN;
elseif index==1
    crossing = time(1);
else
    fraction = (threshold-values(index-1))/(values(index)-values(index-1));
    crossing = time(index-1)+fraction*(time(index)-time(index-1));
end
end
