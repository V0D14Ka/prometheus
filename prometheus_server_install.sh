useradd -M -u 1101 -s /bin/false prometheus
mkdir -p /etc/prometheus/rule_files # каталог конфигурации
mkdir -p /data/prometheus # каталог данных
chown -R prometheus /etc/prometheus /data/prometheus

cat <<EOF> /etc/systemd/system/prometheus.service
[Unit]
Description=prometheus
Requires=docker.service
After=docker.service
 
[Service]
Restart=on-failure
ExecStartPre=-/usr/bin/docker rm prometheus
ExecStart=/usr/bin/docker run \
  --rm \
  --user=1101 \
  --publish=9090:9090 \
  --memory=2048m \
  --volume=/etc/prometheus/:/etc/prometheus/ \
  --volume=/data/prometheus/:/prometheus/ \
  --name=prometheus \
  prom/prometheus:v2.30.3 \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --storage.tsdb.retention.time=14d
ExecStop=/usr/bin/docker stop -t 10 prometheus
 
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl status prometheus
sudo systemctl enable prometheus

cat <<EOF> /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 30s
 
# scrape exporter jobs
scrape_configs:
- job_name: 'prometheus'
  static_configs:
    - targets:
      - <hostname>:9090
- job_name: 'node'
  metrics_path: /metrics
  static_configs:
    - targets:
      - <hostname>:9100
- job_name: 'cadvisor'
  metrics_path: /metrics
  static_configs:
    - targets:
      - <hostname>:8080
- job_name: 'blackbox'
  metrics_path: /metrics
  static_configs:
    - targets:
      - <hostname>:9115
- job_name: 'blackbox-tcp'
  metrics_path: /probe
  params:
    module: [tcp_connect]
  static_configs:
    - targets:
      - github.com:443
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: <hostname>:9115
- job_name: 'blackbox-http'
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
      - https://github.com
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: <hostname>:9115

EOF