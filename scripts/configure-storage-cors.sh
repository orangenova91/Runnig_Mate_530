#!/usr/bin/env bash
# Firebase Storage 버킷 CORS 설정 (웹에서 이미지 로드용)
# 사전 요구: Google Cloud SDK (gsutil) 설치
#   brew install google-cloud-sdk

set -euo pipefail

PROJECT_ID="${1:-running-date-2ee0d}"
BUCKET="gs://${PROJECT_ID}.firebasestorage.app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CORS_FILE="${SCRIPT_DIR}/../storage-cors.json"

if ! command -v gsutil &>/dev/null; then
  echo "gsutil이 없습니다. Google Cloud SDK를 설치해 주세요:"
  echo "  brew install google-cloud-sdk"
  exit 1
fi

echo "CORS 설정 적용: ${BUCKET}"
gsutil cors set "${CORS_FILE}" "${BUCKET}"
gsutil cors get "${BUCKET}"
echo "완료"
