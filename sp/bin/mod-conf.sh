#!/bin/bash

if [ -e /tmp/certs/server.crt -a -e /tmp/certs/server.key ]; then
  # 如果 certs 目录中有证书，则优先采用目录中的证书。
  mv -f /tmp/certs/server.crt /etc/pki/tls/certs/localhost.crt
  mv -f /tmp/certs/server.key /etc/pki/tls/private/localhost.key
fi

# 将https的监听端口改为10443。
sed -i -e 's/Listen 443 https/Listen 10443 https/g' /etc/httpd/conf.d/ssl.conf 
sed -i -e 's/<VirtualHost _default_:443>/<VirtualHost _default_:10443>/g' /etc/httpd/conf.d/ssl.conf
