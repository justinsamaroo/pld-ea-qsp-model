# Changelog

## Initial repository baseline

- Standalone MATLAB implementation of the 20-state PLD and ellagic acid QSP model, with nominal parameters, dosing, cardiac function and population generation in `matlab/model/`.
- Stored biomarker, N = 1024 Sobol, 200-rat population, benchmark-sweep, reference-output and cohort-age-floor sensitivity results.
- Main Figures 1-4 and supplementary Figures S1-S10, with shared plotting functions and a quick export from the included results.
- Main figure export to vector PDF and 1000 dpi CMYK TIFF, plus separate Figure S2 and S8 PDFs. Successful MATLAB R2025b export and output checks are summarized in the README.
- Software authorship and MIT licensing recorded in `CITATION.cff` and `LICENSE`.

## Numerical and scientific corrections incorporated in this baseline

- Integration reaches each exact dosing boundary before the next event is applied, correcting the earlier possibility of skipping the interval between the final reporting point and a dose.
- Dense post-dose sampling is applied consistently across treatment arms; nonnegative states 1-19 are requested from the solver.
- The supplementary generator includes the complete local model and state equations.
- The separately administered EA exposure multiplier is named `eta_form`. Co-encapsulation is not modeled.
- The EA-alone benchmark is attributed to SKOV-3 cells; its use in the assumed DOX activity modifier is distinguished from an experimentally measured interaction parameter. The EA central volume and release parameters are identified as Tier 3 assumptions.
- Figure S2 compares the nominal power law with release from remaining encapsulated drug and includes the implemented age floor. Figure S8 uses the corrected ROS generation coefficient units.
- The schematic documents untracked RES loss, EPR input that is not deducted from liposomal cohorts, and EF/FS dependence on cardiac DOX exposure without feedback from biomarkers or ROS.
- Figure 2 does not treat `KM_ROS` as an EA concentration threshold. It is a ROS-axis constant in the implemented scavenging term.
- Future full Sobol recomputations save sampled matrices and individual evaluations in addition to the sensitivity indices. The included reference MAT contains the indices and design metadata from the completed analysis.

No new full simulation run was performed when packaging this baseline. The included model calculations, figure PDFs and numerical results are preserved.
