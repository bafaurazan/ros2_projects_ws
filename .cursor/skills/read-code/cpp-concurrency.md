# C++ concurrency on this path

Read this when the open fragment uses `std::mutex`, `std::atomic`, a worker thread, or a queue. Do not wait for the user to say `na tej ścieżce`, `co to chroni`, or name the primitive. Tie every sentence to a **named field** in the open files. No language course. No patch.

## What to name

For each primitive on the path, the user (then you score) must answer:

1. **What data** does this protect? (the members inside the lock / the atomic’s value — not “thread safety”)
2. **Who writes, who reads** — function names, which thread (caller, worker, ROS executor, ros2_control `read`/`write`)
3. **What goes wrong** if we delete the lock / use a plain `bool` instead of `atomic`

If they cannot name the data, they do not understand the primitive yet. Ask; do not lecture `std::mutex` in the abstract.

## Mutex vs atomic (only this distinction)

| Use on this path | Typical | Not |
| --- | --- | --- |
| `std::mutex` + `lock_guard` / `unique_lock` | Several members, a container, “check then act” (pop queue, drain, swap) | A single flag polled from another thread with no other data |
| `std::atomic` | One flag or enum (`running`, `active`, mode) loaded/stored from two threads | Replacing a lock around a `std::queue` / multi-field snapshot |

`lock_guard` = lock for this scope, unlock on return or throw. If they ask “why not lock/unlock by hand” — because a later `return` skips unlock.

Do not teach memory orders unless they point at `.load()` / `.store()` with an explicit order. Default sequential consistency is enough to say: “this load sees the other thread’s store of this flag.”

## Queues and workers

If there is `frame_queue_` (or similar) plus `*_mutex_` plus a worker:

- Mutex guards the queue (and usually “running” checks that race with push).
- Worker loop: wait / pop / handle. Stop path: set running false, join, **then** decide whether leftover items are dropped or processed — that choice is the invariant, not “the mutex exists.”
- `OnFrame` / producer that still `push`es after the worker stopped is a causal-path bug (who is allowed to queue), not a “need more locking” bug.

Score hypotheses that say “add a mutex” without naming the shared members as a miss.

## ros2_control / ROS threads (when those files are open)

`read` / `write` / `on_activate` run on the controller manager’s rules (often realtime for `read`/`write`). A CAN worker is a **different** thread. Crossing them without atomic/mutex on the shared flags/queue is the reason those primitives are there.

Do not say “realtime” unless the open code or comments do. Name the two functions and which thread each is on.

## Output (path-concrete add-on)

Add after **Jak tu dochodzimy** (or instead of repeating the score on a follow-up) when the scored path has those primitives, or the hypothesis is about that path. Still no patch. Match the user's language. Default Polish. One primitive at a time.

```markdown
## Co ten lock / atomic tu robi

| | |
| --- | --- |
| Pole | `{pole}` |
| Chroni | `{dane}` |
| Pisze | `{funkcja}` ({wątek}) |
| Czyta | `{funkcja}` ({wątek}) |
| Bez tego | `{wyścig}` |
```

If they want a fix: stop. They invent it after they can say that table out loud.
