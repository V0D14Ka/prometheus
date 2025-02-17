useradd -M -u 1202 -s /bin/false cadvisor

cat <<EOF> /etc/systemd/system/cadvisor.service
[Unit]
Description=cadvisor
Requires=docker.service
After=docker.service
 
[Service]
Restart=always
ExecStartPre=-/usr/bin/docker rm cadvisor
ExecStart=/usr/bin/docker run \
  --rm \
  --user=1202 \
  --publish=8080:8080 \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --privileged=true \
  --name=cadvisor \
  gcr.io/cadvisor/cadvisor:v0.44.0
 
ExecStop=/usr/bin/docker stop -t 10 cadvisor
 
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start cadvisor
sudo systemctl status cadvisor
sudo systemctl enable cadvisor