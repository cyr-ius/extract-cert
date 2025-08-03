#!/usr/bin/env sh

# -----   WARNING  ------
# jq package required
# -----------------------
WORKING_PATH="/var/extractcert"
LAST_MTIME_FILE="${WORKING_PATH}/last_acme_mtime"
CERT_DIR="${WORKING_PATH}/certs"
ACME_FILE="${WORKING_PATH}/acme/acme.json"

# sanity checks
if [ ! -f "$ACME_FILE" ]; then
  echo "ERROR: acme.json not found at $ACME_FILE"
  exit 1
fi

CURRENT_MTIME=$(stat -c %Y "$ACME_FILE")
LAST_MTIME=$(cat "$LAST_MTIME_FILE" 2>/dev/null || echo 0)

if [ "$CURRENT_MTIME" -le "$LAST_MTIME" ]; then
  echo "acme.json not modified since last run. Nothing to do."
  exit 0
fi

# count certificates
CERTS_COUNT=$(jq '.letsencrypt.Certificates | length' "$ACME_FILE" 2>/dev/null)
if [ -z "$CERTS_COUNT" ] || [ "$CERTS_COUNT" -eq 0 ]; then
  echo "No certificates found in acme.json"
  exit 0
fi

echo "acme.json updated, extracting $CERTS_COUNT certificate(s)..."

i=0
while [ "$i" -lt "$CERTS_COUNT" ]; do
  main=$(jq -r ".letsencrypt.Certificates[$i].domain.main" "$ACME_FILE")
  if [ -z "$main" ] || [ "$main" = "null" ]; then
    echo "Skipping entry $i: missing domain.main"
    i=$((i + 1))
    continue
  fi

  destdir="${CERT_DIR}/${main}"
  mkdir -p "${destdir}" && chmod 600 -R "${destdir}"

  # extract cert and key
  jq -r ".letsencrypt.Certificates[$i].certificate" "$ACME_FILE" | base64 -d > "${destdir}/fullchain.pem"
  jq -r ".letsencrypt.Certificates[$i].key" "$ACME_FILE" | base64 -d > "${destdir}/privkey.pem"
    
  # lock down the files
  chmod 600 "${destdir}/"*.pem

  echo "Extracted certificates for ${main} into ${destdir}"
  
  i=$((i + 1))
done

# update mtime record only after successful extraction
echo "$CURRENT_MTIME" > "$LAST_MTIME_FILE"