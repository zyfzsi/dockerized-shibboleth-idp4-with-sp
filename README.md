##### 这是一个用于在 Docker 环境中运行 Shibboleth 的 Dockerfile。 

# 使用方法

# 1.从GitHub获取所需文件

克隆以下 GitHub。
https://github.com/zyfzsi/dockerized-shibboleth-idp4-with-sp.git



## 2.生成 Shibboleth idp 配置文件

首先在idp目录下创建一个Shibboleth idp配置文件（/opt/shibboleth-idp下的文件）。此容器是用于生成 Shibboleth idp 配置文件的临时容器。执行以下命令。执行完成后，将在执行命令的同一目录中创建一个名为 shibboleth-idp 的目录。这是 Shibboleth idp 配置文件。

```shell
$ cd dockerized-shibboleth-idp4-with-sp/idp
$ docker run -it -v $(pwd):/ext-mount --rm noriyukitakei/dockerized-shibboleth-idp4 gen-idp-conf.sh
Generating Shibboleth idp Configuration... This may take some time.
shibboleth-identity-provider-4.0.1.tar.gz: OK
... omit ...
INFO [net.shibboleth.idp.installer.BuildWar:99] - Creating war file /opt/shibboleth-idp/war/idp.war

BUILD SUCCESSFUL
Total time: 4 seconds
Finished generating Shibboleth idp Configuration!!
```

这里有一点很重要，您可以通过在上面运行 gen-idp-conf.sh 时提供环境变量来自定义生成的 Shibboleth idp 配置文件。可指定的环境变量及其内容如下。如果未指定，将设置以下初始值。



| 环境变量名称          | 内容                                                         | 初始值                                  |
| --------------------- | ------------------------------------------------------------ | --------------------------------------- |
| idp_VERSION           | 指定 Shibboleth idp 的版本。                                 | 4.0.1                                   |
| idp_HASH              | 指定 Shibboleth idp 下载文件 (tar.gz) 的哈希值。请务必将其指定为带有 idp_VERSION 的集合。 | Hash                                    |
| idp_ENTITY_ID         | 指定 Shibboleth idp 的实体 ID。                              | https: //idp.example.org/idp/shibboleth |
| idp_HOST_NAME         | 指定 Shibboleth idp 的主机名。                               | idp.example.org                         |
| idp_SCOPE             | 指定 Shibboleth idp 的SCOPE。                                | example.org                             |
| idp_KEYSTORE_PASSWORD | 指定 Shibboleth idp 创建的密钥密码。                         | 密码                                    |
| idp_SEALER_PASSWORD   | 指定存储用于加密 Shibboleth idp 身份验证信息的密钥密码。     | 密码                                    |



要指定上述环境变量，请执行以下操作，每个变量拼接一个-e：



```shell
$ docker run -it -v $(pwd):/ext-mount \
-e idp_ENTITY_ID=https://idp.example.org/idp/shibboleth \
-e idp_HOST_NAME=idp.example.org \
--rm shibboleth gen-idp-conf.sh
```



请注意，这个脚本还包括部署Shibboleth SP，请按如下方式设置 Host Name 和 SAML Entity ID。如果环境变量中没有指定任何内容，则将设置以下初始值。
    HOST NAME：idp.example.org
    SAML ENTITY ID：https: //idp.example.org/idp/shibboleth



## 3.[根据需要] 编辑 Shibboleth idp 配置文件

根据需要编辑在 idp 目录中创建的 Shibboleth idp 配置文件。例如，添加其他的SP。



## 4.[根据需要] 更改 LDAP 初始数据

转到 openldap 目录。data/init.ldif 这里以ldif格式写入要提交给OpenLDAP的初始数据。默认是生成以下条目：
■ BIND DN
 DN：cn = admin，dc = example，dc = org
 密码：password
■ 测试用户
 DN：uid = test001，ou = people，dc = example，dc = org
 密码：password

## 5.[根据需要]更改测试SP应用程序

sp/app/testsp.php 是测试 SP 的 PHP 脚本。默认情况下，登录的用户 ID 如下所示，但您可以根据需要进行更改。顺便说一句，传递给 SP 的唯一属性是 uid。

testsp.php

```php
<?php echo getenv('REMOTE_USER');  ?>
```



## 6.启动Docker容器

请移至项目的根目录并执行以下命令。容器会自行创建并启动。

```shell
$ cd ..
$ docker-compose up -d
```



# 测试方法

## (1) 在宿主机的 hosts 文件中进行如下设置。

```shell
127.0.0.1 idp.example.org
127.0.0.1 sp.example.org
```



## (2) 请在宿主机中访问以下网址。

https://sp.example.org:10443/secure/testsp.php



## (3) 将显示 Shibboleth 登录屏幕，输入以下用户名和密码。

​    用户名：test001
​    密码：password



## (4)如果屏幕上显示用户ID，则表示成功。



# 更改 Shibboleth idp 配置文件

如果要更改 Shibboleth idp 配置文件，请更改 idp/shibboleth-idp 中的文件并执行以下命令。

```shell
$ docker-compose build idp;docker-compose up -d
```



# Jetty启动参数

通过在 idp 容器中设置一个名为 JETTY_JAVA_ARGS 的环境变量，您可以自由更改 Jetty 启动参数。环境变量的详细信息如下。

| 环境变量名称    | 内容                                                | 初始值                                                       |
| --------------- | --------------------------------------------------- | ------------------------------------------------------------ |
| JETTY_JAVA_ARGS | 在 Jetty 中启动 Shibboleth idp 时指定其他 Java 选项 | jetty.home = /opt/jetty-home jetty.base = /opt/jetty-base -Djetty.sslContext.keyStorePassword = storepwd -Djetty.sslContext.keyStorePath = etc / keystore |



如果要指定最大内存，请在 docker-compose.yml 中修改。

docker-compose.yml

```yaml
version: '3'
services:
  ldap:
    container_name: ldap
    build:
      context: ldap
    ports:

   - '389:389'
     vironment:
           LDAP_DOMAIN: "example.org"
           LDAP_ADMIN_PASSWORD: "password"
       idp:
         container_name: idp
         build:
           context: idp
         depends_on:
        - ldap
          rts:
             - 443:8443
               80:8080
                   environment:
                     LDAP_HOST: "ldap"
                     JETTY_JAVA_ARGS: "jetty.home=/opt/jetty-home jetty.base=/opt/jetty-base -Djetty.sslContext.keyStorePassword=storepwd -Djetty.sslContext.keyStorePath=etc/keystore -Xmx1024m"
                 sp:
                   container_name: sp
                   build:
                     context: sp
                   depends_on:
                  - idp
                    rts:
                       - 10443:443
```

