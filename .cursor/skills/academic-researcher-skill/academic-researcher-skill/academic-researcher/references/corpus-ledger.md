# The Corpus Ledger — Reading-Log and Holdings Discipline

Reference for `/corpus`. A long research program accumulates dozens or hundreds of sources across many working files, and the single most corrosive failure mode is **status drift**: one file says a paper is "not held," another says it was read months ago, and eventually an argument is declared blocked for want of a source the researcher finished in March. This reference establishes a ledger discipline that makes that failure impossible.

The discipline comes from a real doctorate where stale "NOT HELD" text in a side file caused a review pass to declare an unblocked derivation blocked — a full working day lost to a fact the reading log had recorded correctly all along.

## Rule 1 — One source of truth

**Exactly one file — the reading log (`READING_LOG.md`; template in `assets/reading-log-template.md`) — is allowed to assert what is held, read, unread, or unavailable.** No other file in the project may state that a paper is missing, unread, or blocking; other files may only *point* to the log. Before treating any source as unavailable, or any argument as blocked for want of a source, **check the log first**.

One derivative is permitted: an **acquisition ledger** (e.g. `find-paper.md`) listing what is still being hunted, with DOIs and candidate access routes. It must be reconciled against the reading log whenever a paper is acquired or read — the log wins every conflict.

## Rule 2 — The assistant logs what the researcher reads

The reading log records the **researcher's own reading**, and keeping it current is the assistant's clerical job, not the researcher's memory burden. Whenever the researcher reports having read, skimmed, or acquired a source — in any session, in passing or formally — **update the log immediately**: full reference, date read, depth (full read / partial / skim), where the notes or extracts live, and one line on what the source turned out to say relative to why it was queued.

The log is a record of reading that actually happened. Never mark a source as read on inference, and never summarize a source into the log that the researcher has not actually read — the log's value is that every line in it is true.

## Rule 3 — Strike, never delete

When a status claim goes stale (a "not held" becomes held; a "blocking" becomes discharged), **strike it through, date the clearance, and point it at the reading-log line that discharges it** — never delete it. Findings, quotations, and lessons attached to the old status are always preserved; only the *status* is retired. This keeps the audit trail intact and prevents the same status from being re-asserted later from memory.

Anchor references to the log by **heading or entry, not line number** — line numbers drift as the log grows.

## Rule 4 — The not-held workaround protocol

A genuinely unobtainable source does not get to block an argument by default. When a source cannot be acquired, choose deliberately and record the choice in the log:

1. **Secondary citation via a named held intermediary** — cite the unobtainable primary *as reported in* a source the researcher actually holds and has read, marked as such in the manuscript ("as cited in…"). The intermediary must be named in the log entry so the dependency is auditable.
2. **Partial acquisition** — a legitimately accessible portion (publisher preview, indexed excerpt, author-posted chapter) read and logged as *partial*, with its limits stated wherever the source is used.
3. **Blocked — last resort.** Only when neither route can support the claim does the argument get marked blocked, in the log, with a dated entry saying exactly what the missing source is needed *for*.

The manuscript must never lean on an unheld source harder than the chosen workaround supports.

## Rule 5 — The reading plan stays unread-only

Keep a companion **reading plan** (tiered queue of what remains to read, in priority order). The moment a source is read, it moves to the log and *leaves* the plan — a plan cluttered with finished reading hides the true remaining workload.

## What `/corpus` does in a session

On invocation (or when any task touches the source base):
1. **Reconcile** — check the reading log, acquisition ledger, and reading plan against each other; the log wins; strike-and-date any stale status found elsewhere.
2. **Log new reading** — capture whatever the researcher reports having read since last time (Rule 2).
3. **Status report** — held vs. outstanding, what is blocking what (per the log only), and the highest-priority unread items.
4. **Advise on acquisition** — DOIs, legitimate access routes, and workaround choices (Rule 4) for the outstanding items.
