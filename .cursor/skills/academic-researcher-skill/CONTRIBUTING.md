# Contributing

Thank you for helping improve the **Academic Researcher** Claude skill. Researchers will audit what they install, so contributions must keep the skill trustworthy as well as useful.

## Ground rules

1. **Script-free.** This skill contains only Markdown instructions, references, and templates — no executable code, no install steps, no network calls. Please keep it that way; it is a core trust property.
2. **Evidence-honest.** Nothing in the skill should encourage Claude to fabricate data, results, or citations, or to assert facts it cannot verify. Where the skill relies on web search, it must instruct Claude to cite and to flag the unverifiable.
3. **Integrity-first.** The guiding principle is that *the researcher owns the contribution*. Changes that drift toward ghostwriting a thesis will not be accepted.
4. **Formal academic register.** Output guidance should keep Claude's deliverables in measured, precise scholarly prose.

## What is welcome

- Sharper or discipline-specific **peer-review rubrics** and committee critiques.
- Additional or refined **doctoral-system** coverage (e.g. specific national or institutional models).
- Better **templates** (roadmap, response-to-reviewers, learning roadmap, etc.).
- New **commands** that fill a genuine gap for independent researchers — added to `SKILL.md` and backed by a reference file.
- Corrections to academic conventions (citation styles, reporting standards, PRISMA, ethics).
- Documentation and discoverability improvements.

## How to contribute

1. Fork the repository and create a branch.
2. Make your change in `academic-researcher/` (edit `SKILL.md` and/or the relevant file in `references/` or `assets/`).
3. Keep `SKILL.md` lean — detailed protocols belong in `references/`, loaded on demand (progressive disclosure). Add a one-line entry to the command catalogue and the reference index for any new command or file.
4. If you change the command set, update the count and the command table in `README.md`.
5. Re-package the `.skill` file if you can (it is a ZIP of the `academic-researcher/` folder with `SKILL.md` at its root). The `description` field in the `SKILL.md` frontmatter must stay **under 1024 characters**.
6. Open a pull request describing what changed and why, and confirming the four ground rules above still hold.

## Reporting issues

Open an issue with a clear title and, where relevant, the command involved, what you expected, and what happened. Suggestions for new commands or rubrics are welcome as issues too.
