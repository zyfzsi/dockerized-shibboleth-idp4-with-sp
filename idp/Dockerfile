FROM zyfzsi/dockerized-shibboleth-idp4:latest

# 定义ssh密码
ENV SSH_PASSWD "root:Docker!"

ADD shibboleth-idp/ /opt/shibboleth-idp/

RUN apk --no-cache add patch

# 将修改Shibboleth 配置文件（例如attribute-resolver）的脚本复制到容器。
COPY bin/mod-idp-conf.sh /usr/local/bin/

# 将 Shibboleth 配置文件（例如attribute-resolver）的补丁复制到容器中。
RUN mkdir /tmp/patch
COPY patch/* /tmp/patch/

# 运行修改 Shibboleth 配置文件的脚本（例如attribute-resolver）。
RUN chmod 750 /usr/local/bin/mod-idp-conf.sh \
    && /usr/local/bin/mod-idp-conf.sh

# 安装 OpenSSH。
RUN apk add openssh && \
    ssh-keygen -A && \
    sed -i -e 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 将启动脚本复制到容器中。
COPY bin/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

CMD ["/usr/local/bin/init.sh"]

EXPOSE 2222
