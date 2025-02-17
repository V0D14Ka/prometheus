# Создать пользователя и подготовить каталоги для конфигурационных файлов и хранения данных
useradd -M -u 1102 -s /bin/false grafana
mkdir -p /etc/grafana/provisioning/datasources # каталог декларативного описания источников данных
mkdir /etc/grafana/provisioning/dashboards # каталог декларативного описания дашбордов
mkdir -p /data/grafana/dashboards # каталог данных
chown -R grafana /etc/grafana/ /data/grafana

# Создать файл декларативного описания источников данных /etc/grafana/provisioning/datasources/main.yml (здесь <hostname> – DNS запись или IP адрес вашего сервера)

cat <<EOF> /etc/grafana/provisioning/datasources/main.yml

apiVersion: 1
 
datasources:
  - name: Prometheus
    type: prometheus
    version: 1
    access: proxy
    orgId: 1
    basicAuth: false
    editable: false
    url: http://localhost:9090

EOF

# Создать файл декларативного описания дашбордов /etc/grafana/provisioning/dashboards/main.yml

cat <<EOF> /etc/grafana/provisioning/dashboards/main.yml
apiVersion: 1
 
providers:
- name: 'main'
  orgId: 1
  folder: ''
  type: file
  disableDeletion: false
  editable: True
  options:
    path: /var/lib/grafana/dashboards

EOF

# Добавить дашборд Node Exporter Full в каталог /data/grafana/dashboards

cd ~/ && git clone https://github.com/rfmoz/grafana-dashboards
sudo cp grafana-dashboards/prometheus/node-exporter-full.json /data/grafana/dashboards/

# Создать /etc/systemd/system/grafana.service

cat <<EOF> /etc/systemd/system/grafana.service
[Unit]
Description=grafana
Requires=docker.service
After=docker.service
 
[Service]
Restart=on-failure
ExecStartPre=-/usr/bin/docker rm grafana
ExecStart=/usr/bin/docker run \
  --rm \
  --user=1102 \
  --publish=3000:3000 \
  --memory=1024m \
  --volume=/etc/grafana/provisioning:/etc/grafana/provisioning \
  --volume=/data/grafana:/var/lib/grafana \
  --name=grafana \
  grafana/grafana:9.2.8
ExecStop=/usr/bin/docker stop -t 10 grafana
 
[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl start grafana
sudo systemctl status grafana
sudo systemctl enable grafana