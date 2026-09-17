# Start here

The `outputs/` folder contains the stored numerical results and figure PDFs. Open these PDFs to view the included results. The main figures and Figures S2 and S8 were checked following a successful MATLAB R2025b export on 16 September 2026. See the verification section of [README.md](README.md) for the checks and their scope.

## Export figures from the included results

1. Download and extract the complete repository.
2. In MATLAB R2025b, set Current Folder to the repository folder containing `export_submission_figures.m`, `matlab` and `outputs`.
3. Run:

```matlab
export_submission_figures
```

This creates the four main figures as vector PDFs and 1000 dpi CMYK TIFFs, a `Main_Figures.zip` containing those images, and separate Figure S2 and S8 PDFs. It writes a dated folder under `submission_exports/` and refreshes the six PDFs in `outputs/`. It uses the stored results without repeating the full ODE, Sobol or virtual population analyses.

For PDF output only, use:

```matlab
export_submission_figures(false)
```

Inspect any newly generated PDFs at their intended final size. The `README.md` describes the figure mapping, numerical settings and commands for recomputing the complete model analyses.

## Authorship, license and release

Justin Mark Samaroo is the sole software author. Manuscript authorship is listed separately in the README. The software is distributed under the [MIT License](LICENSE), also recorded in `CITATION.cff`.

Version v1.0.0 is archived on Zenodo at https://doi.org/10.5281/zenodo.22818176. Cite this DOI when referring to this version of the model, results and documentation.

