FROM centos:centos7

# 定义 shibboleth Idp 主要metadata地址的 URL。
ENV IDP_METADATA_URL=http://idp:8080/idp/shibboleth

# 为 SSH 登录定义密码。
ENV SSH_PASSWD "root:Docker!"

# 复制 yum Shibboleth官方repo，用于安装shibboleth
COPY repo/shibboleth.repo /etc/yum.repos.d/

# 安装 Shibboleth SP 模块和其他必需的项目。
RUN yum -y update \
    && yum -y install wget \
    && yum -y install httpd shibboleth mod_ssl php \
    && yum -y clean all

# 将httpd默认的ServerName修改为https，这样可以强制返回https地址。
RUN sed -i -e 's/#ServerName www.example.com:80/ServerName https:\/\/www.example.com:443/' /etc/httpd/conf/httpd.conf

# 复制 Shibboleth SP 启动脚本到容器中。
COPY bin/init.sh /usr/local/bin/    
RUN chmod +x /usr/local/bin/init.sh

# 将 Shibboleth SP 配置文件复制到容器中。
COPY conf/attribute-map.xml /etc/shibboleth/
COPY conf/shibboleth2.xml /etc/shibboleth/

# 将测试 SP 的 PHP 文件复制到容器中。
RUN mkdir /var/www/html/secure

COPY app/testsp.php /var/www/html/secure

# 将位于 certs 目录中的证书复制到容器中。
# 在容器端，脚本控制优先于此证书。
RUN mkdir /tmp/certs
COPY certs/* /tmp/certs/

# 修改 Shibboleth SP 模块的配置文件。
COPY bin/mod-conf.sh /usr/local/bin/
RUN chmod 750 /usr/local/bin/mod-conf.sh && \
    /usr/local/bin/mod-conf.sh

# 安装 OpenSSH。
RUN yum -y install openssh-server && \
    ssh-keygen -A && \
    sed -i -e 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    sed -i -e 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

# 启动 Shibboleth SP 。
CMD ["/usr/local/bin/init.sh"]

EXPOSE 10443 80 2222
