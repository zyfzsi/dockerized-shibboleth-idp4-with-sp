#!/bin/bash

# Shibboleth IdP启动需要很长时间，Shibboleth SP启动时获取IdP的元数据也需要时间。
# 由于有时会失败，请访问 Shibboleth IdP metadata的 URL 并等待网页返回 200。
status=0

while [ $status != '200' ]
do
  status=`curl -ks $IDP_METADATA_URL -o /dev/null -w '%{http_code}\n'`
  sleep 1
  echo "retrieving IdP Metada..."
done

# 获取 IdP metadata。 $ IDP_HOST 在环境变量中设置IdP 的主机名。
curl -k $IDP_METADATA_URL > /etc/shibboleth/partner-metadata.xml

chmod +x /etc/shibboleth/shibd-redhat

# 启动 Shibboleth SP。
/etc/shibboleth/shibd-redhat start

# 启动 OpenSSH。
echo "$SSH_PASSWD" | chpasswd
/usr/sbin/sshd &

# 启动apache。
exec httpd -DFOREGROUND
