#!/bin/bash

# تنظیم متغیرهای محلی برای استفاده از UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# به‌روزرسانی سیستم
apt-get update && apt-get upgrade -y

# نصب unzip در صورت عدم وجود
apt-get install unzip -y

# پرسیدن نوع عملیات
echo "لطفاً نوع عملیات را انتخاب کنید:"
echo "1: تنظیم سرور ایرانی"
echo "2: تنظیم سرور خارجی"
echo "3: حذف تمامی فایل‌ها و برنامه‌های نصب شده و لغو سرویس‌ها"
read -p "انتخاب شما (1، 2 یا 3): " operation_type

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

  echo "تمامی فایل‌ها و برنامه‌های نصب شده حذف شدند و سرویس‌ها لغو شدند."
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
  echo "شما سرور ایرانی را انتخاب کردید."
elif [ "$operation_type" -eq 2 ]; then
  echo "شما سرور خارجی را انتخاب کردید."
else
  echo "انتخاب نامعتبر است."
  exit 1
fi

# پرسیدن تعداد سرورها
read -p "تعداد سرورها (حداکثر 5): " server_count

# اعتبارسنجی تعداد سرورها
if ((server_count < 1 || server_count > 5)); then
  echo "تعداد سرورها باید بین 1 تا 5 باشد."
  exit 1
fi

# تنظیم فایل core.json
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
config_names=""

# تنظیم فایل‌های config_name.json بر اساس انتخاب سرور
for (( i=1; i<=server_count; i++ )); do
  config_name="config_name$i.json"
  config_names+='"'$config_name'"'
  if [ "$i" -lt "$server_count" ]; then
    config_names+=','
  fi

  if [ "$operation_type" -eq 1 ]; then
    read -p "پورت برای سرور $i: " port
    read -p "آیپی خارجی برای سرور $i: " external_ip
    read -p "سایت برای سرور $i: " site

    cat <<EOL > /root/$config_name
{
    "name": "reverse_reality_grpc_hd_multiport",
    "nodes": [
        {
            "name": "users_inbound",
            "type": "TcpListener",
            "settings": {
                "address": "0.0.0.0",
                "port": $port,
                "nodelay": true
            },
            "next": "header"
        },
        {
            "name": "header",
            "type": "HeaderClient",
            "settings": {
                "data": "src_context->port"
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
            "name": "reality_server",
            "type": "RealityServer",
            "settings": {
                "destination": "reality_dest",
                "password": "CwnwTgwISo"
            },
            "next": "halfs"
        },
        {
            "name": "halfs",
            "type": "HalfDuplexServer",
            "settings": {},
            "next": "reality_server"
        },
        {
            "name": "h2server",
            "type": "Http2Server",
            "settings": {},
            "next": "halfs"
        },
        {
            "name": "pbserver",
            "type": "ProtoBufServer",
            "settings": {},
            "next": "h2server"
        },
        {
            "name": "reverse_server",
            "type": "ReverseServer",
            "settings": {},
            "next": "pbserver"
        },
        {
            "name": "kharej_inbound",
            "type": "TcpListener",
            "settings": {
                "address": "0.0.0.0",
                "port": 443,
                "nodelay": true,
                "whitelist": [
                    "$external_ip/32"
                ]
            },
            "next": "reality_server"
        },
        {
            "name": "reality_dest",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address": "$site",
                "port": 443
            }
        }
    ]
}
EOL
  else
    read -p "پورت برای سرور $i: " port
    read -p "آیپی برای سرور $i: " ip
    read -p "سایت برای سرور $i: " site

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
                "port": $port
            },
            "next": "header"
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
            "name": "reality_client",
            "type": "RealityClient",
            "settings": {
                "password": "CwnwTgwISo",
                "destination": "reality_dest"
            },
            "next": "bridge1"
        },
        {
            "name": "halfc",
            "type": "HalfDuplexClient",
            "settings": {},
            "next": "reality_client"
        },
        {
            "name": "h2client",
            "type": "Http2Client",
            "settings": {},
            "next": "halfc"
        },
        {
            "name": "pbclient",
            "type": "ProtoBufClient",
            "settings": {},
            "next": "h2client"
        },
        {
            "name": "reverse_client",
            "type": "ReverseClient",
            "settings": {},
            "next": "pbclient"
        },
        {
            "name": "core_inbound",
            "type": "TcpListener",
            "settings": {
                "address": "$ip",
                "port": 443,
                "nodelay": true
            },
            "next": "reverse_client"
        },
        {
            "name": "reality_dest",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address": "$site",
                "port": 443
            }
        }
    ]
}
EOL
  fi
done

# تکمیل تنظیمات core.json
core_config+=$config_names']}' 

echo "$core_config" > /root/core.json

# ایجاد فایل سرویس
cat <<EOL > /etc/systemd/system/waterwall.service
[Unit]
Description=```bash
Waterwall Service
After=network.target

[Service]
ExecStart=/root/Waterwall
WorkingDirectory=/root
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOL

# بارگذاری مجدد تنظیمات systemd و فعال‌سازی سرویس
systemctl daemon-reload
systemctl enable waterwall.service
systemctl start waterwall.service

echo "سرویس Waterwall ایجاد و فعال شد."
