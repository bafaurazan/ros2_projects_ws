# Integrity & Citations — Evidence Audit and Verification

Used by `/integrity-citations` and the systematic-search side of `/research`. The promise to the researcher: *you will never build a chapter on weak evidence, a misread source, or a citation that doesn't say what you think it says.* This is the command that protects them from the single most catastrophic doctoral failure — a contribution resting on sand.

## Honest tool limits (state these; don't bluff)

Claude **cannot** directly query subscription databases (Web of Science, Scopus, PsycINFO, etc.). What Claude *can* do is real and valuable:
- Use **web search** to locate papers, check whether a cited work exists, and read open-access/abstract content.
- Apply the **PRISMA methodology** to structure and document a systematic search the researcher then executes/completes in their databases.
- **Audit a manuscript's internal logic**: every claim against its cited support, flagging gaps and over-reach.
- Cross-check citation details and surface likely-fabricated or unverifiable references.

Never paper over a limit with a confident-sounding invention. If a source can't be verified, **say so and mark it** — an honest "unverified" is worth more than a fluent guess. Never fabricate a citation, DOI, quote, or finding. When using search results, paraphrase and cite; do not reproduce large copyrighted chunks.

## Mode A — Claim–evidence audit of a chapter

Go through the manuscript claim by claim:
1. **Extract load-bearing claims** — every sentence that asserts a fact, prior finding, or "it is known that…". Ignore the researcher's own novel results (those rest on their data, not citations) but flag if *those* are over-stated.
2. For each cited claim, ask:
   - **Existence** — does the cited source plausibly exist? (Search if doubtful.)
   - **Support** — does the source actually say this? Flag paraphrases that drift from, exaggerate, or reverse the source.
   - **Primary vs. secondary** — is a primary finding cited to a review or textbook (citation laundering)? Push toward primary sources.
   - **Currency** — is a fast-moving claim resting on stale evidence?
   - **Strength match** — does a tentative single study get cited as settled fact? Calibrate the claim's confidence to the evidence's weight.
3. **Flag uncited claims** — substantive assertions with *no* support are the highest-risk items; a reviewer will pounce. List them.
4. Output a table: claim → citation(s) → status (Supported / Weak / Mismatch / Uncited / Unverifiable) → recommended action.

## Mode B — Citation verification

For a reference list or in-text citations:
- Check each reference's existence and detail accuracy (authors, year, venue) via search where feasible.
- Flag **red flags for fabrication**: too-perfect titles that don't surface anywhere, DOIs that don't resolve, journals that don't exist, author/venue mismatches — common in AI-generated or hastily-assembled lists. (If the researcher used any AI tool to gather references, treat the list as guilty until verified.)
- Check for **retractions** where the claim is load-bearing.
- Screen cited venues for **predatory-journal** signatures; a thesis leaning on predatory sources is vulnerable.
- Report: verified / detail-correction-needed / unable-to-verify / likely-fabricated.

## Mode C — PRISMA systematic search (for review papers / `/research`)

When the chapter makes a systematic-evidence claim, structure it to PRISMA 2020 so it's defensible and reproducible:

1. **Protocol** — question (PICO/SPIDER), inclusion/exclusion criteria, registered if possible (PROSPERO). Define *before* searching.
2. **Identification** — search strings per database (build Boolean strings with the researcher's keywords; Claude can draft these and run open web/Scholar-style searches to scope, but the researcher runs them in the actual databases). Record counts.
3. **Screening** — title/abstract screen against criteria; record excluded + reasons.
4. **Eligibility** — full-text assessment; record excluded + reasons.
5. **Included** — final set feeding synthesis.
6. **PRISMA flow diagram** — produce the four-box flow with counts at each stage (Identification → Screening → Eligibility → Included). Offer to render it.
7. **Quality / risk-of-bias appraisal** — apply an appropriate tool (e.g. for the design) so the synthesis weights evidence, not just counts it.

Document everything so the search is **reproducible** — that's what separates a systematic review from a literature dump, and what an examiner will probe.

## Evidence hierarchy (calibrate claims to this)

Roughly, strongest → weakest for empirical claims: meta-analysis / systematic review > RCT > cohort/quasi-experimental > case-control > cross-sectional > case series > expert opinion / single anecdote. (Disciplines vary — qualitative work has its own rigor criteria: credibility, transferability, dependability, confirmability.) Match the confidence of each written claim to where its support sits on this ladder; downgrade language when the evidence is thin.

## Output

A `/integrity-citations` report: the relevant mode's table(s), a prioritized list of "fix before this goes anywhere," an explicit list of anything Claude could not verify (with why), and — when relevant — the PRISMA flow. End with a one-line integrity verdict: is any part of this chapter currently resting on evidence too weak to defend in a viva?
