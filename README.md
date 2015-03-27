
# MailServer Backend
- Postfix: MTA
- Dovecot: MDA
- MySQL: 保存域、虚拟用户及别名信息

# 使用指南
### 1)build or pull image
build image from source:
```shell
$ docker build -t hqingyi/docker_emailserver --rm ./docker_emailserver
```
or pull from hub:
```shell
$ docker pull hqingyi/docker_emailserver
```

### 2)初始化Container（不建议publish3306数据库端口，root密码已配置在postfix及dovecot中，若要publish，请修改root密码及相应修改配置文件；或者为在服务器中为数据库端口添加防火墙，使用SSH登录）
```shell
$ docker run --name emailserver -p 25:25 -p 465:465 -p 587:587 -p 993:993 -p 995:995 -d -it hqingyi/docker_emailserver /bin/bash
```

### 3)进入container环境
```shell
$ docker exec -it emailserver /bin/bash
```

### 4)在container中初始化域及相关用户（注意：域用户密码使用SHA512-CRYPT加密；请把example.com替成自己的域名）
```shell
$ mysql -proot < /root/mysql_init.sql
$ mysql -proot -e "insert into mailserver.virtual_domains(name) values('example.com');" mailserver
$ mysql -proot -e "insert into mailserver.virtual_users(domain_id, password, email) values(1, encrypt('plain_password',concat('$6$', substring(sha(rand()), -16))), 'postmaster@example.com');" mailserver
```

### 5)修改postfix的hostname，重启postfix
```shell
$ sed -e 's/^\(myhostname\).*$/\1 = example.com/' -i /etc/postfix/main.cf
$ service postfix restart
```

### 6)为域名添加对应的解析服务，Enjoy it!

# 其他
### 参考
- [#Linode#Email with Postfix, Dovecot, and MySQL](https://www.linode.com/docs/email/postfix/email-with-postfix-dovecot-and-mysql)

### 默认配置
- MySQL用户及密码：root/root

### 未涉及
- Web Mail
- PostfixAdmin
- 过滤及防病毒
- ……
