# Calibrations — wrong room

Pattern in every example: symptom → file that *looks* related → module that actually owns the decision. Use these to score hypotheses, not as a canned architecture for other repos.

## 1. C++ — failed Activate patched in the core

**Symptom:** after a failed device activate, retry still sees an error / stale handshake. Robot does not come up cleanly.

**Wrong room:** `can_driver_core` (`CleanupAndResetState`, `OnFrame`, queue drain). The fragment talks about errors, queues, and Activate, so it feels like the bug.

**What the author meant:** core owns the CAN worker, frame queue, and per-device `IsActive` / error flags. The **hardware interface** owns *when* to activate, retry, roll back, and which devices participate in the ros2_control lifecycle (`on_activate`, power stages). A failed activate that leaves the stack unusable is often an HI policy bug that *also* needs a core invariant (do not process frames after stop; clear errors after join). Patching only the core is how you “fix activation” in the wrong layer.

**Hypothesis that would have caught it:**

- Ten kawałek jest od: kolejka ramek i stop workera w core.
- Stan błędu po retry staje się prawdziwy gdy: HI woła Activate ponownie, a core nadal ma error / stare ramki.
- Owner zmiany: **HI** (retry / rollback lifecycle), plus ewentualny invariant w core — nie „cała aktywacja w core”.
- Kandydaci: `husarz_hardware_interface` lifecycle/activate — tak (polityka retry); `CleanupAndResetState` — tylko jeśli worker nadal drenuje po `ClearAll`; konkretny driver `ActivateImpl` — tylko jeśli handshake tego urządzenia.

**Skill must not:** dump a patch for `can_device.hpp`. **Must:** force callers of Activate (HI) before scoring a core-only hypothesis.

## 2. Bash — Distrobox will not enter, patched in the dispatcher

**Symptom:** `./scripts/setup.bash humble` fails on this machine (not Linux, missing distrobox, GPU/image, container create).

**Wrong room:** [`runtime_dispatch.bash`](../../../scripts/bash_container/launch/runtime_dispatch.bash). It is the file `setup.bash` runs. It looks like “the entrypoint”.

**What the author meant:** dispatch only chooses a backend (`humble`/`jazzy` → Distrobox, `prod` → Docker). Platform refuse and `exec` live here. **Creating, entering, and session hook** live in [`distrobox_enter.bash`](../../../scripts/bash_container/src/distrobox/distrobox_enter.bash) and [`container_session.bash`](../../../scripts/bash_container/src/container_session.bash) (ROS, display, macros inside the container). A create/enter/GPU/image bug is not a dispatcher bug. Adding Distrobox logic to `runtime_dispatch.bash` is the bash analog of patching `can_driver_core` for an HI policy.

**Hypothesis that would have caught it:**

- Ten kawałek jest od: wyboru runtime i `exec` do backendu.
- Błąd staje się prawdziwy gdy: backend tworzy/wchodzi do kontenera (albo sesja w bashrc kontenera).
- Owner zmiany: `distrobox_enter.bash` / `container_session.bash` / `platform.bash` — zależnie czy to host, create, czy środowisko w środku.
- Kandydaci: `runtime_dispatch.bash` — nie, chyba że zły argument lub brakujący `exec`; `distrobox_enter.bash` — tak gdy create/enter; `container_session.bash` — tak gdy ROS/makra po wejściu.

**Skill must not:** rewrite `setup.bash`. **Must:** ask which layer failed (host check vs create vs in-container session) before accepting a dispatcher patch.

## 3. Any language — grep the symptom, miss the writer

**Symptom:** “this `if` looks wrong.”

**Wrong room:** the function that *reads* the flag.

**What the author meant:** the branch is a gate. The design lives at the **write-site** (who sets the flag, from which thread/callback, after which event). Comments that say “if X then Y” skip that path.

**Skill must:** send the user to callers and to the store/`export`/assignment of the condition. Score “owner” on the writer’s module, not on the `if`.
