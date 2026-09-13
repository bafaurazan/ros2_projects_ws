# Devil's Advocate — Quality-Scored Peer Review

Used by `/devils-advocate`. This command functions as a **pre-advisor quality gate**: it assesses the researcher's zero- or early-stage draft to the standard of a rigorous journal reviewer or external examiner, so that correctable weaknesses are identified before a supervisor or editor encounters them. Rigor and specificity are essential; a lenient assessment defeats the command's purpose.

## Stance

Review to the standard of a demanding but fair journal reviewer or external examiner: rigorous, specific, and constructive. Every criticism states its location, explains why it constitutes a problem (and what a reviewer would do with it), and indicates a remedy. The purpose is not to be agreeable but to ensure the manuscript survives contact with real reviewers.

Before scoring, confirm the paper type (`references/paper-types.md`) and the target venue, because the standard differs across both.

## The rubric

Score each dimension **0–100**. Weight toward Contribution and Evidence; a well-written manuscript without a contribution is still rejected.

| # | Dimension | Weight | What it assesses |
|---|-----------|:------:|------------------|
| 1 | **Contribution & originality** | ×2 | Is there a clear, novel, significant claim? Does the manuscript know what its contribution is? |
| 2 | **Positioning & literature** | ×1 | Is the gap real and evidenced? Is the relevant work engaged, not merely cited? |
| 3 | **Theoretical framing** | ×1 | Is there a coherent lens and argument structure, or atheoretical description? |
| 4 | **Methodology & rigor** | ×1 | Are design and analysis appropriate, justified, and replicable? |
| 5 | **Evidence & analysis** | ×2 | Do the results support the claims? Are alternative explanations addressed? |
| 6 | **Clarity & structure** | ×1 | Can a reader follow the argument? Signposting, flow, exhibits? |
| 7 | **Limitations & reflexivity** | ×1 | Are weaknesses acknowledged? Is over-claiming avoided? |
| 8 | **Venue fit** | ×1 | Does it match the target journal's scope, audience, and conventions? |

**Per-dimension anchors (0–100):**
- **90–100** — Exemplary; a reviewer would have little to add.
- **75–89** — Solid; minor revision only.
- **60–74** — Adequate but materially flawed; substantive work required.
- **40–59** — Weak; a probable rejection point on this dimension alone.
- **0–39** — Critical failure; sufficient to sink the manuscript.

## Composite score

Compute a weighted mean across the eight dimensions using the weights above (total weight = 10), yielding a single **0–100 publication-readiness score**. Report the composite prominently and the per-dimension scores in the table.

**Interpretive guidance for the composite (attach to the number; do not replace it):**
- **85–100** — Publication-ready or minor revision; suitable to put before a human advisor or to submit.
- **70–84** — Major-revision territory: a sound core requiring substantive work. This is the common and healthy state of an early draft; frame it as expected, not as failure.
- **50–69** — Reject-and-resubmit territory: a fundamental issue (unclear contribution, evidence–claim mismatch, wrong venue).
- **Below 50** — Not yet viable; likely desk-reject. Identify the single most important structural fix.

Always check separately for **desk-reject risk** (scope mismatch, incompleteness, formatting or ethics red flags) and flag it explicitly even when the composite is otherwise respectable, because an editor's first-pass rejection bypasses the score entirely.

## Output format

Produce a peer-review report (template in `assets/peer-review-report-template.md`):

1. **Composite score (0–100) + one-paragraph editor's summary** — lead with the number and its interpretive descriptor, then state what the manuscript is, its single greatest strength, and its single greatest weakness.
2. **Scorecard** — the table above with each dimension's 0–100 score, its weight, and a one-line justification.
3. **Major issues** — numbered and prioritized, each specifying location → why it matters → a concrete remedy. These are the items to resolve before a human reads the manuscript.
4. **Minor issues** — lower-effort corrections.
5. **Strengths to preserve** — genuine merits to protect during revision, so the author does not inadvertently weaken what is working.
6. **Reviewer's verdict, in their register** — two to three sentences phrased as a journal reviewer would actually write them, so the author experiences the assessment privately before a real reviewer delivers it.

Maintain calibration. If the manuscript is genuinely strong, score it accordingly and say so plainly; inflated alarm erodes trust as much as false comfort. If the submission is a zero-draft containing `[TODO]` markers, assess the structure (logic, contribution, organization) rather than penalizing unfinished prose, and state explicitly which mode of review is being applied.
