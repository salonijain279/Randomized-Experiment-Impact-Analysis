# Randomized Experiment Impact Analysis

Two randomized evaluations answer a common analytics question: **did an intervention change behavior, and for whom did it work best?**

The first analysis measures whether a digital recognition incentive increased user participation. The second evaluates whether an education support program improved standardized mathematics and language scores. Together, they show a move from treatment-control validation to effect estimation, subgroup analysis, and assumption checks.

## Key findings

### Digital recognition and user participation

- Treatment and control users were balanced on tenure, premium status, and prior posting activity.
- Receiving the recognition incentive increased the probability of posting by **6.30 percentage points** (`p = 0.0064`).
- The response was concentrated among first-time contributors: their estimated treatment effect was approximately **11.5 percentage points**.
- The interaction between treatment and first-time status was statistically significant (`p = 0.0182`), while the treatment effect for experienced users was not.

### Education support and student outcomes

- Pre-intervention mathematics and language scores did not differ significantly between treatment and control schools.
- After the program, treated students scored **0.177 standardized units higher in mathematics** and **0.127 units higher in language**.
- Both post-program differences were statistically significant.

## Analytical approach

Methods:

- Welch two-sample tests to evaluate pre-treatment balance;
- linear probability models to estimate average treatment effects;
- interaction models to identify heterogeneous effects;
- pre/post validation for the education intervention; and
- SUTVA and spillover checks to define where the causal interpretation could weaken.

The code is organized as reusable functions rather than as an assignment transcript. It validates the required fields, returns tidy model summaries, and keeps the two experiments analytically separate.

## Repository structure

```text
R/experiment_analysis.R   Validation and treatment-effect functions
R/run_analysis.R          Command-line runner for authorized local data
data/README.md            Input schemas and data-use boundary
results/verified_findings.csv
tests/test_analysis.R     Synthetic-data checks for the core calculations
```

## Run the analysis

The original datasets are not redistributed. With authorized local copies:

```bash
Rscript R/run_analysis.R \
  /path/to/platform_experiment.csv \
  /path/to/education_program.csv \
  outputs
```

Run the code checks with:

```bash
Rscript tests/test_analysis.R
```

## Interpretation notes

- A randomized treatment supports causal interpretation only when assignment remains intact and outcomes are measured consistently.
- The education comparison is strongest when treatment is interpreted at the assignment level and cross-school spillovers are limited.
- The platform experiment may face interference if treated users change what control users see or do.
- Subgroup estimates should be interpreted through the interaction model, not by comparing significance levels across separate regressions.

## Tools and skills

`R` · experimental design · balance testing · linear probability models · treatment interactions · heterogeneous effects · causal assumptions

## Collaboration

The original analyses were completed with **Shivanshu Dagur**; this repository is maintained by Saloni Jain, who rewrote the analytical workflow for clear, reusable presentation.
