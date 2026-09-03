#!/bin/sh
set -eu

RING=$(command -v ring)
JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")

if [ ! -f /var/cs/.initialized ]; then
  useradd -r -m hc_user
  useradd -r -m es_user
  useradd -r -m cs_user
  mkdir -p /var/cs/hc_instance /var/cs/es_instance /var/cs/cs_instance
  chown hc_user:hc_user /var/cs/hc_instance
  chown es_user:es_user /var/cs/es_instance
  chown cs_user:cs_user /var/cs/cs_instance

  "$RING" hazelcast instance create --dir /var/cs/hc_instance --owner hc_user
  "$RING" elasticsearch instance create --dir /var/cs/es_instance --owner es_user
  "$RING" cs instance create --dir /var/cs/cs_instance --owner cs_user
  "$RING" hazelcast --instance hc_instance service create --init-system sysv --username hc_user --java-home "$JAVA_HOME" --stopped
  "$RING" elasticsearch --instance es_instance service create --init-system sysv --username es_user --java-home "$JAVA_HOME" --stopped
  "$RING" cs --instance cs_instance service create --init-system sysv --username cs_user --java-home "$JAVA_HOME" --stopped
  "$RING" cs --instance cs_instance jdbc pools --name common set-params --url 'jdbc:postgresql://postgres:5432/cs_db?currentSchema=public'
  "$RING" cs --instance cs_instance jdbc pools --name common set-params --username db_user
  "$RING" cs --instance cs_instance jdbc pools --name common set-params --password "$DB_PASSWORD"
  "$RING" cs --instance cs_instance jdbc pools --name privileged set-params --url 'jdbc:postgresql://postgres:5432/cs_db?currentSchema=public'
  "$RING" cs --instance cs_instance jdbc pools --name privileged set-params --username db_user
  "$RING" cs --instance cs_instance jdbc pools --name privileged set-params --password "$DB_PASSWORD"
  "$RING" cs --instance cs_instance websocket set-params --hostname 0.0.0.0 --port 8086
  cat > /var/cs/cs_instance/config/video.yml <<'EOF'
video:
  enabled: true
  conference-server-based-member-limit: 34
  conference-server-based-threshold: 3
  max-bandwidth: 2000
  max-reference-width: 1280
  max-reference-height: 720
  max-reference-fps: 30
EOF
  touch /var/cs/.initialized
fi

"$RING" hazelcast --instance hc_instance service start --init-system sysv
"$RING" elasticsearch --instance es_instance service start --init-system sysv
"$RING" cs --instance cs_instance service start --init-system sysv
exec tail -f /dev/null
