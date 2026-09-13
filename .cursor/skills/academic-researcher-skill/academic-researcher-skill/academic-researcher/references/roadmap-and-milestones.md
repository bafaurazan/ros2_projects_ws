# Roadmap & Milestones — Program Architecture

Used by `/roadmap` and `/milestone`. The roadmap is the spine of the whole program; everything else hangs off it.

## The governing idea: reverse-engineer from the contribution

A PhD by publication is **not** "write some papers and staple them." It is *one* original contribution to knowledge, expressed through several publications. So design top-down:

1. **Contribution claim** — one or two sentences: *"This thesis establishes X about Y, which matters because Z."* If the researcher can't state it, that's the first job. Everything downstream must serve it.
2. **Research program** — the 2–4 sub-questions whose answers, together, substantiate the claim.
3. **Paper portfolio** — each paper answers one sub-question (roughly). Map papers → sub-questions → contribution. Gaps and overlaps surface immediately.
4. **The golden thread** — the throughline (theoretical lens, dataset, phenomenon, or method) that makes the papers obviously one program. Name it explicitly; the synthesis chapter is built on it.

A healthy portfolio is **3–6 papers**. A common, robust shape:
- **Paper 1** — conceptual / positioning / systematic review: stakes out the gap and the framework. Doubles as the literature foundation for the kappa.
- **Papers 2–4** — the empirical/analytical core: the actual new knowledge.
- **Final paper** — often integrative, an extension, or a higher-stakes venue piece.
Adapt to discipline; this is a scaffold, not a rule.

## Two doctoral systems (the skill supports both)

### UK / EU / Australia — viva + synthesis chapter
- Submission = the bound papers + a **synthesis chapter (kappa)** + sometimes a critical commentary on each paper.
- Examined by **oral viva voce** with internal + external examiners; outcome bands from pass to major corrections to revise-and-resubmit.
- Papers may be published, accepted, under review, or "publishable" depending on institution — confirm the local rule early.
- Milestone spine: registration → confirmation/upgrade (≈ year 1) → paper cycles → synthesis chapter → submission → viva → corrections → award.

### US — committee + proposal defense + dissertation
- Coursework + comprehensive/qualifying exams → **dissertation proposal defense** → research → **final defense** before a committee (chair + members).
- The "publication" format = a dissertation whose body chapters are journal articles, topped and tailed by an integrative intro and conclusion (the US analogue of the kappa).
- Milestone spine: coursework → quals/comps → proposal defense → candidacy → paper/chapter cycles → final defense → deposit.

When the system is unknown, ask; when set, store it in the roadmap and bend milestone names, the defense prep (`/viva`), and the synthesis framing (`references/synthesis-kappa.md`) accordingly.

## Status taxonomy (use consistently in the tracker)

`idea → scoped → outlined → zero-draft → full draft → self-reviewed (/devils-advocate passed) → advisor-reviewed → submitted → under review → R&R (major/minor) → accepted → published / in thesis`

A paper is only "done for thesis purposes" when it meets the **institution's** bar (published / accepted / under review / publishable) — record that bar.

## Milestone schedule

Build a realistic schedule backward from the funding/submission deadline. Rules of thumb (calibrate hard to the person — these are planning anchors, not promises):
- A core empirical paper: **3–6 months** idea→submittable for a focused researcher; longer with new data collection.
- **Peer review adds 3–9 months** of mostly-waiting per cycle, often with an R&R. This is the dominant schedule risk — parallelize: while Paper 2 is under review, draft Paper 3.
- Synthesis chapter: **6–10 weeks** of concentrated work, but only once ≥2 papers are stable.
- Always hold a buffer; doctorates overrun. Plan to the 75th-percentile-bad case, not the dream.

## Roadmap artifact format

Produce/maintain `roadmap.md` (template in `assets/roadmap-template.md`) containing:

1. **Project profile** — system, discipline, citation style, papers required + local "done" bar, timeline, supervision reality, target venues.
2. **Contribution claim** — the one/two-sentence statement + the golden thread.
3. **Research program** — sub-questions mapped to papers.
4. **Paper portfolio table** — for each paper: working title, sub-question/role, target journal, method, current status, next action, owner-of-thinking note.
5. **Milestone schedule** — dated, backward from the deadline, with the buffer visible.
6. **Risk register** — see below.

## Milestone tracker (the `/milestone` view)

On `/milestone`, render a compact status pass:
- Portfolio table with each paper's status + the single next action.
- "On pace?" verdict against the schedule, with the binding constraint named.
- Top 1–3 blockers and a concrete unblock for each.
- One honest sentence on momentum (don't sugarcoat a stall; don't catastrophize a slow week).
Then update the roadmap artifact's tracker in place.

## `/proposal` — proposal, prospectus, or confirmation report

An early formal milestone that secures approval to proceed, under different names by system:
- **US**: the dissertation **proposal / prospectus defense** — typically the introduction, literature review, and proposed methodology, defended before the committee to advance to candidacy.
- **UK/EU/AUS**: the **confirmation / upgrade / transfer report** (often ~end of year 1) — a comparable document demonstrating a viable, original program, sometimes with a short oral component.

For the publication route, frame the proposal around the **portfolio**: the overarching contribution claim, the planned papers and their sub-questions, the coherence argument (the golden thread), the methodology spanning them, a realistic timeline, and the anticipated contribution to knowledge. Help the researcher assemble this from the roadmap rather than as a separate artifact — the proposal is largely the roadmap rendered as prose plus a literature foundation and a detailed methodology. Anticipate the panel's or committee's likely questions (route to `/viva` for rehearsal) and pre-empt the obvious objections in the document itself.

## Risk register — what actually derails a PhD by publication

Track and mitigate these; they kill more candidates than bad ideas do:
- **Incoherent portfolio** — papers don't add up to one contribution. *Mitigation:* re-run the contribution→sub-question→paper map at every milestone; guard the golden thread.
- **Scope creep / the perfect paper** — endlessly polishing one paper. *Mitigation:* time-box; "good enough to submit" beats "perfect and unsubmitted."
- **Review-cycle latency** — the silent clock-killer. *Mitigation:* always have the next paper in motion; submit early; pick realistic venues (see `/journal`).
- **Single point of failure** — the whole thesis leans on one paper that gets rejected. *Mitigation:* portfolio redundancy; have a fallback venue ladder per paper.
- **Isolation (independent researchers especially)** — no external pressure or sanity-check. *Mitigation:* schedule recurring `/supervisor` and `/committee` sessions as forcing functions; seek at least one real human reader.
- **Integrity drift under deadline pressure** — temptation to over-claim or lean too hard on AI for the thinking. *Mitigation:* the core bargain in SKILL.md; routine `/integrity-citations` and `/devils-advocate` passes.
