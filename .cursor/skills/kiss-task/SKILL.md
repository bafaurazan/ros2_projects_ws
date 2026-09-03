---
name: kiss-task
description: Enforce surgical, minimal KISS task execution in team codebases. Prevents scope creep and unsolicited refactoring, strictly bounds modifications, and quaranitines out-of-scope observations into chat/plan reports (never in code). MANDATORY TRIGGERS: 'kiss-task', 'kiss task', 'tryb kiss', 'w trybie kiss', 'poprawki kiss'.
---

# KISS Scoped Task

Enforce minimal, surgical code modifications strictly limited to the task goal. Prevent scope creep, unsolicited refactoring, and architectural drift in team codebases.

---

## Core Principles

1. **Zero Unsolicited Refactoring:** Never edit, reformat, or "clean up" code outside the immediate scope of the ticket.
2. **Minimal Viable Diff (KISS):** Choose the simplest, most direct solution that satisfies the requirement without unnecessary defensive layers, wrapper abstractions, or extra complexity.
3. **Out-of-Band Quarantine (Never in Code):** All out-of-scope observations, potential tech debt, or adjacent bugs are reported **strictly in chat or the plan file**. NEVER insert `TODO`, `FIXME`, or temporary comments into the codebase.
4. **Escalation Over Scope Expansion:** If fixing the issue cleanly requires altering cross-component contracts, state machines, or threading models, do NOT silently expand scope. Stop and escalate to `/claude-skills-llm-council`.

---

## 4-Phase Protocol

```
[New Task / Bugfix]
        │
        ▼
┌──────────────────────────────────────────────┐
│ Phase 1: Scope Lock (Pre-Edit Boundary)      │
│ - 1-sentence goal definition                 │
│ - Exact list of allowed files & functions    │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│ Phase 2: KISS Implementation (Surgical Diff) │
│ - Minimal direct fix                         │
│ - Zero adjacent modifications                │
│ - Zero unnecessary defensive layers          │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│ Phase 3: Out-of-Scope Quarantine (Report)    │
│ - Clean PR-ready diff                        │
│ - Markdown section in chat/plan only:        │
│   exact file:lines + snippet + reason        │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│ Phase 4: Escalation Gate (When to Council)   │
│ - Standard task -> finish in KISS mode       │
│ - Cross-contract / architecture -> Council   │
└──────────────────────────────────────────────┘
```

---

### Phase 1: Scope Lock (Before Modifying Code)

Before writing any code, explicitly define the boundary:
1. **Goal:** One clear sentence stating what this change achieves.
2. **Target Scope:** Explicitly list the exact file path(s) and function name(s) permitted to mutate. Every other file and function in the repository is strictly **read-only**.
3. **Success Criteria:** What concrete behavior will verify this task is complete.

---

### Phase 2: KISS Implementation (Surgical Diff)

1. Implement the minimal change necessary to satisfy the goal.
2. **Strict Negatives:**
   - Do NOT touch or reformat adjacent lines or functions.
   - Do NOT reorganize imports/includes unless directly required by the new code.
   - Do NOT add speculative retry loops, redundant defensive wrappers, or extra caching layers unless explicitly requested.
   - Respect existing project rules and conventions in `.cursor/rules/`.

---

### Phase 3: Out-of-Scope Quarantine (In Chat / Plan ONLY)

During code exploration, if you notice adjacent bugs, security issues, performance problems, or tech debt:
1. **DO NOT fix them in code.**
2. **DO NOT add `// TODO:` or `// FIXME:` comments in the code.**
3. **List them in the final chat response (and `.plan.md` if planning) under a dedicated section:**

```markdown
### Spostrzeżenia poza zakresem (Tylko do Twojej wiadomości)
- `path/to/file.ext:start_line-end_line` — [Krótki tytuł problemu]:
  ```language
  // Istniejący kod lub pseudokod
  if (!check()) { ... }
  ```
  *Dlaczego poza zakresem:* [1-2 zdania wyjaśniające, dlaczego to potencjalny problem i dlaczego zostawiono go bez zmian w ramach tego zadania].
```

---

### Phase 4: Escalation Gate (KISS vs. LLM Council)

Use this decision matrix to determine when to stay in KISS mode vs. when to escalate:

| Situation | Action |
| :--- | :--- |
| **Bugfix within a single module/function** | Stay in **KISS Mode** (surgical diff). |
| **Adding a feature within existing interface/contract** | Stay in **KISS Mode**. |
| **Refactoring requested by user** | Scope-lock the requested refactor in **KISS Mode**. |
| **Fix requires changing cross-module state machines** | **Escalate:** Stop and propose `/claude-skills-llm-council`. |
| **Fix requires redesigning threading or concurrency models** | **Escalate:** Stop and propose `/claude-skills-llm-council`. |
| **Trade-offs with no obvious right answer** | **Escalate:** Run `/claude-skills-llm-council` for multi-angle verdict. |
