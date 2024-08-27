#!/bin/bash

# به روز رسانی و نصب بسته‌های مورد نیاز
apt-get update && apt-get upgrade -y && apt-get install curl socat git -y

# نصب Docker
curl -fsSL https://get.docker.com | sh

# کلون کردن مخزن Marzban-node
git clone https://github.com/Gozargah/Marzban-node

# ایجاد دایرکتوری
mkdir /var/lib/marzban-node

# تغییر دایرکتوری به پوشه Marzban-node
cd ~/Marzban-node

# ایجاد یا ویرایش فایل docker-compose.yml
cat <<EOF > docker-compose.yml
services:
  marzban-node:
    # build: .
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host

    environment:
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert.pem"
      SERVICE_PROTOCOL: "rest"
      
    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
EOF

# ایجاد یا ویرایش فایل ssl_client_cert.pem
cat <<EOF > /var/lib/marzban-node/ssl_client_cert.pem
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjQwNzMwMDI1MDE1WhgPMjEyNDA3MDYwMjUwMTVaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA2vd16JaW23bA
wHHfPzNHozsQIBKwXZpDpi449931VPtuAYTlJYm12+qztfiG/vDNo8PLmqbPHL1Q
g7uGpCDSBxM1XhGhbPpliN+L7JQLC6w7Nxv4HFaunv3a+6dSTH5Zs8VuiZYrTREI
dl6jL8pQxULzYXL3AZBT35k5sen1D5qAoQzVgg3WrdVGwYOE6vPOeXpf/qC5F+zp
VqXa5VhYdskXplHYhzO0j+skTzN0zApg5atOUlq9VH+YRJIWoq6uD/ra/q8z6o4P
AUx10iiB2mdYfDi9mGQg1oxuecPKe37IMDsxRTgcoWsR9gI1o5iTzqb5ujqbz1p8
nB6VhdPmu4rS+w3yUzgPquAAv4h4iqAed8SWE4IxTOo6m3cgG/CoMLWqAu5J2iJZ
rcG9Gq/rR75nuBI+VXDJfZhasrDN+Lre23X3BpdTGCQpSPy7n/eGtEBiAopCKujS
PxJoBBSJqTF5Q8Mf+sY1cLtwgeFs0drxNLEA3eh0PeP8Mtl0SMkMvGiNAujAKxxB
yLupq2g+eg+gMKO0Pzp+62fANQAL5JMqo3U+BVaxUkm4XlIJ1pUS0Kqk/U9X5ZjL
VqGH7GKsy1JVQ5dsvGryX2yXlAa86Z84JrO18ycX/TBj9itfNvQko/jmBd7Kk62P
R1FoBZlwAZAXhHEisJGIxLf1imsD/1MCAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
ZhDnmcU65oHer8JaZmDkEtWwTp+asR7ncwq2WJwGifNVFsYMeoG6kihrXxYDMTJt
dON2g6+3uGegXedFAQNTOA0PFDy2zqTvSD5pPgEjsYjPoBb7delowMoqJSKg6QMG
bpNwAFyk/sYzOgBBImQEXlTw5GTmPQGxjBgcGt6VmuPMGyLRrZx/ne0MLd5r8dmw
fYVe0Tbi2gz3BGgJPoIqQKzG33d1lA94GXez6q0qccr7WUhYFFDw6Xhnu9Dk9X+J
wm7sr+3V32jN31sY64vh/04oM30MmVM03rYDwd35lyqhX6oPN8nC0xyEuDP9A5+6
zA8+zriDHA8PXTx8FFVWt1s6wEf01mxWnm26FczCfsMrEhmBODWJl757Bh//k/M2
HDgdgq++H3fpKbbC31Y1ZdrY4ORYdYzgDu8+4tq0lYQ7g4DV/IvYJ1orwMRplVnk
ZhlVWrpxggjLJJef58GtrGBCQo1Xjz0q7IvYnkr3AQ26/I5DoHR4EOaP2MlgrAFE
T3dySmr908NQXENj49s4kMW03G1ldOqlQ2ysmksd1XfadIsBb+ExMpmzmnkqiBzp
8e8+w0ETyfQBEjD78W7K3ZLmkZblQaeHO6HAK/oW/zcwNL4g3ZoRzzAGp7Zp0JMr
Lz7JPyKlDnbtKIxzPyCmuLLHm66ERi1ApfONVtOpGMY=
-----END CERTIFICATE-----
EOF

# اجرای Docker Compose برای بالا آوردن سرویس
docker compose up -d
