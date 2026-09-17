# PLD and ellagic acid QSP model

Standalone MATLAB implementation for the manuscript:

> Rat-Calibrated Quantitative Systems Pharmacology Framework to Define Target-Site Ellagic Acid Requirements During PEGylated Liposomal Doxorubicin Therapy

**Software author: Justin Mark Samaroo.** The manuscript authors are Justin Mark Samaroo, Bart Lipkens, Shuhua Bai and Hamed Gilzad-Kohan. Software citation metadata lists Justin Mark Samaroo alone.

The model contains 20 ordinary differential equation states: five liposomal doxorubicin dose cohorts, free doxorubicin in plasma, RES, tumor and heart, viable tumor cells, five cardiac biomarkers, cardiac reactive oxygen species (ROS), three ellagic acid (EA) pharmacokinetic states, and cumulative cardiac doxorubicin exposure. Ejection fraction (EF) and fractional shortening (FS) are calculated from cumulative cardiac exposure.

## Overview

This repository contains the model source, stored numerical results, main Figures 1-4 and supplementary Figures S1-S10. The included results support both a quick figure export and a complete recomputation of the analyses. The software is distributed under the [MIT License](LICENSE).

Repository: [justinsamaroo/pld-ea-qsp-model](https://github.com/justinsamaroo/pld-ea-qsp-model).

## Requirements

- MATLAB R2025b, base installation.
- SimBiology and additional toolboxes are not required.

## Quick figure export from the included results

Extract the entire repository folder and set it as the Current Folder in MATLAB. Run:

```matlab
export_submission_figures
```

This generates the four main figures as vector PDFs and 1000 dpi CMYK TIFFs, plus a `Main_Figures.zip` containing only those image files. It also exports the Figure S2 release comparison and Figure S8 ROS analysis as separate PDFs. Files are written to a dated folder under `submission_exports/`, and the six exported PDFs are copied into `outputs/`.

The function loads the original Figure 3, Sobol and population MAT files included in `outputs/`. It does not rerun the ODE model, the 30,720 Sobol evaluations or the virtual population. Figure 2 is evaluated from the linear EA pharmacokinetic equations using a matrix exponential and peak search. Figure S2 uses the exact cumulative release expression with the cohort age floor.

For a faster PDF-only export:

```matlab
export_submission_figures(false)
```

The requested final widths are 178 mm for Figures 1 and 3, and 86 mm for Figures 2 and 4. Main text is 8 pt, with smaller mathematical subscripts and superscripts. The checked PDFs contain vector graphics and embedded fonts. TIFF export uses four CMYK channels, LZW compression and 1000 dpi metadata. Inspect any newly generated files at final size. The CMYK conversion is a numerical conversion without an embedded printing profile.

See the [MATLAB exportgraphics documentation](https://www.mathworks.com/help/matlab/ref/exportgraphics.html) for the distinction between vector output and raster resolution.

## Recompute the model results

The following commands recompute simulations, rather than simply redrawing the included results:

```matlab
run_all_figures(false)   % Figures 1-3 and S1-S10, including 200 virtual rats
run_all_figures(true)    % The same analyses plus the full Sobol run
```

The full Sobol design uses 1,024 base samples, 28 varied parameters and 30,720 full model evaluations. This may take several hours. Replotting the stored results does not require this run. These commands update files in `outputs/`.

Individual analyses can be run after adding the complete MATLAB folder:

```matlab
addpath(genpath(fullfile(pwd,'matlab')))
Figure1_model_schematic
Figure2_exposure_analysis
Figure3_biomarker_doseresponse
Figure4_Sobol_heatmap
Supplementary_Figures_S1_S9
FigureS10_benchmark_sweep
```

Individual functions write their results to the Current Folder. The `run_all_figures` entry point selects `outputs/` automatically and restores the original folder and MATLAB path on completion.

## Files and figure mapping

| File or folder | Purpose |
| --- | --- |
| `matlab/model/` | Canonical parameter definitions, 20 equations, dosing and sampling, cardiac function and population generator |
| `matlab/analysis/` | Reference output and cohort age floor sensitivity checks |
| `matlab/plotting/` | Shared plot layouts and export functions |
| `matlab/Figure1_model_schematic.m` | Figure 1 model schematic |
| `matlab/Figure2_exposure_analysis.m` | Figure 2 EA exposure comparison |
| `matlab/Figure3_biomarker_doseresponse.m` | Figure 3 biomarker dose response |
| `matlab/Figure4_Sobol_heatmap.m` | Figure 4 Sobol analysis |
| `matlab/Supplementary_Figures_S1_S9.m` | Figures S1-S9, with one shared population sample |
| `matlab/FigureS10_benchmark_sweep.m` | Figure S10 EA benchmark sensitivity |
| `outputs/` | Original numerical results and plotted outputs |
| `export_submission_figures.m` | Quick export using the included results |
| `CITATION.cff` | Software citation metadata |

The supplementary generator contains local model functions and uses the shared plotting helpers for Figures S2 and S8. Future scientific changes must be applied consistently to the canonical and supplementary model functions.

## Reproducibility settings

- ODE solver: `ode15s`, relative tolerance `1e-7`, absolute tolerance `1e-10`, maximum step 4 h, nonnegative states 1-19.
- Dosing: PLD 3.75 mg/kg intravenously at days 0, 7, 14, 21 and 28, using a 0.25 kg rat. Oral EA is administered daily on days 0-34. Simulations end at day 42.
- Each integration segment reaches the exact next dose boundary. The reporting grid includes dense samples after every scheduled dose.
- For positive cohort ages, the release coefficient is evaluated at `max(cohort_age,1e-3)` h. At exactly zero age, the RHS coefficient is zero. Its value at this single point does not change the integrated continuous release expression.
- Population: 200 virtual rats, independent lognormal parameter sampling, seed `12345` using `twister`.
- Population percentiles: ordered sample position `N*p + 0.5`, with linear interpolation and endpoint clipping. Here `p` is the percentile expressed as a fraction.
- Sobol: seed `1` using `twister`, independent uniform sampling from 80% to 120% of each nominal value, with PLD plus EA at 200 mg/kg and `eta_form = 1`.
- The Figure 4 total order estimate is `mean((YA - YAB).^2)/(2*var([YA;YB]))` for each output. The original MAT stores indices and design metadata. Updated code additionally saves the sampled matrices and evaluated outputs on a future recomputation.
- Cumulative ROS excess integrates `max(ROS - ROSss,0)` over time in hours.

Reference checks can be rerun separately:

```matlab
addpath(genpath(fullfile(pwd,'matlab')))
check_reference_outputs
check_tau_floor_sensitivity
```

These functions write files to the Current Folder. Their original result files are already included in `outputs/`.

## Verification of included outputs

The included export record documents a successful `export_submission_figures` run in MATLAB R2025b Update 1 on 16 September 2026. The four main PDFs and the Figure S2 and S8 PDFs were inspected for layout and clipping, and checked for vector graphics and embedded fonts. The four generated main-figure TIFFs were checked for CMYK channels, 1000 dpi resolution metadata and LZW compression. TIFFs can be regenerated with the export command; the repository includes the figure PDFs.

The export uses stored biomarker, Sobol and population results. It does not repeat the full ODE, Sobol or virtual-population analyses. The included Sobol design uses N = 1024 and seed 1; the population contains 200 virtual rats with seed 12345. The stored Sobol MAT contains the indices and design metadata, but does not contain the individual evaluations from that run. These checks do not independently recompute those evaluations or quantify the sampling uncertainty of the indices.

Consistency checks of the exported figures confirmed that:

- Figure 2 concentrations follow the computed oral EA peak multiplied by 1, 10, 25 and 50.
- Figure 3 curves reproduce the saved biomarker ratios and percentage decreases.
- All 140 Figure 4 heatmap annotations match the stored total order indices rounded to two decimal places.
- Figure S2 implements the exact integral of the release coefficient with the 0.001 h cohort age floor. At 168 h, nominal fractional release is approximately 0.5433 and release-only ODE fractional release is approximately 0.4181.
- Figure S8 reports a correlation of 0.40, consistent with the stored value of approximately 0.40433.

Selected reference results are listed below. They are model outputs, not experimental observations.

| Quantity | Reference result |
| --- | ---: |
| Oral EA peak, 100 mg/kg | 0.35487775 microgram/mL |
| Oral EA peak, 200 mg/kg | 0.70975550 microgram/mL |
| Free plasma DOX peak, PLD alone | 8.60858439 microgram/mL |
| Tumor DOX peak, PLD alone | 11.30133199 microgram/mL |
| Cardiac DOX peak, PLD alone | 0.09006735 microgram/mL |
| Cardiac DOX AUC, PLD alone | 46.05176597 microgram h/mL |
| cTnI decrease, EA 100 / 200 mg/kg | 7.3636% / 12.5870% |
| cTnT decrease, EA 100 / 200 mg/kg | 7.6818% / 12.9744% |
| Cumulative ROS excess reduction, EA 100 / 200 mg/kg | 20.5537% / 37.8601% |
| Population plasma DOX peak, 5th / 50th / 95th percentiles | 5.44 / 8.49 / 13.64 microgram/mL |
| Population final EF, 5th / 50th / 95th percentiles | 45.6% / 48.3% / 56.8% |

The independent linear EA peak calculation used for Figure 2 gives 0.70975553 microgram/mL at 200 mg/kg, consistent with the saved simulation value to the reported precision. Numerical consistency and successful export do not establish experimental or clinical validity. The assumptions and structural limitations below govern interpretation.

## Interpretation and parameter provenance

This is a model for exploring hypotheses using rat parameters. Its parameters have different evidence levels, as specified in the manuscript and supplementary tables.

The EA absorption and disposition constants were taken from [Yan et al.](https://doi.org/10.3390/molecules191118923). The apparent EA central volume is 506.611 mL in code, rounded to 0.507 L in the manuscript. It was selected for an assumed concentration target and is a Tier 3 scenario assumption. Oral bioavailability of 0.01 is also a Tier 3 assumption.

The EA benchmark of 11.1 microgram/mL was obtained by converting the EA-alone IC50 of 36.6 micromolar reported for SKOV-3 ovarian cancer cells by [Elsaid et al.](https://doi.org/10.1111/1440-1681.13338), using a molecular weight of 302.2 g/mol. Using this value as the concentration scale for modification of doxorubicin activity is a Tier 3 assumption. It is not a measured EA-doxorubicin interaction parameter. The assumed maximum fractional increase of 1.0 allows a doubling of the doxorubicin killing rate.

Both Korsmeyer-Peppas parameters, `kKP = 0.06` and `nKP = 0.43`, are Tier 3 assumptions. Neither was fitted to release measurements obtained specifically for PLD. The coefficient multiplies the remaining encapsulated doxorubicin concentration. Without regularization of cohort age, and with release as the only loss process, cumulative fractional release is `1 - exp(-kKP*tau^nKP)`. Figure S2 compares the nominal power law with the release-only solution that includes the implemented age floor.

The `eta_form` multiplier scales plasma EA concentrations used in pharmacodynamic terms. It represents hypothetical exposure from a separately administered EA product. The model does not simulate a formulation, carrier distribution or tissue EA concentration.

EA modifies biomarker turnover and ROS scavenging. EF and FS depend only on cardiac doxorubicin exposure, so their equality across EA groups follows from the model structure. There is no feedback from the biomarkers or ROS to EF or FS.

The historical parameter `krel_RES` implements untracked loss from the RES, with no return flux to plasma. The additional EPR input to the tumor is not deducted from the liposomal cohorts. These concentration transfer approximations are not a closed mass balance. Cardiac exchange is coupled to free plasma doxorubicin. Its contribution to peak plasma variability is negligible within the tested ranges, rather than identically absent.

## Citation and release

`CITATION.cff` provides the software citation metadata and lists Justin Mark Samaroo as the sole software author. The software is distributed under the [MIT License](LICENSE), and the citation metadata records `license: MIT`.

Version v1.0.0 is archived on Zenodo at https://doi.org/10.5281/zenodo.22818176. Cite this DOI when referring to this version of the model, results and documentation.

