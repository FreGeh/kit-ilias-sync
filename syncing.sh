#!/usr/bin/env bash
set -euo pipefail

USER_NAME="ubuntu"
SEMESTER="SS26"

BASE_DIR="/home/${USER_NAME}"
PFERD_DIR="${BASE_DIR}/pferd"
NEXTCLOUD_DIR="${BASE_DIR}/Nextcloud/${SEMESTER}"

PFERD_BIN="${PFERD_DIR}/pferd"
PFERD_CONFIG="${PFERD_DIR}/config_${SEMESTER}.ini"
LOG_FILE="${PFERD_DIR}/pferd.log"

RCLONE_CONFIG="${BASE_DIR}/.config/rclone/rclone.conf"
RCLONE_REMOTE="bwsyncshare_pferd"
RCLONE_REMOTE_PATH="KIT Sharing/${SEMESTER}"

ts() { date -Is; }
trap 'ec=$?; echo "[ERROR] $(ts) exit=$ec" | tee -a "$LOG_FILE"; exit $ec' ERR

mkdir -p "$NEXTCLOUD_DIR"

echo "===== [START] $(ts) =====" | tee -a "$LOG_FILE"
echo "[PFERD] start $(ts)" | tee -a "$LOG_FILE"
p_start=$(date +%s)

"$PFERD_BIN" -c "$PFERD_CONFIG" >> "$LOG_FILE" 2>&1

echo "[PFERD] end   $(ts) (duration: $(( $(date +%s) - p_start ))s)" | tee -a "$LOG_FILE"
echo "[RCLONE] start $(ts)" | tee -a "$LOG_FILE"
r_start=$(date +%s)

rclone --config "$RCLONE_CONFIG" copy -u \
  "$NEXTCLOUD_DIR" \
  "${RCLONE_REMOTE}:${RCLONE_REMOTE_PATH}" \
  --checksum \
  --create-empty-src-dirs \
  --log-file "$LOG_FILE" \
  --log-level INFO

echo "[RCLONE] end   $(ts) (duration: $(( $(date +%s) - r_start ))s)" | tee -a "$LOG_FILE"
echo "===== [DONE]  $(ts) =====" | tee -a "$LOG_FILE"
