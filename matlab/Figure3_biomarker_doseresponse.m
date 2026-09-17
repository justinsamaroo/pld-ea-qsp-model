function Figure3_biomarker_doseresponse
% FIGURE3_BIOMARKER_DOSERESPONSE
% Figure 3. Cardiac biomarker dose-response across oral ellagic acid dose.

clear; close all;
p = qsp_parameters();

doses = [0 25 50 100 200 300 400];
ug_per_mgkg = 250;  % dose conversion for a 250-g rat
nB = numel(p.bio);
peakB = zeros(nB,numel(doses));

for dose_index = 1:numel(doses)
    opt = struct('ea_dose',doses(dose_index)*ug_per_mgkg, ...
        'eta_form',1,'ec50_ea',p.EC50_EA,'npts',1500);
    [~,states] = qsp_run(p,opt);
    for biomarker = 1:nB
        peakB(biomarker,dose_index) = max(states(:,10+biomarker));
    end
end

ratio = peakB./p.Bss(:);
attenuation = 100*(peakB(:,1)-peakB)./peakB(:,1);

data = struct('doses',doses,'ratio',ratio,'attenuation',attenuation, ...
    'names',{p.bio});
fig = qsp_main_figure(3,data);
qsp_export_figure(fig,pwd,'Figure3',178,90,false);
save('Figure3_biomarker_results.mat','doses','peakB','ratio','attenuation');
fprintf('Saved Figure3.pdf and Figure3_biomarker_results.mat\n');
for biomarker = 1:nB
    fprintf('%-10s attenuation(%%): %s\n',p.bio{biomarker}, ...
        mat2str(round(attenuation(biomarker,:),1)));
end
end
