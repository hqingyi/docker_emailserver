# 邮件服务器
#
# Postfix（SMTP）、Dovecot（POP、IMAP）
# 目标：安全传输、虚拟用户
FROM ubuntu:14.04

MAINTAINER hqingyi <huangb.qingy@gmail.com>

# 禁止安装时交互
ENV DEBIAN_FRONTEND noninteractive
# 安装postfix
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN echo "postfix postfix/mailname string localhost" | debconf-set-selections
RUN echo "postfix postfix/root_address string admin@localhost" | debconf-set-selections
RUN echo "postfix postfix/mynetworks string 0.0.0.0/0" | debconf-set-selections
RUN echo "dovecot-core dovecot-core/create-ssl-cert boolean false" | debconf-set-selections
RUN echo "dovecot-core dovecot-core/ssl-cert-name string localhost" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

RUN apt-get update -qq
RUN apt-get install -y -qq \
    postfix \
    postfix-mysql \
    dovecot-core \
    dovecot-imapd \
    dovecot-pop3d \
    dovecot-lmtpd \
    dovecot-mysql \
    mysql-server

# 初始化数据
WORKDIR /root
ADD mysql_init.sql /root/mysql_init.sql
#RUN mysql -proot < /root/mysql_init.sql

# 重置所有配置
RUN rm -rf /etc/dovecot
RUN rm -rf /etc/postfix
ADD etc/dovecot /etc/dovecot
ADD etc/postfix /etc/postfix

# 添加用户
RUN groupadd -g 5000 vmail
RUN useradd -g vmail -u 5000 vmail -d /var/mail
# 修改目录权限
RUN chown -R vmail:vmail /var/mail
RUN chown -R vmail:dovecot /etc/dovecot

# 导出所有端口: 25-smtp 465-urd 587-submission 993-imaps 995-pop3s 3306-mysql(方便管理)
EXPOSE 25 465 587 993 995 3306

# 默认指令：启动dovecot、postfix以及mysql
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
