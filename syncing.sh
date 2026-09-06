#!/usr/bin/env bash
set -euo pipefail

USER_NAME="ubuntu"
SEMESTER="SS26"

BASE_DIR="/home/${USER_NAME}"
PFERD_DIR="${BASE_DIR}/pferd"
NEXTCLOUD_DIR="${BASE_DIR}/Nextcloud/${SEMESTER}"

PFERD_BIN="${PFERD_DIR}/pferd-linux"
PFERD_CONFIG="${PFERD_DIR}/configs/config_${SEMESTER}.ini"
PFERD_CONFIG_TEMPLATE="${PFERD_DIR}/configs/config_template.ini"
LOG_FILE="${PFERD_DIR}/pferd.log"
LOGIN_PASS="${PFERD_DIR}/.pferd_pass"

RCLONE_CONFIG="${BASE_DIR}/.config/rclone/rclone.conf"
RCLONE_REMOTE="bwsyncshare_pferd"
RCLONE_REMOTE_PATH="KIT Sharing/${SEMESTER}"

# check if login data was given, if not fix it
if [[ ! -f "$LOGIN_PASS" ]]; then
    echo "ERROR: Missing credentials file: $LOGIN_PASS"
    echo "Create it with:"
    echo "  cp ${PFERD_DIR}/.pferd_pass.example $LOGIN_PASS"
    exit 1
fi

if [[ ! -f "$PFERD_CONFIG" ]]; then
    echo "[CONFIG] Creating config for ${SEMESTER}"

    sed "s/__SEMESTER__/${SEMESTER}/g" \
        "$PFERD_CONFIG_TEMPLATE" > "$PFERD_CONFIG"

    echo "Created:"
    echo "  $PFERD_CONFIG"
    echo "Edit the course rename rules, then run the script again."
    exit 0
fi

ts() { date -Is; }
trap 'ec=$?; echo "[ERROR] $(ts) exit=$ec" | tee -a "$LOG_FILE"; exit $ec' ERR

# keep only last 10k lines of log file, to keep it small
if [[ -f "$LOG_FILE" ]]; then
    tail -n 10000 "$LOG_FILE" > "${LOG_FILE}.tmp"
    mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

mkdir -p "$NEXTCLOUD_DIR"

# use pferd to get updated ilias content
echo "===== [START] $(ts) =====" | tee -a "$LOG_FILE"
echo "[PFERD] start $(ts)" | tee -a "$LOG_FILE"
p_start=$(date +%s)

"$PFERD_BIN" -c "$PFERD_CONFIG" >> "$LOG_FILE" 2>&1

echo "[PFERD] end   $(ts) (duration: $(( $(date +%s) - p_start ))s)" | tee -a "$LOG_FILE"

# sync it via rclone
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
