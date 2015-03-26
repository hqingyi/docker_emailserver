#!/bin/bash
postfix_stop(){
    ps -ef | grep postfix | awk '{print $2}' | xargs kill -9
}
/etc/init.d/mysql start
/etc/init.d/postfix start
dovecot
exec "$@"
