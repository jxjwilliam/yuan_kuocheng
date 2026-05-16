# AGENTS.md — Guidance for AI coding agents

Purpose
- Quick, actionable instructions to help AI coding agents be productive in this repo.

Quick links
- Project README: [README.md](README.md)
- Behavioral guidelines for LLMs: [CLAUDE.md](CLAUDE.md)
- Project docs folder: [docs](docs)

How to get started (agent checklist)
1. Read the `CLAUDE.md` behavioral guidelines before making changes.
2. Open [README.md](README.md) for environment and run instructions.
3. Look in `docs/` for task-specific workflows (audio prep, slicing, ASR).
4. Use the project virtualenv at `venv/` if present; prefer the commands in `README.md`.

Conventions for edits
- Keep changes surgical and minimal; touch only files required to complete the task.
- If a change affects behavior, add a small, focused test or a runnable snippet and verify locally.
- Prefer linking to existing docs rather than copying them (see link list above).

Environment & common commands
- This repository uses Python and includes a `venv/` layout. Typical commands:

```bash
# activate virtualenv
source venv/bin/activate

# install dependencies (if requirements.txt exists)
pip install -r requirements.txt || true

# follow README.md for project-specific steps (training / preprocessing)
```

What agents should *not* do
- Do not assume tests exist; do not run destructive commands without asking.
- Do not refactor large areas; keep changes narrowly scoped to the task.

Where to find important files
- `README.md` — project setup and run instructions.
- `CLAUDE.md` — agent behavior and modification rules.
- `config.py` — runtime or configuration hints.
- `docs/` — task-specific guides (audio, denoise, slicing, ASR).

Next suggested agent customizations
- Create a `.github/copilot-instructions.md` or extend `AGENTS.md` with language-specific run scripts.
- Add a lightweight skill that exposes common commands (venv activation, data layout) for new contributors.

If anything here looks wrong or you'd like more detail for a sub-area (tests, CI, frontend), say which area.
