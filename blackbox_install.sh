useradd -M -u 1203 -s /bin/false blackbox-exporter

cat <<EOF> /etc/systemd/system/blackbox-exporter.service
[Unit]
Description=blackbox exporter
Requires=docker.service
After=docker.service
 
[Service]
Restart=always
ExecStartPre=-/usr/bin/docker rm blackbox-exporter
ExecStart=/usr/bin/docker run \
  --rm \
  --user=1203 \
  --publish=9115:9115 \
  --memory=64m \
  --name=blackbox-exporter \
  prom/blackbox-exporter:v0.22.0
ExecStop=/usr/bin/docker stop -t 10 blackbox-exporter
 
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start blackbox-exporter
sudo systemctl status blackbox-exporter
sudo systemctl enable blackbox-exporter