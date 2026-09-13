# Revision Coaching & Response Letters

Used by `/revision-coaching` and `/cover-letter`. The researcher pastes raw, unstructured feedback — reviewer reports, an editor's decision letter, scribbled supervisor notes, track-changes prose — and Claude converts the chaos into a calm, ordered plan plus a diplomatic reply.

The emotional truth: reviewer feedback often lands as a demoralizing wall of criticism, sometimes contradictory, sometimes unfair. The coaching job is to *de-fang and organize* it so the researcher sees a finite, sequenced to-do list instead of an attack.

## Step 1 — Atomize

Break the feedback into **discrete, individually-actionable comments**. One reviewer sentence can contain three demands; split them. Give each an ID (R1.1, R2.3, Ed.2, Sup.4) tracing to its source, because response letters must address each point individually.

## Step 2 — Classify each comment

Tag every atomized item on two axes:

**Severity:** Major (blocks acceptance) / Minor / Editorial (typos, formatting).

**Your stance:**
- **Agree & act** — do it; usually most items.
- **Partially agree** — do part, push back on part.
- **Disagree & defend** — you believe the reviewer is wrong; you'll respond with a reasoned, evidenced rebuttal (allowed and sometimes necessary — but pick these battles).
- **Need clarification** — genuinely ambiguous; note it (the editor can sometimes mediate).

## Step 3 — Detect conflicts and the editor's steer

Reviewers often contradict each other. Surface conflicts explicitly and flag that the **editor's letter is the tie-breaker** — read it for what the editor actually requires vs. lists as optional. Do what the editor emphasizes; for reviewer-vs-reviewer clashes, choose a path and justify it in the letter. Note which comments are "must" vs. "nice."

## Step 4 — Sequence into a revision roadmap

Order the work intelligently, not in the order the reviewers happened to write it:
- **Dependencies first** — structural/analysis changes before prose that describes them. No point polishing a paragraph about an analysis you're about to redo.
- **Highest-impact majors** next — the things that actually decide acceptance.
- **Easy wins** batched — editorial fixes in one pass.
- **Effort estimates** per cluster so the researcher can budget realistically.
Present as an ordered checklist with severity tags and the response-stance for each.

## Step 5 — Draft the response-to-reviewers letter

Use `assets/response-to-reviewers-template.md`. The conventions:
- Open warmly: thank the editor and reviewers, note the manuscript is improved.
- **Point-by-point**, quoting (briefly) or paraphrasing each comment, then your response, then *where* the change was made (section/line/"see revised p.X"). Reviewers want to see their comment addressed and locate the change fast.
- Tone is **gracious and evidence-based, never defensive** — even when disagreeing. "We thank the reviewer for this point. We respectfully retain our approach because [evidence], and have added a sentence clarifying the rationale (p.X)." You catch more acceptances with grace than with grievance.
- For "disagree & defend," lead with the reviewer's legitimate concern, then the reasoned counter, then any partial accommodation. Never just refuse.
- Make every claimed change a real change — if the letter says "we added X," X must exist in the manuscript.
- Keep it the researcher's voice and the researcher's call on contested science; draft, don't dictate.

## Cover letters (`/cover-letter`)

For an initial submission: 1 short page — the contribution in two sentences, why it fits *this* journal specifically, confirmation of originality/ethics/no-conflict, suggested/excluded reviewers if invited. Crisp, not grandiose; editors skim.

## `/rebuttal` — appealing a decision

Distinct from revising after an R&R: occasionally a desk-reject or reject rests on a reviewer's clear factual error or misreading, and an appeal is warranted. Appeals are high-cost and frequently unsuccessful, so counsel honestly before drafting:
- **Triage the grounds.** Appeal only a demonstrable error of fact or process (the reviewer misread the method; a claimed omission is present; a conflict of interest), not mere disagreement with editorial taste or a negative-but-defensible judgment. If the decision is sound, say so and redirect to `/journal` for the next venue — resubmitting elsewhere is usually faster than appealing.
- **Weigh the cost.** An appeal delays the next submission and rarely reverses a considered decision; the funding clock often favors moving on.
- **If justified, draft with restraint.** Address the editor, not the reviewer; identify the specific error precisely and evidence it; remain unfailingly courteous; request reconsideration rather than demanding it. Acknowledge the legitimate parts of the critique.

The decision to appeal is the researcher's; Claude provides a candid assessment of the merits and, where warranted, a measured draft.

## When feedback is from a supervisor (not a journal)

Same parsing, lighter formality. The output is the revision roadmap plus, if useful, a short note back confirming understanding and flagging anything you'll push back on — turning vague "this needs more depth" notes into specific, checkable actions by inferring what the supervisor likely means and confirming it.
