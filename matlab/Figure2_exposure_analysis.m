function Figure2_exposure_analysis
% FIGURE2_EXPOSURE_ANALYSIS EA exposure at 200 mg/kg once daily.
% The exposure multiplier is hypothetical. It does not model a formulation.
p = qsp_parameters();
data.eta_form = [1 10 25 50];
data.oral_Cmax = qsp_ea_cmax(p);
data.effective_Cmax = data.oral_Cmax*data.eta_form;
fig = qsp_main_figure(2,data);
qsp_export_figure(fig,pwd,'Figure2',86,92,false);
save('Figure2_exposure_results.mat','-struct','data');
fprintf('Saved Figure2.pdf and Figure2_exposure_results.mat.\n');
end
