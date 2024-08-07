#!/bin/bash

# به‌روزرسانی سیستم
apt-get update && apt-get upgrade -y

# دانلود WaterWall
wget https://github.com/radkesvat/WaterWall/releases/download/v1.30/Waterwall-linux-64.zip

# استخراج فایل
unzip Waterwall-linux-64.zip
rm Waterwall-linux-64.zip

# تغییر مجوزها
chmod u+x Waterwall

# پرسیدن نوع سرور
echo "kojaii:"
echo "1: irani"
echo "2: khrji"
read -p " (1 ya 2): " server_type

# پرسیدن تعداد سرور
read -p " (ta 5): " server_count

# اعتبارسنجی تعداد سرورها
if ((server_count < 1 || server_count > 5)); then
  echo " 1 ta 5 ."
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

  if [ "$server_type" -eq 1 ]; then
    echo "iraniiii."
    read -p "port $i: " port
    read -p "ip kharj $i: " external_ip
    read -p "sni $i: " site

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
            "name": "reverse_server",
            "type": "ReverseServer",
            "settings": {},
            "next": "bridge1"
        },
        {
            "name": "pbserver",
            "type": "ProtoBufServer",
            "settings": {},
            "next": "reverse_server"
        },
        {
            "name": "h2server",
            "type": "Http2Server",
            "settings": {},
            "next": "pbserver"
        },
        {
            "name": "halfs",
            "type": "HalfDuplexServer",
            "settings": {},
            "next": "h2server"
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
    echo "kharji."
    read -p "port $i: " port
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
                "port": $port
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
                "address": "$ip",
                "port": 443
            }
        }
    ]
}
EOL
  fi
done

core_config+=$config_names
core_config+=']}'

echo "$core_config" > /root/core.json

# ایجاد فایل سرویس systemd
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

[Install]
WantedBy=multi-user.target
EOL

# فعال‌سازی و شروع سرویس
sudo systemctl daemon-reload
sudo systemctl enable waterwall.service
sudo systemctl start waterwall.service

echo "krdmsh absh omd."
