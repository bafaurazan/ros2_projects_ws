# The Exam Builder — Multiple-Choice Mastery Tests

Reference for `/exam`. Where `/professor` closes each teaching turn with a short free-recall check, `/exam` builds a **full multiple-choice examination bank** over a milestone, topic, or literature — the instrument that decides whether a milestone is *mastered* rather than merely *covered*. The governing standard: **a milestone is mastered only when the researcher answers from memory, not recognition** — so every construction rule below exists to make the test ungameable.

## Construction rules (non-negotiable)

1. **Balanced answer key — the key cannot be reverse-engineered.** Within every section, correct answers are distributed **evenly across the option letters** (e.g., in a 16-question section of four-option items, exactly four correct answers per letter). No streak-reading, no "when in doubt pick C."
2. **Options matched in length and form.** All options in an item have comparable length, grammatical structure, and specificity. The correct answer must never be identifiable as the longest, most hedged, or most detailed option — a test-wise reader with zero knowledge should score at chance.
3. **Identical format throughout.** One item format across the exam: same option count, same phrasing conventions, same voice. Variation in format leaks information and adds construct-irrelevant difficulty.
4. **Distractors are real misconceptions, not filler.** Each wrong option is something a partially-informed reader might genuinely believe: the neighboring concept, the reversed direction, the claim from the rival theory, the overgeneralized finding. A distractor nobody would pick is a wasted slot that raises the guessing floor.
5. **Every item carries an explanation.** One or two sentences shown after answering: why the credited option is right and, where the distractor traps a known confusion, why that trap is wrong. The exam teaches on contact.
6. **Verified facts only — flag the rest.** Specific numbers, named effects, and study results are search-verified before appearing in an item; anything checked only at search/abstract level is explicitly marked **"(verify)"** in its explanation rather than presented with false confidence. Never build an item on an invented finding or citation.
7. **Balanced coverage.** Items spread across all sub-topics in scope (state the blueprint: N items per sub-milestone), weighted toward mechanisms, boundary conditions, contested findings, and the researcher's design-specific traps — not just headline definitions. Include items that probe *why* and *what breaks*, phrased the way an examiner would ask.

## Delivery formats

Offer both; default to whichever the researcher used last.

- **Interactive HTML exam (preferred for self-testing).** A single self-contained file: answers **lock on selection** (no changing after the reveal, so the researcher cannot game the key), the explanation appears immediately, and a sticky score bar tracks running results with a per-section breakdown and a reset control. Style it cleanly and legibly; respect any standing presentation preferences the researcher has expressed (e.g., a dark theme).
- **Markdown bank.** Numbered items with an answer key + explanations at the end, suitable for printing or spaced re-testing.

## Session flow

1. **Scope and blueprint first.** Confirm what the exam covers (which milestone/sub-topics, how many items, item count per section) before writing items.
2. **Build against the taught record.** Draw items from what was actually taught and logged (the learning roadmap, curriculum notes, literature matrix) — an exam over untaught material tests reading, not mastery.
3. **Score honestly.** On completion, report per-section results, diagnose the *pattern* of misses (which sub-topic, which trap), and feed weak areas back into `/professor` as the next teaching targets. A milestone is marked mastered on the roadmap only after a passed exam, not after the teaching alone.
4. **Regenerate, don't recycle.** For a retake, write fresh items on the missed territory; a second sitting of identical items measures memory of the exam, not of the material.
