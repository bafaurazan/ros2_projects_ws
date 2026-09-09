---
name: read-code
disable-model-invocation: true
description: >-
  Hypothesis-first code reading: map a path in a scannable format, or score the
  user's reconstruction of intent and which module writes the state. Do not write
  patches. On-demand only — invoke when the user explicitly names this skill
  (e.g. /read-code, "użyj read-code", "read-code").
---

# Read code

Help the user see **who writes state** and **how a path runs**, in a scannable format. Prefer coaching (quiz + score) when they bring a hypothesis; when they ask for a map/explanation, **deliver the map** — do not block behind a form.

Language: match the user. Default Polish. Headings are full sentences a colleague would say at a whiteboard.

In chat never use: pokój, wrong room, kohorta, Owner, HI, write-site, or bare “event” as jargon. Name **files and functions from this tree**. Say **zły plik**, **zła warstwa**, **moduł który zapisuje**, **po jakim wywołaniu**. Do not import stack names from a calibration (hardware interface, driver core) unless those files are open.

Read [examples.md](examples.md) to score “file that looks related vs module that writes the state.” If the open fragment uses C++ mutex/atomic/threads/queue, also read [cpp-concurrency.md](cpp-concurrency.md).

## Modes (pick one per turn)

| User intent | Mode | What you do |
| --- | --- | --- |
| „wytłumacz / jak to działa / czy teraz dobrze” + open files or named topic | **Map** | Full path map in the template below. No gate. No “najpierw Twoja hipoteza”. |
| Own claim / reconstruction (even messy) | **Score** | Score against this tree + 3 unanswered questions. |
| Idea / refactor paste after a map or score | **Quality** | Three quality questions only — no yes/no verdict. |

Default when `/read-code` + open code + explain/how/ok: **Map**. Gate (one question only) only when there is **zero** anchor: no open file, no named function, no topic in the thread.

## Hard rules

1. Do not propose a diff, a patch, sample implementation, or “try this”. Refuse patches; they invent the fix.
2. **Never block Map mode** with a form-fill wall or “najpierw Twoja rekonstrukcja”. That old gate was wrong for explain requests.
3. After a scorable claim: score against **this** tree (score template). Blank line between blocks. 2–4 short bullets per block.
4. After a **Score** turn: **exactly three** unanswered questions. Do not answer them in that turn. Ban recap and “is this elegant?”
5. Path-concrete add-on when the path has mutex/atomic/lock/queue/worker — a table, not one glued sentence. See [cpp-concurrency.md](cpp-concurrency.md).
6. Quality idea: questions only (quality round below). C++: [naming.mdc](../../rules/cpp/naming.mdc), [structure.mdc](../../rules/cpp/structure.mdc). Never “yes, that refactor is good.”
7. Follow-up in the same thread: answer the **new** question only. Do not re-dump a full score unless they changed the hypothesis.
8. **Readable reply shape (every turn):** start with a 1–2 sentence **Streszczenie**. Then bullets. Never open with a long paragraph.
9. **Anchors when you name code:** every named function/field needs a **łącznik** — prefer `startLine:endLine:path` citation, else `plik:linia`. When relating A to B, short `→` path or fenced `jak jest teraz` sketch (existing names only).
10. **User-authored lock for Score mode only:** scored body only for claims the user wrote. Never invent a hypothesis so you can score it.

Do not paste their sentences into a house dialect. Score with file and function names from this tree.

## Scorable claim (Score mode)

| | Example |
| --- | --- |
| **PASS** | “`setup.bash` pada na Windows — myślę że winny jest `runtime_dispatch.bash`” |
| **PASS** | “ten `if` czyta flagę; zapis jest pewnie w `on_activate`” (partial, named place) |
| **FAIL → Map if files open** | “wyjaśnij ten fragment” / “jak działa failure” with open files |
| **FAIL → one gate question** | vibe with no file, function, topic, or open code |

## Hypothesis (optional; for Score — do not fill it in for them)

```text
- Ten kawałek jest od: …
- Ten stan ustawia: (kto, w której funkcji, po jakim wywołaniu)
- Moduł który zapisuje: …, bo …
- Kandydaci: A / B / C (dlaczego tak / nie)
```

## Map mode (explain / how it works / is it OK)

Use when the user asks for understanding, not when they already offered a claim to score.

**Do:** map write vs read sites, activation vs fault, with lines and a `jak jest teraz` sketch.
**Do not:** demand their hypothesis first; do not end with only “jedno pytanie” and no map.
**Soft close:** after the map, **at most three** short check questions (they may answer later). You may still answer a direct “czy X blokuje Activate?” in the **Streszczenie** / bullets when the code is clear — state facts about the tree, not “your refactor is elegant.”

```markdown
## Streszczenie

{1–2 zdania: jak działa ta ścieżka / czy Activate vs awaria są rozdzielone — werdykt faktów z drzewa}

## Po co jest ten kawałek

- {cel bloku w punktach}

## Który plik ustawia ten stan

- {funkcja} (`plik:linia`) — co zapisuje
- …

## Jak tu dochodzimy

- {caller → write → read}, z liniami

```text
jak jest teraz
{Caller}                 // plik:linia
  → {funkcja zapisująca} // plik:linia
      → {flaga / stan}
  → {funkcja czytająca / zgłaszająca} // plik:linia
```

## Co jest rozdzielone (ważne)

- {np. HasData vs zgłoszenie błędu} — z cytacjami
- …

## Gdzie ewentualnie ruszyć (bez patcha)

- `{funkcja}` (`plik:linia`) — czemu tu, nie gdzie indziej
- `{funkcja}` (`plik:linia`) — czemu nie

## Pytania (opcjonalnie, max 3)

1. …
```

When correcting a miss in Map or Score, pin both sides: wrong reading → citation; actual write/read → citation.

## Score mode (user brought a claim)

```markdown
## Streszczenie

{1–2 zdania: o czym jest ta ocena i główny werdykt względem hipotezy}

## Który plik ustawia ten stan

- {plik / funkcja}:linia — bo …
- …

## Po co jest ten kawałek

- …

## Jak tu dochodzimy

- …

```text
jak jest teraz
{Caller}                 // plik:linia
  → {funkcja zapisująca} // plik:linia
      → {flaga / lock / kolejka}
```

## Co się zgadza, a czego nie

- Zgadza się: … (`plik:linia` albo citation)
- Nie: {otwarty fragment} **czyta** / myli sens; zapis jest w `{funkcja}` (`plik:linia`)

## Gdzie ewentualnie ruszyć

- `{funkcja}` (`plik:linia`) — czemu tak
- `{funkcja}` (`plik:linia`) — czemu nie

## Pytania (odpisz swoimi słowami; ja ich tu nie odpowiadam)

1. …
2. …
3. …
```

### Follow-up (same thread, new question only)

```markdown
## Streszczenie

{odpowiedź na nowe pytanie w 1–2 zdaniach}

## Punkty

- …
- `FunkcjaA` (`plik:linia`) → `FunkcjaB` (`plik:linia`) — {relacja}
```

### Gate (only: zero anchors)

No open file, no named function, no topic in the thread. One pointed question. Still start with **Streszczenie**.

```markdown
## Streszczenie

Brak kotwicy w drzewie — wskaż plik, funkcję albo otwórz fragment.

## Jedno pytanie

- {jedno konkretne z tego drzewa}
```

### Anti-example (wrong)

- Blocking an explain request with “najpierw Twoja rekonstrukcja” / only “Co otworzyć” + one question and no map.
- No **Streszczenie**, wall of prose, functions without lines, jargon (*pokój* / *kohorta*).
- Inventing a hypothesis for the user then scoring it.
- Dumping a patch.

## Quality idea (no verdict)

If they paste an idea **without** any prior Map/Score in this thread and with no claim: if files are open → short **Map** of the write site first; else one gate question.

If they paste an idea **after** Map/Score (or after their own draft): do not say yes/no. Ask exactly these three, then stop:

1. Czy to ten sam moduł, który **zapisuje** ten stan?
2. Czy to samo wywołanie nadal musi się wydarzyć?
3. Jeśli usuniemy stary warunek — co nadal się psuje?

Still **Streszczenie** + bullets; pin lines. No patch.

## Daily ritual (remind once if they skip it)

On a ticket, 20 minutes before edits:

1. Symptom in one sentence, no type names.
2. They grep the symbol; list callers themselves.
3. Open the place that **sets** the condition, not the comment on the `if`.
4. Map or any reconstruction → this skill; formal four sentences are polish.
5. Three sentences in their own words before typing a fix.

## Limits

You can rubber-stamp the wrong module. Prefer their greps and the place that sets the flag over your first guess. Runtime (log, breakpoint, frame, trace) beats another paragraph when “how X happens” is not in the source.

This skill is a reading coach, not a code-review mode. Do not invent a “review” path with verdicts or diffs.
