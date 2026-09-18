#!/bin/bash
# 🐺 ERLİK Ultra-Lightweight Sync Engine (Tailscale P2P / SSH Bridge)
# Zero-RAM Overhead: Executes on cron / interval, syncs SQLite deltas, then terminates immediately.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DB_PATH="$DIR/erlik.db"
HOSTNAME_LOCAL="$(hostname -s)"
PEER_HOST="mbp" # ~/.ssh/config alias for 100.126.131.105
PEER_PATH="/Users/halil/code/erlik"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

function sync_peer() {
    # Check if peer is reachable via Tailscale with quick 3-second timeout
    if ! ssh -o ConnectTimeout=3 -o BatchMode=yes "$PEER_HOST" "echo ok" >/dev/null 2>&1; then
        exit 0
    fi

    SYNC_DIR="$DIR/sync"
    mkdir -p "$SYNC_DIR"
    LOCAL_DUMP="$SYNC_DIR/delta_${HOSTNAME_LOCAL}.sql"

    # 1. Export local records with explicit column mapping to avoid ID collision
    sqlite3 "$DB_PATH" "SELECT 'INSERT OR IGNORE INTO erlik_heartbeats (timestamp, device_id, app_name, bundle_id, category, project_name, git_branch, window_title, duration_seconds, is_afk) VALUES (''' || timestamp || ''', ''' || REPLACE(IFNULL(device_id, 'MacBookPro-Local'), '''', '''''') || ''', ''' || REPLACE(app_name, '''', '''''') || ''', ''' || REPLACE(bundle_id, '''', '''''') || ''', ''' || REPLACE(category, '''', '''''') || ''', ''' || REPLACE(IFNULL(project_name, 'Genel'), '''', '''''') || ''', ''' || REPLACE(IFNULL(git_branch, '-'), '''', '''''') || ''', ''' || REPLACE(IFNULL(window_title, ''), '''', '''''') || ''', ' || duration_seconds || ', ' || is_afk || ');' FROM erlik_heartbeats WHERE timestamp >= datetime('now', '-2 hours');" > "$LOCAL_DUMP"

    # 2. Push dump to remote peer and import
    if [ -s "$LOCAL_DUMP" ]; then
        scp -q -o ConnectTimeout=3 "$LOCAL_DUMP" "$PEER_HOST:$PEER_PATH/sync/" 2>/dev/null
        ssh -o ConnectTimeout=3 "$PEER_HOST" "sqlite3 '$PEER_PATH/erlik.db' < '$PEER_PATH/sync/delta_${HOSTNAME_LOCAL}.sql' 2>/dev/null; rm -f '$PEER_PATH/sync/delta_${HOSTNAME_LOCAL}.sql'" 2>/dev/null
    fi

    # 3. Pull remote peer's delta if available
    REMOTE_DUMP_NAME="delta_remote.sql"
    ssh -o ConnectTimeout=3 "$PEER_HOST" "mkdir -p '$PEER_PATH/sync'; sqlite3 '$PEER_PATH/erlik.db' \"SELECT 'INSERT OR IGNORE INTO erlik_heartbeats (timestamp, device_id, app_name, bundle_id, category, project_name, git_branch, window_title, duration_seconds, is_afk) VALUES (''' || timestamp || ''', ''' || REPLACE(IFNULL(device_id, 'MacBookPro'), '''', '''''') || ''', ''' || REPLACE(app_name, '''', '''''') || ''', ''' || REPLACE(bundle_id, '''', '''''') || ''', ''' || REPLACE(category, '''', '''''') || ''', ''' || REPLACE(IFNULL(project_name, 'Genel'), '''', '''''') || ''', ''' || REPLACE(IFNULL(git_branch, '-'), '''', '''''') || ''', ''' || REPLACE(IFNULL(window_title, ''), '''', '''''') || ''', ' || duration_seconds || ', ' || is_afk || ');' FROM erlik_heartbeats WHERE timestamp >= datetime('now', '-2 hours');\" > '$PEER_PATH/sync/$REMOTE_DUMP_NAME' 2>/dev/null" 2>/dev/null

    scp -q -o ConnectTimeout=3 "$PEER_HOST:$PEER_PATH/sync/$REMOTE_DUMP_NAME" "$SYNC_DIR/" 2>/dev/null
    if [ -s "$SYNC_DIR/$REMOTE_DUMP_NAME" ]; then
        sqlite3 "$DB_PATH" < "$SYNC_DIR/$REMOTE_DUMP_NAME" 2>/dev/null
        rm -f "$SYNC_DIR/$REMOTE_DUMP_NAME"
    fi
}

sync_peer
