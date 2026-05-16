# .github/copilot-instructions.md

Purpose
- Short repo-specific instructions for GitHub Copilot / AI agents when opening this repository.

Quick start (common commands)
- **Activate virtualenv:** `source venv/bin/activate`
- **Install dependencies (if present):** `pip install -r requirements.txt || true`
- **Run Web UI (from README):** `python webui.py`

Project layout hints
- **Data root:** `data/` — put raw audio under `data/raw/` (or create `yuan_raw/` when following docs/豆包.md).
- **Virtualenv:** `venv/` (project includes a `venv/` scaffold); prefer using that for local runs.

Behavioral guidance
- See [CLAUDE.md](../CLAUDE.md) for agent behavior and code change conventions.

Where to look first
- `README.md` — environment and run instructions.
- `docs/` — task-specific workflows (audio prep, slicing, ASR).

What not to do
- Do not run destructive shell commands or delete large data without confirming with the repo owner.
