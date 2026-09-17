# Canonical model implementation

The files in this folder are the callable implementation used by the main-figure and analysis functions.

- `qsp_parameters.m` contains the nominal parameter set and Sobol metadata.
- `qsp_run.m` handles dosing events, event-aware output sampling, and integration with `ode15s`.
- `qsp_rhs.m` contains the 20 state equations.
- `qsp_cardiac_function.m` calculates EF and FS from cumulative cardiac DOX exposure.
- `qsp_population.m` generates the documented virtual population.
- `qsp_ea_cmax.m` calculates the EA plasma peak for the nominal 200 mg/kg daily regimen from the linear PK system, using a matrix exponential and peak search.

The EA peak helper evaluates the linear pharmacokinetic equations using a matrix exponential and peak search. The full model uses numerical ODE integration. See the root README for parameter evidence, reference outputs and software authorship.

## Historical variable-name mapping

The following internal field names map to the terminology used in the manuscript.

| Internal name | Manuscript interpretation |
| --- | --- |
| `eta_form` | Assumed multiplier on pharmacologically available plasma EA from a separately administered product |
| `EC50_EA` | Source-anchored EA-alone antiproliferative benchmark used in the assumed doxorubicin-effect modifier |
| `EEA_pot` | Maximum magnitude of the assumed doxorubicin-effect modifier |
| `krep` | Historical code name for biomarker turnover or loss rate, not myocardial repair |
| `krel_RES` | Historical code name implemented as an untracked first-order RES loss, not a return flux to plasma |

The EPR input to the tumor is also not subtracted from the liposomal cohorts. These concentration-transfer approximations are documented limitations and must not be interpreted as a closed mass-balanced system.
