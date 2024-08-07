#!/bin/bash

sudo timedatectl set-ntp false
sudo timedatectl set-timezone UTC

# به‌روزرسانی سیستم
apt-get update && apt-get upgrade -y

# نصب unzip در صورت عدم وجود
apt-get install unzip -y

# پرسیدن نوع عملیات

echo "chikar konim kako :"

echo "1: to kharjiii" 

echo "2: to iraniii "

echo "3: hazfkon"

read -p " (1 ya 2 ya 3): " operation_type

if [ "$operation_type" -eq 3 ]; then
  # توقف و غیرفعال کردن سرویس
  systemctl stop waterwall.service
  systemctl disable waterwall.service

  # حذف فایل‌های سرویس

  rm -f /etc/systemd/system/waterwall.service

  # حذف تمامی فایل‌ها و برنامه‌های نصب شده
  rm -f /root/Waterwall
  rm -f /root/config_name*.json
  rm -f /root/core.json

  echo "paksh krdam."
  exit 0
fi

# دانلود WaterWall
wget https://github.com/radkesvat/WaterWall/releases/download/v1.30/Waterwall-linux-64.zip

# استخراج فایل
unzip Waterwall-linux-64.zip
rm Waterwall-linux-64.zip

# تغییر مجوزها
chmod u+x Waterwall

# پرسیدن نوع سرور
if [ "$operation_type" -eq 1 ]; then
  echo "khraj mikony."
elif [ "$operation_type" -eq 2 ]; then
  echo "iran mikony."
else
  echo "انتخاب نامعتبر است."
  exit 1
fi

# پرسیدن تعداد سرورها
read -p "(1 / 5): " server_count

# اعتبارسنجی تعداد سرورها
if ((server_count < 1 || server_count > 5)); then
  echo "1 taaaa 5 ."
  exit 1
fi

# تنظیم فایل core.json
config_names=""
core_config='{
    "log": {
        "path": "log/",
        "core": {
            "loglevel": "DEBUG",
            "file": "core.log",
            "console": true
        },
        "network": {
            "loglevel": "DEBUG",
            "file": "network.log",
            "console": true
        },
        "dns": {
            "loglevel": "SILENT",
            "file": "dns.log",
            "console": false
        }
    },
    "dns": {},
    "misc": {
        "workers": 8,
        "ram-profile": "server",
        "libs-path": "libs/"
    },
    "configs": ['

for (( i=1; i<=server_count; i++ )); do
  config_name="config_name$i.json"
  config_names+='"'$config_name'"'
  if [ "$i" -lt "$server_count" ]; then
    config_names+=','
  fi

  if [ "$operation_type" -eq 1 ]; then
    read -p "ip kharj $i: " external_ip
    read -p "sni $i: " site

    cat <<EOL > /root/$config_name
{
    "name": "reverse_reality_grpc_client_hd_multiport_client",
    "nodes": [
        {
            "name": "outbound_to_core",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address": "127.0.0.1",
                "port": "dest_context->port"
            }
        },
        {
            "name": "header",
            "type": "HeaderServer",
            "settings": {
                "override": "dest_context->port"
            },
            "next": "outbound_to_core"
        },
        {
            "name": "bridge1",
            "type": "Bridge",
            "settings": {
                "pair": "bridge2"
            },
            "next": "header"
        },
        {
            "name": "bridge2",
            "type": "Bridge",
            "settings": {
                "pair": "bridge1"
            },
            "next": "reverse_client"
        },
        {
            "name": "reverse_client",
            "type": "ReverseClient",
            "settings": {
                "minimum-unused": 16
            },
            "next": "pbclient"
        },
        {
            "name": "pbclient",
            "type": "ProtoBufClient",
            "settings": {},
            "next": "h2client"
        },
        {
            "name": "h2client",
            "type": "Http2Client",
            "settings": {
                "host": "$site",
                "port": 443,
                "path": "/",
                "content-type": "application/grpc",
                "concurrency": 128
            },
            "next": "halfc"
        },
        {
            "name": "halfc",
            "type": "HalfDuplexClient",
            "next": "reality_client"
        },
        {
            "name": "reality_client",
            "type": "RealityClient",
            "settings": {
                "sni": "$site",
                "password": "CwnwTgwISo"
            },
            "next": "outbound_to_iran"
        },
        {
            "name": "outbound_to_iran",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address": "$external_ip",
                "port": 443
            }
        }
    ]
}
EOL
  else

    read -p "ip iran $i: " ip

    read -p "sni $i: " site

    cat <<EOL > /root/$config_name
{
    "name": "reverse_reality_grpc_client_hd_multiport_client",
    "nodes": [
        {
            "name": "outbound_to_core",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address": "127.0.0.1",
                "port": [23, 65535],
            }
        },
        {
            "name": "header",
            "type": "HeaderServer",
            "settings": {
                "field": "Port"
            },
            "next": "bridge2"
        },
        {
            "name": "bridge2",
            "type": "Bridge",
            "settings": {
                "pair": "bridge1"
            }
        },
        {
            "name": "bridge1",
            "type": "Bridge",
            "settings": {
                "pair": "bridge2"
            }
        },
        {
            "name": "reverse_client",
            "type": "ReverseClient",
            "settings": {
                "minimum-unused": 16
            },
            "next": "pbclient"
        },
        {
            "name": "pbclient",
            "type": "ProtoBufClient",
            "settings": {},
            "next": "h2client"
        },
        {
            "name": "h2client",
            "type": "Http2Client",
            "settings": {
                "host": "$site",
                "port": 443,
                "path": "/",
                "content-type": "application/grpc",
                "concurrency": 128
            },
            "next": "halfc"
        },
        {
            "name": "halfc",
            "type": "HalfDuplexClient",
            "next": "reality_client"
        },
        {
            "name": "reality_client",
            "type": "RealityClient",
            "settings": {
                "sni": "$site",
                "password": "CwnwTgwISo"
            },
            "next": "outbound_to_iran"
        },
        {
            "name": "outbound_to_iran",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address": "$ip",
                "port": 443
            }
        }
    ]
}
EOL
  fi
done

core_config+="$config_names"
core_config+="
    ]
}
"

# نوشتن فایل core.json
echo "$core_config" > /root/core.json


# ادامه ایجاد فایل سرویس waterwall.service
cat <<EOL > /etc/systemd/system/waterwall.service
[Unit]
Description=Waterwall Service
After=network.target

[Service]
ExecStart=/root/Waterwall
WorkingDirectory=/root
Restart=always
User=root
Group=root
RestartSec=30  # تنظیم زمان بین ریستارت‌ها به 30 ثانیه

[Install]
WantedBy=multi-user.target
EOL

# بارگذاری مجدد فایل‌های سرویس
systemctl daemon-reload

# فعال کردن و راه‌اندازی سرویس
systemctl enable waterwall.service
systemctl start waterwall.service

echo "سرویس Waterwall به‌درستی نصب و راه‌اندازی شد."

# پرسیدن زمان‌بندی ریستارت سرویس
echo "har chand sait restart konm:"
echo "1: 1 Hore "
echo "2: 2 Hore "
echo "3: 3 Hore "
echo "4: 4 Hore "
echo "5: 5 Hore "
echo "6: 6 Hore "
read -p "bgo kako  (1 ta 6): " restart_interval

case "$restart_interval" in
  1)
    interval_sec=3600
    ;;
  2)
    interval_sec=7200
    ;;
  3)
    interval_sec=10800
    ;;
  4)
    interval_sec=14400
    ;;
  5)
    interval_sec=18000
    ;;
  6)
    interval_sec=21600
    ;;
  *)
    echo "انتخاب نامعتبر است."
    exit 1
    ;;
esac

# تنظیم زمان‌بندی ریستارت سرویس
crontab -l | { cat; echo "*/$((interval_sec/3600)) * * * * systemctl restart waterwall.service"; } | crontab -

echo "bos ${restart_interval} ok shok ."

echo "mehrdad konet pare shod ."
echo  "kakoooooooooooooooooo ."
