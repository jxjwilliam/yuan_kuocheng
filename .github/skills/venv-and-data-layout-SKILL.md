# Skill: venv-and-data-layout

Description
- Lightweight skill describing common local commands and the repository's expected data layout. Useful for new contributors and automated agents.

Usage
- Activate the provided virtual environment (macOS / Linux):

```bash
source venv/bin/activate
```

- Install dependencies (if a `requirements.txt` exists):

```bash
pip install -r requirements.txt || true
```

- Run the Web UI (follow `README.md` for environment specifics):

```bash
python webui.py
```

Data layout (recommended)
- `data/raw/` — place original audio files (WAV preferred) here.
- `yuan_raw/` — alternative dataset folder referenced in `docs/豆包.md` for RVC training.
- `output/` or `output/*` — training and processing outputs (create when running pipelines).

Small tips
- Use 16-bit mono WAV, 44100 or 40000 Hz depending on the pipeline.
- If copying files from another machine, use `scp -P <port> file user@host:/path/to/repo/data/raw/`.

Where to find more
- See [README.md](../README.md) and files under `docs/` for full workflows.
