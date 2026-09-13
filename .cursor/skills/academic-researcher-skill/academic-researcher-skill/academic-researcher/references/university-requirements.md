# University Requirements — Institutional Intelligence for the Route

Used by `/university`. This command is the program's **institutional-intelligence service**: it researches and compiles how specific universities run the PhD-by-publication route, so the roadmap is built against a real target institution's rules rather than generic assumptions. It functions as a continually-researched reference on the route's institutional landscape — not a static wiki, but a live compilation Claude assembles from each institution's current regulations.

Because the "done" bar, the number of papers, the eligibility rules, and the examination format **all vary by institution and set the parameters of the entire program**, this command is often the right first step before `/roadmap`: what the target university requires determines what the roadmap must deliver.

## What the command does

1. **Profiles a named institution** — given a university, search its official postgraduate research / graduate-school regulations and compile its PhD-by-publication policy against the parameter taxonomy below.
2. **Surveys the landscape** — given a discipline, country, or constraint ("UK universities that accept external candidates"), identify institutions that offer the route and summarize how their offerings differ.
3. **Compares institutions** — present two or more side by side on the parameters that matter, to support a choice of where to register.
4. **Feeds the roadmap** — translate the findings into the project profile (system, papers required, done-bar, synthesis requirement, timeline), and update `roadmap.md` so every downstream command respects the real rules.

## The two models (clarify which an institution offers)

- **Retrospective — "PhD by prior / published work."** For candidates who already hold a coherent body of published work. Often restricted to a university's own staff or alumni, sometimes with a minimum period since first publication. The submission is the existing papers plus a critical synthesis/commentary, examined by viva.
- **Prospective — "PhD with publication" / "thesis including published works" (Australia: TIP) / Scandinavian compilation thesis.** The candidate undertakes a normal doctoral program but the thesis body is article-based — papers written (and ideally published) during candidature, plus the synthesis chapter. This is the more widely available model and the usual fit for someone starting out.

Identify which model applies, because eligibility and timeline differ sharply between them.

## Parameter taxonomy (compile these per institution)

- **Model offered** — retrospective, prospective, or both.
- **Eligibility** — open to external candidates, or staff/alumni only; any minimum time since first publication (retrospective route).
- **Number of papers** — typical range three to eight; the regulation's minimum.
- **"Done" bar** — must papers be *published*, *accepted*, *submitted/under review*, or merely *publishable*? This single parameter most affects the timeline.
- **Authorship rules** — requirement to be sole or principal author; how co-authored papers are credited and documented.
- **Synthesis / commentary requirement** — whether an integrative chapter or critical commentary is required, and its expected length.
- **Examination** — viva voce (UK/EU/AUS) or committee defense (US); internal/external examiner arrangements.
- **Time limits, residency, and fees** — registration period, any in-person residency, and cost.
- **Discipline norms** — some fields and faculties support the route far more than others within the same university.

## Honesty and tool conduct

- **Search; do not assert from memory.** University regulations change; compile each profile from the institution's *current* official pages via web search, cite the source, and paraphrase (do not reproduce regulation text verbatim).
- **Flag the authority limit plainly.** What Claude compiles is a researched starting point, not a binding statement of policy. Regulations are revised, and faculties interpret them differently. Direct the candidate to confirm with the institution's graduate school or doctoral college and the current research-degree regulations before relying on any parameter.
- **Mark the unverifiable.** If an institution's policy cannot be found or confirmed, say so rather than inferring it; an honest gap is safer than a confident guess about a rule that governs the whole program.
- **Note the geography.** The route is well established in the UK, Australia, New Zealand, Scandinavia, and parts of Europe and South Africa; in the US it more often takes the form of an article-based ("three-paper") dissertation rather than a distinct named route. Set expectations accordingly when surveying a region.