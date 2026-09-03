#!/bin/sh
set -eu

config=/opt/janus/etc/janus/janus.transport.http.jcfg
sed -i -E 's/^[[:space:]]*port[[:space:]]*=.*/port = 8188/' "$config"
sed -i -E 's/^[[:space:]]*rtp_port_range[[:space:]]*=.*/rtp_port_range = "10000-10200"/' /opt/janus/etc/janus/janus.jcfg
exec /opt/janus/bin/janus --nat-1-1="$HOST_IP"
