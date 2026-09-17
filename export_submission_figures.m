function out = export_submission_figures(includeTIFF)
% EXPORT_SUBMISSION_FIGURES Redraw the four main figures from bundled results.
% No ODE integrations, Sobol evaluations, or population reruns are performed.
% Default: vector PDFs plus 1000 dpi CMYK TIFFs for Figures 1-4.
% Also refreshes the S2 release comparison and S8 units as vector PDFs.
%   export_submission_figures(false) produces only the PDFs, more quickly.
if nargin<1, includeTIFF = true; end
assert((islogical(includeTIFF) || isnumeric(includeTIFF)) && ...
    isscalar(includeTIFF) && ismember(includeTIFF,[0 1]), ...
    'Use true or false for includeTIFF.');
root = fileparts(mfilename('fullpath'));
oldPath = path; restorePath = onCleanup(@()path(oldPath)); %#ok<NASGU>
addpath(genpath(fullfile(root,'matlab')));
source = fullfile(root,'outputs');
required = {'Figure3_biomarker_results.mat','Figure4_sobol.mat', ...
    'FigureS6_S9_population.mat'};
for k = 1:numel(required)
    assert(isfile(fullfile(source,required{k})), ...
        'Extract the complete repository ZIP before running this function.');
end
p = qsp_parameters();
b = load(fullfile(source,required{1}));
s = load(fullfile(source,required{2}));
pop = load(fullfile(source,required{3}));
assert(all(isfield(b,{'doses','peakB','ratio','attenuation'})), ...
    'Incomplete Figure 3 result file.');
assert(isequal(b.doses,[0 25 50 100 200 300 400]) && ...
    isequal(size(b.peakB),[5 7]) && all(isfinite(b.peakB(:))), ...
    'Unexpected Figure 3 doses or result dimensions.');
ratio = b.peakB./p.Bss(:);
attenuation = 100*(b.peakB(:,1)-b.peakB)./b.peakB(:,1);
assert(max(abs(ratio(:)-b.ratio(:)))<1e-10 && ...
    max(abs(attenuation(:)-b.attenuation(:)))<1e-8, ...
    'Stored Figure 3 ratios do not match the stored peaks.');
assert(all(isfield(s,{'ST','N','seed','parameter_names','nominal','lower','upper'})), ...
    'Incomplete Figure 4 result file.');
assert(s.N==1024 && s.seed==1 && isequal(size(s.ST),[28 5]) && ...
    all(isfinite(s.ST(:))) && all(s.ST(:)>=0), ...
    'Expected the publication Sobol results: N=1024, seed=1, 28 by 5 indices.');
assert(isequal(s.parameter_names(:),p.sobol_names(:)) && ...
    max(abs(s.nominal(:)-p.sobol_nom(:))./max(abs(p.sobol_nom(:)),eps))<1e-12, ...
    'Saved Sobol parameter names or nominal values differ from the model.');
assert(max(abs(s.lower(:)-.8*p.sobol_nom(:))./abs(p.sobol_nom(:)))<1e-12 && ...
    max(abs(s.upper(:)-1.2*p.sobol_nom(:))./abs(p.sobol_nom(:)))<1e-12, ...
    'Saved Sobol bounds differ from the publication design.');
assert(isfield(pop,'P') && pop.P.seed==12345 && pop.P.Nrats==200, ...
    'Expected the stored 200-rat population with seed 12345.');

stamp = char(datetime('now','Format','yyyyMMdd_HHmmss_SSS'));
out = fullfile(root,'submission_exports',stamp);
mkdir(out);
fprintf('Redrawing stored results. No simulation rerun is needed.\n');
fig = qsp_main_figure(1);
qsp_export_figure(fig,out,'Figure1',178,179,includeTIFF);
exposure = struct('eta_form',[1 10 25 50],'oral_Cmax',qsp_ea_cmax(p));
exposure.effective_Cmax = exposure.oral_Cmax*exposure.eta_form;
fig = qsp_main_figure(2,exposure);
qsp_export_figure(fig,out,'Figure2',86,92,includeTIFF);
b.names = p.bio;
fig = qsp_main_figure(3,b);
qsp_export_figure(fig,out,'Figure3',178,90,includeTIFF);
fig = qsp_main_figure(4,s);
qsp_export_figure(fig,out,'Figure4',86,195,includeTIFF);
[fig,release] = qsp_release_figure(p);
qsp_export_figure(fig,out,'FigureS2',178,80,false);
fig = qsp_ros_population_figure(pop.P);
qsp_export_figure(fig,out,'FigureS8',178,80,false);

mainFiles = {'Figure1.pdf','Figure2.pdf','Figure3.pdf','Figure4.pdf'};
zipFiles = mainFiles;
if includeTIFF
    zipFiles = [zipFiles,{'TIFF_CMYK/Figure1.tif','TIFF_CMYK/Figure2.tif', ...
        'TIFF_CMYK/Figure3.tif','TIFF_CMYK/Figure4.tif'}];
end
zip(fullfile(out,'Main_Figures.zip'),zipFiles,out);
% Refresh only the plotted outputs after all exports succeed. Numerical
% Figure 3, Sobol and population MAT files are never overwritten here.
updatedPDFs = [mainFiles,{'FigureS2.pdf','FigureS8.pdf'}];
for k = 1:numel(updatedPDFs)
    copyfile(fullfile(out,updatedPDFs{k}),fullfile(source,updatedPDFs{k}));
end
save(fullfile(source,'Figure2_exposure_results.mat'),'-struct','exposure');
save(fullfile(source,'FigureS2_release_results.mat'),'-struct','release');
record = struct('exported_at',stamp,'matlab_version',version, ...
    'source_files',{required},'Sobol_N',s.N,'Sobol_seed',s.seed, ...
    'population_seed',pop.P.seed,'simulations_recomputed',false);
save(fullfile(source,'submission_export_record.mat'),'record');
fprintf('\nFinished. Main figures ZIP and PDFs: %s\n',out);
fprintf('The six updated PDFs were also copied into the repository outputs folder.\n');
fprintf('Open the PDFs and check their layout before submission.\n');
end
