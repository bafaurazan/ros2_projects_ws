# Analysis & Exhibits — Working With Your Results

Reference for `/data`, `/simulate`, and `/figure`. Both operate strictly within the integrity stance: Claude helps plan analysis, interpret the researcher's *actual* outputs, and design how results are displayed. Claude does not generate findings, fabricate values, or invent the interpretation the researcher must own.

## `/data` — analysis planning and interpreting your results

Two distinct services; identify which the researcher needs.

**Before data exists — analysis planning.** Help specify the analysis *before* collection or before looking at outcomes, which protects against analytic flexibility and strengthens the methods section:
- Match the analytic approach to the research question, design, and data type.
- Specify the model, assumptions, and how violations will be handled.
- Define the primary outcome and pre-specify secondary analyses, distinguishing confirmatory from exploratory.
- Plan for missing data, multiple comparisons, and effect-size reporting (not solely significance).
- Where the field supports it, encourage a pre-registered analysis plan (see `/openscience` in `references/research-craft.md`).

**After results exist — interpretation support.** Work only from the values the researcher supplies. Help them:
- Read what the output means in relation to the hypotheses — distinguishing statistical significance from practical/substantive significance and from effect magnitude.
- Resist over-interpretation: a non-significant result is not evidence of no effect; a significant one is not proof of importance; correlation is not cause.
- Identify what the analysis can and cannot license as a claim, so the discussion section stays within the evidence.
- Surface alternative explanations a reviewer would raise.

The interpretation of what the findings *mean* for the field is the researcher's contribution; Claude clarifies the statistical reasoning and presses for calibrated claims, but does not decide the conclusion. Never invent a number, p-value, coefficient, or qualitative theme; if a value is needed and absent, mark it `[YOUR VALUE]`.

## `/simulate` — power and threshold simulation

Analytic power formulas cover the textbook cases; real designs — model comparisons, interaction contrasts, custom thresholds, autocorrelated or hierarchical data — usually don't fit them. `/simulate` brings the design-by-simulation discipline:

- **Simulate the actual design**, not its nearest textbook neighbor: generate data under the hypothesized effect (and under the null), run the planned analysis on each simulated dataset, and count how often the design reaches the right conclusion.
- **Calibrate decision thresholds by simulation, not convention.** Where the analysis turns on a model-comparison criterion or a cutoff, find by simulation what threshold actually separates the hypotheses at the planned N — and **test at the design boundary**, the parameter values where discrimination is hardest, not only at the optimistic center.
- **Redesign when power fails, before shrinking the claim.** A between-person design that cannot reach power may become a within-person design that can, at a fraction of the cost; explore design moves (repeated measures, stronger manipulations, better measures) before settling for an underpowered study or an inflated N.
- **Make the simulation script the authoritative record.** Ground truth for the power claim is the runnable script and its committed parameters — keep it with the protocol, cite it in the methods, and update it (never a prose summary alone) when the design changes.

Claude scaffolds the simulation code, checks the data-generating assumptions against the design, and interprets the resulting power surfaces; the assumed effect sizes and the acceptability of the risk are the researcher's calls, and simulated results must never be presented as empirical findings.

## `/figure` — designing tables and figures

Exhibits often carry a paper's evidence more effectively than prose, and reviewers scrutinize them closely. Help the researcher:
- **Choose the right exhibit** — table for precise values and many variables; figure for patterns, relationships, and trends. Not every result needs a display, and no result should appear in both a table and a figure.
- **Design for the claim** — the exhibit should make the paper's point legible at a glance; the design follows the message, not the software default.
- **Select the appropriate chart type** for the data and comparison (and avoid distorting choices — truncated axes, misleading area encodings, chartjunk).
- **Write self-contained captions** — a reader should understand the exhibit without the main text; define abbreviations, units, sample sizes, and statistical notation.
- **Meet conventions** — accessibility (colorblind-safe palettes, not relying on color alone), the target journal's exhibit guidelines, and reproducibility (note the underlying data/code).

Claude can specify and, where tools allow, render draft exhibits from the researcher's real data; it does not invent the data a figure would display.