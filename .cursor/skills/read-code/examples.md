# Calibrations — wrong layer / wrong file

Pattern in every example: symptom → file that *looks* related → module that actually **writes** the state. Use these to score hypotheses, not as a canned architecture for other repos.

In chat say **hardware interface** and **driver core**, never unlabeled HI. Never echo “room / pokój” to the user — even if you think that way internally.

## 1. C++ — failed Activate patched in the driver core

**Symptom:** after a failed device activate, retry still sees an error / stale handshake. Robot does not come up cleanly.

**Looks related:** `can_driver_core` (`CleanupAndResetState`, `OnFrame`, queue drain). The fragment talks about errors, queues, and Activate, so it feels like the bug.

**What the author meant:** driver core owns the CAN worker, frame queue, and per-device `IsActive` / error flags. The **hardware interface** owns *when* to activate, retry, roll back, and which devices participate in the ros2_control lifecycle (`on_activate`, power stages). A failed activate that leaves the stack unusable is often hardware-interface policy that *also* needs a driver-core invariant (do not process frames after stop; clear errors after join). Patching only the driver core is how you “fix activation” in the wrong layer.

**Hypothesis that would have caught it:**

- Ten kawałek jest od: kolejka ramek i stop workera w driver core.
- Ten stan ustawia: hardware interface woła `Activate` ponownie; driver core nadal ma error / stare ramki.
- Moduł który zapisuje: **hardware interface** (retry / rollback lifecycle), plus ewentualny invariant w driver core — nie „cała aktywacja w driver core”.
- Kandydaci: `husarz_hardware_interface` lifecycle/activate — tak (polityka retry); `CleanupAndResetState` — tylko jeśli worker nadal drenuje po `ClearAll`; konkretny driver `ActivateImpl` — tylko jeśli handshake tego urządzenia.

**Skill must not:** dump a patch for `can_device.hpp`. **Must:** force callers of Activate (hardware interface) before scoring a driver-core-only hypothesis.

**Example sketch (existing path, not a patch):**

```text
jak jest teraz
hardware interface Activate / retry
  → CanDevice::Activate
      → worker / kolejka / error flags nadal z poprzedniej próby
```

**Example nudge after the score (do not answer it in the same turn):** Kto nadal ustawia błąd albo kolejkuje ramkę po nieudanym `Activate` — otwórz to miejsce, nie komentarz przy `if`.

## 2. Bash — Distrobox will not enter, patched in the dispatcher

**Symptom:** `./scripts/setup.bash humble` fails on this machine (not Linux, missing distrobox, GPU/image, container create).

**Looks related:** [`runtime_dispatch.bash`](../../../scripts/bash_container/launch/runtime_dispatch.bash). It is the file `setup.bash` runs. It looks like “the entrypoint”.

**What the author meant:** dispatch only chooses a backend (`humble`/`jazzy` → Distrobox, `prod` → Docker). Platform refuse and `exec` live here. **Creating, entering, and session hook** live in [`distrobox_enter.bash`](../../../scripts/bash_container/src/distrobox/distrobox_enter.bash) and [`container_session.bash`](../../../scripts/bash_container/src/container_session.bash) (ROS, display, macros inside the container). A create/enter/GPU/image bug is not a dispatcher bug. Adding Distrobox logic to `runtime_dispatch.bash` is the bash analog of patching driver core for hardware-interface policy.

**Hypothesis that would have caught it:**

- Ten kawałek jest od: wyboru runtime i `exec` do backendu.
- Ten stan ustawia: backend tworzy/wchodzi do kontenera (albo sesja w bashrc kontenera).
- Moduł który zapisuje: `distrobox_enter.bash` / `container_session.bash` / `platform.bash` — zależnie czy to host, create, czy środowisko w środku.
- Kandydaci: `runtime_dispatch.bash` — nie, chyba że zły argument lub brakujący `exec`; `distrobox_enter.bash` — tak gdy create/enter; `container_session.bash` — tak gdy ROS/makra po wejściu.

**Skill must not:** rewrite `setup.bash`. **Must:** ask which layer failed (host check vs create vs in-container session) before accepting a dispatcher patch.

## 3. Any language — grep the symptom, miss who sets the flag

**Symptom:** “this `if` looks wrong.”

**Looks related:** the function that *reads* the flag.

**What the author meant:** the branch is a gate. The design lives where the flag is **set** (who assigns it, from which thread/callback, after which call). Comments that say “if X then Y” skip that path.

**Skill must:** send the user to callers and to the store/`export`/assignment of the condition. Score “which file writes this” on that module, not on the `if`.

## 4. Quality idea in the wrong module

**Symptom:** the user already scored the path, then says “I’ll extract a helper / add retry / clear errors in driver core — that’s cleaner.”

**Looks related:** a tidy change in the file they have open, not in the module that **sets** the state or decides retry.

**What the author meant:** a good-looking extract or extra `ClearAll` in driver core can still be the wrong layer if retry policy lives in the hardware interface. Quality questions are not a yes: same module as the writer? same call still required? if we drop the old condition, what still breaks?

**Skill must not:** say “yes, extract that.” **Must:** run the three quality questions, then stop.
