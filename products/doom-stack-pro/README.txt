DOOM STACK PRO — Phase 1 Core
=============================

WHAT THIS IS
------------
The paid PRO core build of DOOM STACK. Real productivity app, not a
viral teaser. Single self-contained HTML file with full task CRUD,
local persistence, filters, repeats, subtasks, and the premium dark
neon DOOM STACK identity.

The FREE viral version (apps/doom-stack-free) is a separate product
and is left untouched by this build.

PHASE 1 CORE INCLUDES
---------------------
- Task CRUD: add, edit, delete, complete/incomplete, undo (6s window)
- Fields: title, priority, category, due, repeat, notes, subtasks,
  completed, completedAt, createdAt, updatedAt, id
- Priority: HIGH / MID / LOW (visual weight + sort priority)
- Category: WORK / LIFE / HEALTH / IDEA / ERRAND / DEADLINE
- Date filters: TODAY / TOMORROW / THIS WEEK / NEXT WEEK / ALL / DONE
  + specific date (HTML5 date picker)
- Repeat: NONE / DAILY / WEEKDAYS / WEEKLY / MONTHLY / CUSTOM
  (auto-creates next instance when a recurring task is completed)
- Notes: free-form, persisted
- Subtasks: nested per task with their own complete state
- Mental Load meter (top-right): HIGH=3, MID=2, LOW=1, capacity 30,
  tier ladder LIGHT / BUSY / HEAVY / DOOM (DOOM tier pulses)

PERSISTENCE
-----------
LocalStorage key:  doomStackPro:v1
Schema:
  {
    version: 1,
    tasks: [ <task>, ... ],
    ui: { activeFilter, selectedDate }
  }
Reload restores tasks, filter, and date.

VISUAL RULE
-----------
Visual destruction NEVER deletes task data. State.tasks is the source
of truth. Any visual state (filters, expansions, future physics) is
derived from it.

MOBILE
------
Designed mobile-first.
- iPhone 375x812 and Android 430x932 verified no overflow.
- Thumb-friendly tap targets (>= 28px).
- viewport-fit=cover, no zoom, double-tap zoom guard outside inputs.
- Bottom-sheet edit modal on phones; centered card on tablets/desktop.

KEYBOARD
--------
Add input: Enter = add task.
Subtask input (inside expanded task): Enter = add subtask.

DEVELOPER NOTES
---------------
- Single HTML, inline CSS + JS only. No external libs / fonts /
  network calls.
- Test surface: window.__doomStackPro exposes the full task API plus
  audit() returning { storageOk, hasState, filterReady, mobileReady,
  externalDeps } for hands-free verification.
- Future phases (not in this build): physics-stack visualization,
  analytics, history, export, sync.

FILES
-----
index.html      — the app
README.txt      — this file
quick-start.txt — fast intro for first-time users
