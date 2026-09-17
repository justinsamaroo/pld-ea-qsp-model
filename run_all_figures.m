function run_all_figures(includeSobol)
% RUN_ALL_FIGURES Generate manuscript and supplementary analysis figures.
%
%   run_all_figures(false) runs all figures except the long Sobol analysis.
%   run_all_figures(true) also runs the N = 1024 Sobol analysis last.

if nargin < 1
    includeSobol = false;
end

repoRoot = fileparts(mfilename('fullpath'));
codeDir = fullfile(repoRoot,'matlab');
outputDir = fullfile(repoRoot,'outputs');

if ~isfolder(outputDir)
    mkdir(outputDir);
end

originalFolder = pwd;
folderCleanup = onCleanup(@() cd(originalFolder));
originalPath = path;
addpath(genpath(codeDir));
pathCleanup = onCleanup(@() path(originalPath));
cd(outputDir);

fprintf('Writing generated files to %s\n', outputDir);

Figure1_model_schematic;
Figure2_exposure_analysis;
Figure3_biomarker_doseresponse;
Supplementary_Figures_S1_S9;
FigureS10_benchmark_sweep;

if includeSobol
    fprintf('Starting the full N = 1024 Sobol analysis. This can take several hours.\n');
    Figure4_Sobol_heatmap;
else
    fprintf('Skipped Figure 4 Sobol analysis. Run run_all_figures(true) for the full analysis.\n');
end

fprintf('Figure generation finished. See README.md for verification and interpretation.\n');
end
