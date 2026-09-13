# The Sweep — Adversarial Multi-Agent Manuscript Review

Reference for `/sweep`. A **sweep** is a repeatable, logged, adversarial pass over one manuscript (a paper draft, a theory chapter, a protocol, a synthesis chapter) whose purpose is to surface the *strongest genuinely new problems* the document still contains — and to leave a permanent, auditable record of every finding and its resolution. It is the heaviest review instrument in this skill: `/devils-advocate` scores a draft once against a rubric; `/sweep` hunts for specific, novel defects and accumulates them across sessions into a growing quality ledger.

Developed and battle-tested across a real doctorate in progress, where repeated sweeps carried theory papers through dozens of confirmed findings without a single fabricated critique.

## When to run a sweep

- A draft has already had its first-pass review (rubric score, supervisor comments) and the researcher wants deeper, adversarial scrutiny.
- Before submission, as the last internal gate.
- Periodically on a long-lived "workbench" document that evolves over months.
- On request: "run a sweep for N findings on this paper."

## The protocol

### 1. One agent per finding, one lens per agent

Dispatch **one disposable subagent per requested finding** (if the environment supports subagents; otherwise run each lens as a separate, self-contained analytical pass). Each agent receives:
- the full manuscript,
- the existing sweep log (so it cannot resubmit a known finding),
- **one distinct adversarial lens**, and
- the instruction to return exactly **one strongest, genuinely new finding**: verbatim quotes anchoring it, a severity rating, and candidate fixes written in the manuscript's own register.

Standard lenses (choose per document; invent new ones as the document matures):

| Lens | Hunts for |
|------|-----------|
| **Internal consistency** | Claims in one section contradicted or silently weakened elsewhere. |
| **Citation support** | Sentences whose cited source does not actually say what the sentence needs it to say. |
| **Falsifier quality** | Predictions or claims that no realistic observation could refute (self-sealing arguments). |
| **Rival-theory handling** | Competing accounts dismissed, straw-manned, or ignored (pairs with `/rivals`). |
| **Derivation logic** | Steps where a conclusion does not follow from the stated premises. |
| **Measurement grounding** | Constructs invoked without a defensible measure; instruments used outside their validated range. |
| **Novelty / prior art** | The "gap" or contribution already exists in the literature under other vocabulary. |
| **Register / style compliance** | Violations of the paper's own declared writing rules, hedging drift, over-claiming. |
| **Reader-cold comprehension** | Passages a reader with zero project context could not parse (pairs with `/selfcontained`). |

### 2. Interrogate before accepting

**Never accept an agent's finding at face value.** For each returned finding, the main assistant must:
- **Steelman the manuscript** — try to defeat the finding using the document's own text.
- **Demand quotes** — a finding not anchored to verbatim text is not a finding.
- **Probe the proposed fix** — what does the fix break? Does it create a new inconsistency elsewhere?
- Iterate with the agent (or re-examine directly) until the finding is **confirmed, downgraded, or withdrawn**, and the best in-register fix is settled.

### 3. Small problems don't count

If interrogation downgrades a finding to a small problem with an obvious fix: apply (or recommend) the fix immediately, log only a one-line note, and **dispatch a replacement agent on a fresh lens** so the requested finding count is still met with substantive findings. A sweep that returns typos has failed its job.

### 4. The main assistant does all logging

Findings go into a persistent per-manuscript sweep log (e.g. `mypaper-sweeps.md`; template in `assets/sweep-log-template.md`). Every entry records:
- **Sweep number and date.**
- **Finding number, lens, and severity** (CRITICAL / MAJOR / MINOR).
- **Verbatim anchor quotes** from the manuscript.
- **The finding stated self-containedly** — readable cold by someone who has never seen the project, all shorthand unpacked, every label accompanied by what it actually says (see `/selfcontained` for the standard).
- **Disposition** — CONFIRMED / DOWNGRADED / WITHDRAWN, with the interrogation reasoning in brief.
- **The settled fix** and, once applied, a dated note that it was applied.

Resolved findings are **struck through, never deleted** — the log is the memory that prevents future sweeps from rediscovering old problems, and the audit trail that shows the manuscript earned its state.

### 5. Report back

Close the sweep with a summary the researcher can act on: findings ranked by severity, the fixes awaiting their decision, and (on request) a polished formatted report or PDF of the sweep's findings.

## Conduct

- **The researcher decides.** The sweep surfaces problems and candidate fixes; the researcher rules on every fix before it enters the manuscript (see the explain-before-apply principle in SKILL.md).
- **No manufactured findings.** If the document genuinely yields fewer strong findings than requested, say so plainly — an honest short sweep beats a padded one.
- **Findings must be earned.** Every finding is anchored to quoted text and survives interrogation; severity reflects consequence for the argument, not rhetorical drama.
- **Self-correct visibly.** If a logged finding later proves wrong, retract it in the log by name, dated, with the reason.
