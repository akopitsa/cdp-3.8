#!/bin/bash

dd if=/dev/zero of=/swapfile bs=1M count=2560
chown root:root  /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile   swap    swap    sw  0   0" >> /etc/fstab
echo "vm.swappiness = 100" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf
sysctl -p
apt update
apt install -y ntp vim mc git tree debconf-utils
timedatectl set-timezone Europe/Kiev
ntpdate pool.ntp.org
sed -i 's/server 0.centos.pool.ntp.org/server 0.ua.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 1.centos.pool.ntp.org/server 1.ua.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 2.centos.pool.ntp.org/server 2.ua.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 3.centos.pool.ntp.org/server 3.ua.pool.ntp.org/g' /etc/ntp.conf
systemctl restart ntpd
systemctl enable ntpd

echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
apt install mysql-server -y
sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -uroot -proot -e 'USE mysql; UPDATE `user` SET `Host`="%" WHERE `User`="root" AND `Host`="localhost"; DELETE FROM `user` WHERE `Host` != "%" AND `User`="root"; FLUSH PRIVILEGES;'
service mysql restart

free && sync && echo 3 > /proc/sys/vm/drop_caches && free


# vim /etc/mysql/mysql.conf.d/mysqld.cnf
# [mysqld]
# log-bin=mysql-bin
# server-id=1 
# sudo service mysqld restart

# RDS 
# DB instance  cdpdbinstance
# Master username cdproot 
# Master password Epam2017#
# Database name checkreplicate

# create user 'repl_user'@'172.31.74.148' IDENTIFIED BY 'Test1#';
# GRANT REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO 'repl_user'@'172.31.74.148 IDENTIFIED BY 'Test1#';

# Останавливаем запись в базу
# FLUSH TABLES WITH READ LOCK; SET GLOBAL read_only = ON;

# backup
# sudo mysqldump    --databases checkreplicate --master-data=2 --single-transaction  --order-by-primary   -r backup.sql  -uroot  -proot 
# Воссnанавливаем бэкап
# source backup.sql

# смотрим позицию в бэкапе 
# cat backup.sql
# CALL mysql.rds_set_external_master ('34.229.157.2', 3306, 'repl_user', 'Test1#', 'mysql-bin.000001', 154, 0); 

# снимаем блокировки
# SET GLOBAL read_only = OFF; UNLOCK TABLES;FLUSH TABLES; 
# CALL mysql.rds_start_replication;