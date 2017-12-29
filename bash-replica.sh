#!/bin/bash

sed -i '33r rep.txt' /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart
mysql -uroot -proot -e "create user 'repl_user'@'rds.instanceip' IDENTIFIED BY 'Test1#';"
mysql -uroot -proot -e "GRANT REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO 'repl_user'@'172.31.74.148 IDENTIFIED BY 'Test1#';"
sudo mysqldump    --databases checkreplicate --master-data=2 --single-transaction  --order-by-primary   -r backup.sql  -uroot  -prootpwd
mysql -h rds.instanceip -uroot -prootpwd -d DB < backup.sql
mysql -h rds.instanceip -uroot -prootpwd -e "CALL mysql.rds_set_external_master ('ipmasterhost', 3306, 'repl_user', 'pass-repl-user', 'mysql-bin.000001', POS, 0);"
mysql -h rds.instanceip -uroot -prootpwd -e "CALL mysql.rds_start_replication;"


