#!/bin/sh

if [ -e /tmp/certs/server.crt -a -e /tmp/certs/server.key ]; then
  # certsディレクトリに証明書が置いてあったらそちらを優先して配置する。
  mv /tmp/certs/server.crt /usr/local/apache2/conf/server.crt
  mv /tmp/certs/server.key /usr/local/apache2/conf/server.key
else
  # ApacheのSSL証明書を生成する。
  cd /tmp
  
  openssl genrsa 2048 > server.key
  
  openssl req -new -key server.key <<EOF > server.csr
JP
Tokyo
Minato-ku
Hoge Company
Fuga Section
idp.example.org



EOF
  
  openssl x509 -days 3650 -req -signkey server.key < server.csr > server.crt
  
  mv /tmp/server.key /usr/local/apache2/conf/server.key
  mv /tmp/server.crt /usr/local/apache2/conf/server.crt
  rm /tmp/server.csr
fi


