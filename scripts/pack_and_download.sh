#!/usr/bin/env bash
# Pack selected model artifacts and reference wavs into a tarball for easy download.
# Usage (run inside AutoDL container):
#   ./scripts/pack_and_download.sh -o /root/autodl-tmp/yuan_artifacts.tar.gz

set -euo pipefail

OUT="/root/autodl-tmp/yuan_artifacts_$(date +%Y%m%d-%H%M).tar.gz"
TMPDIR="/root/autodl-tmp/artifacts_for_download"
NUM_REFS=10

while [[ $# -gt 0 ]]; do
  case $1 in
    -o|--out) OUT="$2"; shift 2;;
    -n|--num-refs) NUM_REFS="$2"; shift 2;;
    -h|--help) echo "Usage: $0 [-o /path/to/out.tar.gz] [-n num_reference_wavs]"; exit 0;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

echo "Creating artifact package..."
rm -rf "$TMPDIR"
mkdir -p "$TMPDIR/reference_wavs"
mkdir -p "$(dirname "$OUT")"

# Copy SoVITS weights (common locations)
echo "Collecting SoVITS weights..."
if [ -d SoVITS_weights_v2Pro ]; then
  cp -v SoVITS_weights_v2Pro/* "$TMPDIR/" 2>/dev/null || true
fi
if [ -d SoVITS_weights_v3 ]; then
  cp -v SoVITS_weights_v3/* "$TMPDIR/" 2>/dev/null || true
fi

# Copy GPT weights
echo "Collecting GPT weights..."
for d in GPT_weights*; do
  if [ -d "$d" ]; then
    cp -v "$d"/* "$TMPDIR/" 2>/dev/null || true
  fi
done

# Copy logs/config
echo "Collecting logs and configs..."
if [ -d logs ]; then
  mkdir -p "$TMPDIR/logs"
  cp -v logs/* "$TMPDIR/logs/" 2>/dev/null || true
fi
if [ -f config.json ]; then
  cp -v config.json "$TMPDIR/" 2>/dev/null || true
fi

# Copy example reference wavs from output slicer
echo "Collecting reference wavs (up to $NUM_REFS)..."
if [ -d output/slicer_opt ]; then
  ls -1 output/slicer_opt | head -n "$NUM_REFS" | while read -r f; do
    cp -v "output/slicer_opt/$f" "$TMPDIR/reference_wavs/" || true
  done
fi

# Copy original raw mp3s if present
echo "Collecting raw audio files..."
if [ -d raw ]; then
  mkdir -p "$TMPDIR/raw_myvoice"
  if [ -d raw/myvoice ]; then
    cp -v raw/myvoice/* "$TMPDIR/raw_myvoice/" 2>/dev/null || true
  fi
fi

echo "Packing to $OUT"
tar -C "$(dirname "$TMPDIR")" -czf "$OUT" "$(basename "$TMPDIR")"

echo "Computing SHA256..."
sha256sum "$OUT" > "$OUT".sha256 || true

echo
echo "Artifact package created: $OUT"
echo "SHA256:"
cat "$OUT".sha256 || true
echo
echo "To download from your local machine (example using scp):"
echo "  scp -P <port> root@<autodl-host>:$OUT ./"
echo
echo "If you prefer to upload the tarball to a temporary HTTP location, run any simple file server or upload to cloud storage and then download from your machine."

exit 0
