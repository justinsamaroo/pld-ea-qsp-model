# Stored results and plotted outputs

This folder contains the reference numerical results, main Figures 1-4 and supplementary Figures S1-S10. The completed Sobol analysis uses N = 1024 and seed 1; the virtual population contains 200 rats generated with seed 12345.

| File | Contents |
| --- | --- |
| `Figure3_biomarker_results.mat` | Biomarker dose-response results |
| `Figure4_sobol.mat` | First order and total order sensitivity indices and design metadata |
| `FigureS6_S9_population.mat` | Shared virtual population results |
| `FigureS10_benchmark_results.mat` | EA benchmark sensitivity results |
| `reference_output_check.mat` | Reference-output checks |
| `tau_floor_sensitivity.mat`, `tau_floor_sensitivity.csv` | Cohort-age-floor sensitivity results |
| `original_result_hashes.json` | SHA-256 hashes and sizes of the seven reference MAT/CSV files above |
| `Figure2_exposure_results.mat` | Oral EA peak and effective exposure multipliers used in the export |
| `FigureS2_release_results.mat` | Nominal and regularized release-only curves and coefficient values |
| `submission_export_record.mat` | Export time, MATLAB version, source filenames and random seeds |

The included export record documents a successful MATLAB R2025b run on 16 September 2026. The four main PDFs and Figure S2 and S8 PDFs were checked for layout, embedded fonts and vector content. Details and selected numerical reference values are provided in the root [README.md](../README.md).

Run `export_submission_figures` from the repository root to regenerate the four main PDFs and CMYK TIFFs plus the Figure S2 and S8 PDFs. This uses the saved biomarker, Sobol and population files and does not repeat the full simulation analyses. The export refreshes the six PDFs and the three export-specific MAT files while preserving the reference numerical results.

The included Sobol MAT contains full precision first order and total order indices and design metadata, but not the individual model evaluations. A new full Sobol recomputation saves those evaluations as well. The included indices are sufficient for an exact replot of Figure 4.
