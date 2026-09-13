# Academic Researcher: The Researcher's Operating System (a Claude Skill)

> A **Claude [Agent Skill](https://agentskills.io)** that gives Claude the roles a research program needs: supervisor, editor, adversarial peer reviewer, simulated committee, reading-ledger keeper, milestone tracker, literature tutor, and writing partner. Built for anyone writing scholarly papers, from a first journal article to a full doctorate, with the deepest support for the **PhD by publication** (thesis by published works), where it began.

<p>
<img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-green.svg">
<img alt="Agent Skills standard" src="https://img.shields.io/badge/Agent%20Skills-open%20standard-blue">
<img alt="Works with Claude" src="https://img.shields.io/badge/Works%20with-Claude.ai%20%7C%20Claude%20Code%20%7C%20API-orange">
<img alt="Version 2.0.0" src="https://img.shields.io/badge/version-2.0.0-lightgrey">
</p>

**Keywords:** academic research assistant · research workflow · academic writing · peer review · PhD by publication · thesis by publication · compilation thesis · article-based dissertation · three-paper dissertation · kappa / synthesis chapter · doctorate · dissertation · viva preparation · systematic review · PRISMA · literature review · reading log · rival hypotheses · power simulation · research methodology · reviewer response letter · Claude skill · Anthropic Agent Skill · AI research assistant · AI PhD supervisor · independent researcher.

---

## Table of contents
- [What is this?](#what-is-this)
- [Who it is for](#who-it-is-for)
- [The core principle (academic integrity)](#the-core-principle-academic-integrity)
- [What it does](#what-it-does)
- [New in 2.0](#new-in-20)
- [The 40 commands](#the-40-commands)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Supported doctoral systems](#supported-doctoral-systems)
- [Honest limitations](#honest-limitations)
- [Repository structure](#repository-structure)
- [Contributing](#contributing)
- [How to cite](#how-to-cite)
- [License & disclaimer](#license--disclaimer)
- [Recommended GitHub topics](#recommended-github-topics)

---

## What is this?

An **Agent Skill for Claude** that supports the full lifecycle of scholarly work: planning a research program, mastering a literature, designing and simulating studies, hunting rival explanations, drafting and reviewing papers, parsing reviewer feedback into revision plans, auditing citations and evidence, tracking what you have read, and preparing you for examination.

Once you install it, Claude recognises **40 slash commands** (and the plain-English equivalents) and switches into the matching mode. You wait weeks for a supervisor meeting and months for peer review; these loops run in minutes, at the same standard of rigour.

The skill began as a support system for the **PhD by publication**, also called a *thesis by publication*, *compilation thesis*, *article-based dissertation*, or *three-paper dissertation*: a doctorate earned through a portfolio of publishable papers bound by an integrative **synthesis chapter** (the *kappa*). That route remains its deepest specialty. Version 2.0 adds the working methods one candidate refined over a doctorate in progress.

## Who it is for

- **Researchers writing academic papers**: graduate students, postdocs, faculty, and practitioners publishing from industry.
- **Independent and self-funded researchers** with little or no formal supervision. The skill plays the missing roles.
- **PhD-by-publication candidates**, who get the full apparatus: portfolio planning, synthesis chapter, viva preparation.
- **Master's and doctoral students** on conventional thesis routes, in both UK/EU/AUS and US systems.
- **Supervisors and writing centres** who want candidates to self-assess before human review.

## The core principle (academic integrity)

One rule governs the skill:

> **The researcher owns the contribution. Claude owns the scaffolding, the friction, and the feedback loops.**

Claude plans, structures, critiques, interrogates, organises, checks, and coaches: the work a good supervisor and committee provide. Claude does not fabricate data, results, or citations, does not invent empirical claims you have not earned, and treats the intellectual core as yours. An AI-written doctorate is worthless, and your university can revoke it. Use the skill within your institution's AI-use and disclosure policies.

## What it does

- **Plans the whole programme.** Reverse-engineers a paper portfolio from a single contribution claim, with milestones and a risk register.
- **Acts as your supervisor.** Recurring sessions that review the roadmap, cross off completed milestones, and decompose the next one into concrete steps.
- **Simulates a research committee.** Three voices (Optimist, Skeptic, Strategist) debate any decision, design, or draft, then deliver a verdict.
- **Scores your draft like a reviewer.** A pre-advisor gate that grades a draft 0–100 against an eight-dimension academic rubric.
- **Runs adversarial review sweeps.** Single-lens reviewers hunt a manuscript's strongest remaining defects; Claude interrogates each finding before accepting it and logs it with verbatim anchors.
- **Audits rival explanations.** Lists the theories that predict your result without your mechanism, and designs the condition that discharges each.
- **Keeps your reading ledger.** One log records what you have read and hold, so a stale note in a side file can never falsely block an argument.
- **Coaches revisions.** Parses raw reviewer feedback into a sequenced revision plan and a point-by-point response letter.
- **Audits integrity and citations.** A PRISMA-aligned audit of claims against evidence that flags over-claiming, missing support, and unverifiable references.
- **Teaches the topic to mastery.** One sub-milestone at a time, anchored to your design, ending in examiner-style recall checks.
- **Examines you.** Multiple-choice mastery exams with balanced keys, misconception distractors, and per-item explanations.
- **Prepares you for the viva / defence.** Mock examinations, question banks, and the contribution pitch.
- Plus focused commands for methodology, theory, drafting, editing, abstracts, figures, power simulation, ethics, open science, funding, conferences, co-authorship, and networking.

## New in 2.0

The six new commands came out of a real doctorate in progress, where each one earned its place before it entered the skill:

- **`/sweep`**: one disposable reviewer per finding, each assigned a distinct lens (internal consistency, citation support, falsifier quality, rival-theory handling, derivation logic, and more). Claude interrogates every finding before accepting it, fixes small problems on the spot and redeploys the lens, and logs everything to a persistent sweep file. In use it carried theory papers through dozens of confirmed findings without one manufactured critique.
- **`/rivals`**: written the day a systematic hunt found seven rival theories, each predicting a study's key interaction through a different mechanism, and the design changed before data collection. Includes auditing the gap claim itself against primary sources, because full reads kill gaps more often than researchers admit.
- **`/corpus`**: written after a stale "NOT HELD" note in a side file convinced a review pass that an unblocked argument was blocked. One reading log rules; Claude logs what you read; stale statuses get struck through with dated clearances, never deleted; unobtainable sources get a principled workaround.
- **`/selfcontained`**: an opt-in explanation standard. Claude writes every account of your work for a reader who knows nothing, defines every coined term, and pairs every section label with what the section says. Useful for sweep logs, viva answers, and your future self.
- **`/simulate`**: power and threshold calibration by simulating your actual design, tested at the boundary where discrimination is hardest. The simulation script, not a prose summary, is the record.
- **`/exam`**: multiple-choice mastery exams you cannot reverse-engineer: correct answers spread evenly across the option letters in every section, options matched in length and form, distractors drawn from real misconceptions, every item explained, every fact verified or flagged "(verify)". Delivered as an interactive lock-on-select HTML exam or a markdown bank.

The teaching engine (`/professor`) was rebuilt from the same experience: one sub-milestone per turn, concepts taught through your design from the first sentence, deliberate hunting for design-specific traps, and examiner-style recall checks closing each session.

## The 40 commands

| Group | Commands |
|-------|----------|
| **Architecture & tracking** | `/university` · `/roadmap` · `/milestone` |
| **Guidance & adversarial review** | `/supervisor` · `/committee` · `/devils-advocate` · `/sweep` · `/rivals` |
| **Research, writing & evidence** | `/research` · `/gap` · `/methodology` · `/theory` · `/draft` · `/data` · `/simulate` · `/corpus` · `/figure` · `/edit` · `/selfcontained` · `/abstract` · `/openscience` · `/synthesis` |
| **Revision & submission** | `/revision-coaching` · `/rebuttal` · `/journal` · `/cover-letter` |
| **Dissemination, collaboration & funding** | `/conference` · `/coauthor` · `/funding` · `/network` |
| **Integrity, milestones & defence** | `/integrity-citations` · `/ethics` · `/proposal` · `/viva` (`/defense`) · `/elevator` |
| **Learning, momentum & meta** | `/professor` · `/teach` · `/exam` · `/momentum` · `/help` |

Run `/help` inside Claude for the annotated list. The commands are a convenience vocabulary; Claude also responds to the plain-English equivalents ("review my chapter like a journal reviewer", "what other theories predict my result", "log what I read this week").

## Installation

The skill contains Markdown instructions, references, and templates. No scripts, no executable code. Read it end to end before installing if you want to audit it.

### Claude.ai (Pro, Max, Team, Enterprise)
1. Download [`academic-researcher.skill`](./academic-researcher.skill) from this repository.
2. In Claude, go to **Settings → Capabilities → Skills** and upload the file.
3. Enable it. Start a chat and type `/help` or describe your research.

### Claude Code
Clone into your skills directory so Claude Code discovers it on startup:
```bash
# personal (all projects)
git clone https://github.com/Scottthe3rd/academic-researcher-skill ~/.claude/skills/academic-researcher-tmp
mv ~/.claude/skills/academic-researcher-tmp/academic-researcher ~/.claude/skills/academic-researcher

# or per-project (committed with the repo)
mkdir -p .claude/skills && cp -r academic-researcher .claude/skills/
```

**Optional: real slash commands.** The [`commands/`](./commands/) folder holds one Claude Code command file per skill command, so `/sweep`, `/rivals`, `/exam`, and the other 38 work as first-class slash commands (with autocomplete) instead of trigger phrases. Copy them next to the skill:
```bash
# personal (all projects)
cp commands/*.md ~/.claude/commands/

# or per-project
mkdir -p .claude/commands && cp commands/*.md .claude/commands/
```
Each command file loads the matching skill reference before running, so install the skill itself as well. Claude.ai ignores the `commands/` folder; there the skill routes slash commands by itself.

### Claude API (with the code-execution / skills capability)
Upload or reference the `academic-researcher/` folder per the [Anthropic API skills documentation](https://docs.claude.com). The skill follows the open [Agent Skills standard](https://agentskills.io), so other compatible agent tools can run it too.

## Quick start

Try any of these once installed:

```text
/roadmap I'm an independent researcher in education technology with one pilot study; map my whole research programme.
/sweep Run an adversarial sweep for 5 findings on this draft: <paste>
/rivals My study predicts an attention × difficulty interaction — what rival theories predict the same result, and how do I discharge each?
/corpus Set up a reading log for my project, and log the three papers I read this week.
/devils-advocate Review this draft introduction against a journal-reviewer rubric before my advisor sees it: <paste>
/revision-coaching Here are my reviewer comments — parse them into a revision plan and a response letter: <paste>
/simulate Will N=120 give me power to detect this model-comparison at my planned threshold?
/selfcontained Rewrite this summary of my argument so a cold reader understands every sentence: <paste>
/professor Build me a learning roadmap to master self-regulated learning theory and its key literature.
/exam Build me an 80-question balanced exam over milestone 6, as an interactive HTML test.
/viva Run a mock viva focused on my contribution and methodology.
```

## Supported doctoral systems

You configure the skill per project. It supports both major systems:
- **UK / EU / Australia**: oral *viva voce* examination plus a synthesis chapter (*kappa*); milestones around registration, confirmation/upgrade, paper cycles, and submission.
- **United States**: committee model with a proposal/prospectus defence and a final defence; the publication route takes the form of an article-based dissertation with an integrative introduction and conclusion.

Researchers outside a doctoral programme skip the institution-specific parts. The rest applies unchanged.

## Honest limitations

- **Not a ghostwriter.** The skill refuses to fabricate data, results, findings, or citations, and treats the intellectual contribution as yours. Use it within your institution's AI policy.
- **Citation/database access.** Claude cannot query subscription databases (Scopus, Web of Science, and the like). For literature and integrity work it uses web search, applies PRISMA methodology, audits claims against sources, and flags what it cannot verify.
- **Not authoritative on institutional rules.** `/university` compiles a researched starting point; regulations change, so confirm with the institution's graduate school.
- **Not legal, financial, or mental-health advice.** `/momentum` offers writing-productivity support, not clinical care, and points you to qualified help where appropriate.

## Repository structure

```
.
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CHANGELOG.md
├── CITATION.cff
├── academic-researcher.skill         # packaged, ready to upload to Claude.ai
├── commands/                         # 41 standalone Claude Code slash commands (one file each)
└── academic-researcher/              # skill source
    ├── SKILL.md                      # dispatcher: philosophy, command catalogue, integrity stance
    ├── references/                   # detailed protocols, loaded on demand per command
    │   ├── university-requirements.md
    │   ├── roadmap-and-milestones.md
    │   ├── supervisor.md
    │   ├── professor.md
    │   ├── committee-personas.md
    │   ├── peer-review-rubrics.md
    │   ├── sweep-protocol.md
    │   ├── rival-mechanisms.md
    │   ├── corpus-ledger.md
    │   ├── self-contained.md
    │   ├── exam-builder.md
    │   ├── revision-coaching.md
    │   ├── integrity-and-citations.md
    │   ├── paper-types.md
    │   ├── research-craft.md
    │   ├── analysis-and-exhibits.md
    │   ├── professional-practice.md
    │   ├── researcher-support.md
    │   ├── synthesis-kappa.md
    │   └── viva-defense.md
    └── assets/                       # fillable templates
        ├── roadmap-template.md
        ├── milestone-tracker-template.md
        ├── learning-roadmap-template.md
        ├── peer-review-report-template.md
        ├── response-to-reviewers-template.md
        ├── reading-log-template.md
        └── sweep-log-template.md
```

## Contributing

Contributions are welcome: sharper rubrics, discipline-specific guidance, additional doctoral systems, new adversarial lenses for `/sweep`, and bug fixes. Read [CONTRIBUTING.md](./CONTRIBUTING.md) first. Researchers will audit what they install, so every change must keep the skill script-free, evidence-honest, and integrity-first.

## How to cite

If this skill supports your research, cite it and disclose AI assistance per your institution's policy. A machine-readable [`CITATION.cff`](./CITATION.cff) is included, and GitHub renders a "Cite this repository" button. Example:

> Scott. (2026). *Academic Researcher: The Researcher's Operating System (a Claude Skill)* (Version 2.0.0) [Computer software]. GitHub. https://github.com/Scottthe3rd/academic-researcher-skill

## License & disclaimer

Released under the [MIT License](./LICENSE). The skill aids rigorous independent research; it does not confer, guarantee, or substitute for any academic qualification, and it does not replace human supervision, peer review, or your institution's regulations. Use it ethically and disclose AI assistance where required.
