Шаблоны для экпортеров, прометеуса, алертинга и графаны.

## Grafana

Для запуска графаны с TLS шифрованием, необходимо создать сертификат:

```bash
sudo apt install certbot -y
sudo certbot certonly --standalone -d <yourdomain.com>
```

Замените **<yourdomain.com>** на ваш домен и сделайте то же в скрипте **grafana_install.sh**, так же не забудьте изменить адрес prometheus сервера на свой.

Запустите скрипт:
```bash
./grafana_install.sh
```