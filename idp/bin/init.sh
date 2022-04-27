#!/bin/sh

# 启动 OpenSSH。
echo "$SSH_PASSWD" | chpasswd
/usr/sbin/sshd &

# 启动jetty。
$JAVA_HOME/bin/java -jar $JETTY_HOME/start.jar $JETTY_JAVA_ARGS

