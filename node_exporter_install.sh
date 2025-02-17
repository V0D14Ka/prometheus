useradd -M -u 1201 -s /bin/false node_exporter

cat <<EOF> /etc/systemd/system/node-exporter.service
[Unit]
Description=node exporter
Requires=docker.service
After=docker.service
 
[Service]
Restart=on-failure
ExecStartPre=-/usr/bin/docker rm node-exporter
ExecStart=/usr/bin/docker run \
  --rm \
  --user=1201 \
  --publish=9100:9100 \
  --memory=64m \
  --volume="/proc:/host/proc:ro" \
  --volume="/sys:/host/sys:ro" \
  --volume="/:/rootfs:ro" \
  --name=node-exporter \
  prom/node-exporter:v1.1.2
ExecStop=/usr/bin/docker stop -t 10 node-exporter
 
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node-exporter 
sudo systemctl status node-exporter 
sudo systemctl enable node-exporter 