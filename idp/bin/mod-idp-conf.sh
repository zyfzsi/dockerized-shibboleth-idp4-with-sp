#!/bin/bash

# 应用补丁文件,用于修改 Shibboleth 配置文件（例如attribute-resolver）。
cp /opt/shibboleth-idp/conf/attribute-resolver-ldap.xml /opt/shibboleth-idp/conf/attribute-resolver.xml && \

cd /opt/shibboleth-idp

for file in `\find /tmp/patch -maxdepth 1 -type f`; do
    patch -b -p0 < $file
done

sed -i -e s/validUntil=\"[^\"\]*\"/validUntil=\"2030-01-01T00:00:00\.999Z\"/ /opt/shibboleth-idp/metadata/idp-metadata.xml
