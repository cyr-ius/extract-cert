#!/usr/bin/env sh

WATCH_DIR="/var/extractcert/acme"
TARGET="acme.json"
/usr/bin/extractCert.sh
inotifywait -m -e close_write,moved_to,create "$WATCH_DIR" |
while read -r path event file; do
  [ "$file" != "$TARGET" ] && continue
  echo "[$(date +'%F %T')] Le fichier $file a déclenché l'événement: $event"
  /usr/bin/extractCert.sh
done