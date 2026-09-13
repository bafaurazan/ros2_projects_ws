# Changelog

All notable changes to this skill are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/), and the project aims to follow semantic versioning.

## [2.0.0] — 2026-08-01

Renamed and generalised: **phd-by-publication** is now **academic-researcher**. The skill serves any researcher writing scholarly papers and keeps the PhD-by-publication route as its deepest specialty. Six new commands capture working methods refined across a real doctorate in progress.

### Changed
- **Skill renamed** to `academic-researcher`; repository renamed to `academic-researcher-skill`; packaged file is now `academic-researcher.skill`. Triggers broadened to standalone papers, master's theses, postdocs, and independent scholars; all PhD-by-publication triggers retained.
- `/professor` teaching engine rebuilt: one sub-milestone per turn with stable sub-part numbering; concepts anchored to the researcher's own design from the first sentence; deliberate hunting of design-specific traps; forward/backward milestone connections; contested claims verified by search; examiner-style active-recall checks (including a trap probe) closing every session; precise part-by-part answer feedback; decisions logged; visible self-correction.
- `/data` reference extended with the `/simulate` protocol.
- New operating principles: **explain-before-apply** (present planned edits and wait for approval before touching the researcher's files) and **keep the program's memory** (dated decision logging in canonical files; strike-never-delete status retirement).

### Added
- **`/sweep`**: adversarial multi-agent manuscript review: one disposable reviewer per finding, each on a distinct adversarial lens; findings interrogated before acceptance; small problems fixed on the spot and replaced with a fresh lens; persistent per-manuscript sweep log with verbatim anchors and dispositions. (`references/sweep-protocol.md`, `assets/sweep-log-template.md`)
- **`/rivals`**: rival-mechanism audit: enumerate every theory predicting the result without the researcher's mechanism, steelman each from its own literature, design the discharging condition or measure, and audit the gap claim itself against primary sources. (`references/rival-mechanisms.md`)
- **`/corpus`**: reading-ledger discipline: one reading log as the single source of truth for held/read/unavailable status, kept current by Claude as the researcher reports their reading; strike-never-delete clearances; the not-held workaround protocol (secondary citation via a named held intermediary, or partial acquisition, before ever declaring an argument blocked). (`references/corpus-ledger.md`, `assets/reading-log-template.md`)
- **`/selfcontained`**: opt-in zero-knowledge explanation standard: every term defined at first use, labels treated as addresses not content, arguments spelled out, the "so what" carried every time. (`references/self-contained.md`)
- **`/simulate`**: power and threshold calibration by simulating the actual design, tested at the design boundary, with the simulation script as the authoritative record. (`references/analysis-and-exhibits.md`)
- **`commands/` folder**: one standalone Claude Code slash-command file per skill command (41 files, including the `/defense` alias). Copy into `~/.claude/commands/` or a project's `.claude/commands/` and every command works as a first-class slash command with autocomplete; each file loads its skill reference before executing.
- **`/exam`**: multiple-choice mastery exams built to be ungameable: balanced answer key (even letter distribution per section), options matched in length and form, real-misconception distractors, per-item explanations, verified facts only ("(verify)" flags for search-level checks); delivered as an interactive lock-on-select HTML exam or a markdown bank. (`references/exam-builder.md`)

## [1.0.0] — 2026-05-29

Initial public release.

### Added
- **34 slash commands** across seven groups, covering the full PhD-by-publication lifecycle.
- Architecture & tracking: `/university`, `/roadmap`, `/milestone`.
- Guidance & adversarial review: `/supervisor`, `/committee` (Optimist/Skeptic/Strategist debate), `/devils-advocate` (0–100 quality-scored peer review).
- Research, writing & evidence: `/research`, `/gap`, `/methodology`, `/theory`, `/draft`, `/data`, `/figure`, `/edit`, `/abstract`, `/openscience`, `/synthesis`.
- Revision & submission: `/revision-coaching`, `/rebuttal`, `/journal`, `/cover-letter`.
- Dissemination, collaboration & funding: `/conference`, `/coauthor`, `/funding`, `/network`.
- Integrity, milestones & defence: `/integrity-citations` (PRISMA-aligned claim–evidence audit), `/ethics`, `/proposal`, `/viva` / `/defense`, `/elevator`.
- Learning, momentum & meta: `/professor` (topic mastery + learning roadmap), `/teach`, `/momentum`, `/help`.
- Support for both **UK/EU/AUS (viva + synthesis chapter)** and **US (committee + proposal defence)** doctoral systems.
- 15 on-demand reference files and 5 fillable templates (roadmap, milestone tracker, learning roadmap, peer-review report, response-to-reviewers).
- Integrity stance baked throughout: the researcher owns the contribution; no fabricated data or citations; honest tool-limit disclosure.
- Packaged `phd-by-publication.skill` for one-click upload to Claude.ai.
