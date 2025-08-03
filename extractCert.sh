#!/usr/bin/env sh

# -----   WARNING  ------
# jq package deb required
# -----------------------
WORKING_PATH="/var/extractcert"
LAST_MTIME_FILE="${WORKING_PATH}/last_acme_mtime"
CERT_DIR="${WORKING_PATH}/certs"
ACME_FILE="${WORKING_PATH}/acme/acme.json"
CURRENT_MTIME=$(stat -c %Y "$ACME_FILE")
LAST_MTIME=$(cat "$LAST_MTIME_FILE" 2>/dev/null || echo 0)

if [ "$CURRENT_MTIME" -gt "$LAST_MTIME" ]; then
  mkdir -p "$CERT_DIR" && chmod 600 -R "$CERT_DIR"
  echo "$CURRENT_MTIME" > "$LAST_MTIME_FILE"
  echo "acme.json updated, extracting..."
  jq -r '.letsencrypt.Certificates[0].certificate' "$ACME_FILE" | base64 -d > "$CERT_DIR/fullchain.pem"
  jq -r '.letsencrypt.Certificates[0].key' "$ACME_FILE" | base64 -d > "$CERT_DIR/privkey.pem"
  chmod 600 "$CERT_DIR"/*.pem
  echo "Certificates extracted."
fi
