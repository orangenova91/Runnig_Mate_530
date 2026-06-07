#!/bin/bash
# flutterfire가 firebase CLI를 찾을 수 있도록 PATH 설정 후 configure 실행

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$ROOT/node_modules/.bin:$HOME/.pub-cache/bin:$HOME/flutter/bin:$PATH"

echo "firebase: $(command -v firebase)"
firebase --version || { echo "Firebase CLI not found. Run: cd \"$ROOT\" && npm install"; exit 1; }

cd "$ROOT"
flutterfire configure \
  --project=running-date-2ee0d \
  --platforms=web \
  --overwrite-firebase-options
