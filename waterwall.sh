#!/bin/bash

# 1. به‌روزرسانی و ارتقاء بسته‌ها
apt-get update
apt-get upgrade -y

# 2. دانلود و نصب WaterWall
wget https://github.com/radkesvat/WaterWall/releases/download/v1.30/Waterwall-linux-64.zip
unzip Waterwall-linux-64.zip
rm Waterwall-linux-64.zip
chmod u+x Waterwall

# 3. پرسش نوع سرور
echo "لطفا نوع سرور را انتخاب کنید:"
echo "1) سرور ایرانی"
echo "2) سرور خارج"
read -p "انتخاب شما (1 یا 2): " server_type

# 4. ایجاد و پیکربندی core.json
cat <<EOF > core.json
{
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
    "configs": [
        "config_name.json"
    ]
}
EOF

# 5. پیکربندی config_name.json
if [ "$server_type" -eq 1 ]; then
    echo "لطفا پورت، IP و سایت را وارد کنید:"
    read -p "پورت: " port
    read -p "IP خارج: " external_ip
    read -p "سایت: " site

    cat <<EOF > config_name.json
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
EOF

elif [ "$server_type" -eq 2 ]; then
    echo "لطفا پورت، IP و سایت را وارد کنید:"
    read -p "پورت: " port
    read -p "IP: " ip
    read -p "سایت: " site

    cat <<EOF > config_name.json
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
EOF
else
    echo "انتخاب نامعتبر است. لطفاً مجدداً تلاش کنید."
    exit 1
fi

echo "پیکربندی انجام شد."
