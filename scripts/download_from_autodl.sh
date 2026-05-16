#!/usr/bin/env bash
# Simple helper to download the artifact tarball from AutoDL to local machine.
# Usage: ./scripts/download_from_autodl.sh <host> <port> [remote_path] [dest_dir] [-i identity_file]

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <host> <port> [remote_path] [dest_dir] [-i identity_file]"
  echo "Example: $0 autodl.example.com 46840 /root/autodl-tmp/yuan_artifacts.tar.gz ~/downloads -i ~/.ssh/id_rsa"
  exit 1
fi

HOST="$1"
PORT="$2"
REMOTE_PATH="${3:-/root/autodl-tmp/yuan_artifacts.tar.gz}"
DEST_DIR="${4:-./downloads}"
shift 2

IDENTITY=""
while [ $# -gt 0 ]; do
  case "$1" in
    -i) IDENTITY="$2"; shift 2;;
    --) shift; break;;
    *) shift;;
  esac
done

mkdir -p "$DEST_DIR"

SCP_CMD=(scp -P "$PORT")
if [ -n "$IDENTITY" ]; then
  SCP_CMD+=( -i "$IDENTITY" )
fi
SCP_CMD+=( "root@${HOST}:${REMOTE_PATH}" "$DEST_DIR/" )

echo "Running: ${SCP_CMD[*]}"
"${SCP_CMD[@]}"

TAR_LOCAL="$DEST_DIR/$(basename "$REMOTE_PATH")"
if [ -f "$TAR_LOCAL" ]; then
  if [ -f "$TAR_LOCAL.sha256" ]; then
    echo "Verifying sha256..."
    sha256sum -c "$TAR_LOCAL.sha256" || echo "SHA256 check failed or unsupported format; please verify manually."
  else
    echo "No sha256 file found next to tarball. You can manually verify with: sha256sum $TAR_LOCAL"
  fi
  echo "Extraction to $DEST_DIR"
  tar -xzf "$TAR_LOCAL" -C "$DEST_DIR"
fi

echo "Download and extraction finished. Files are in: $DEST_DIR"
