#!/bin/sh
#Script automatiza restore do scritp de backup zbx_backup_config_history_trends.sh
#Created by Hernandes Martins
#Date: 29/05/2018
#Testado em Zabbix 2.4
#Este script e arquivos devem estar dentro do diretorio /opt/

#Parar o serviço do Zabbix Server
systemctl stop zabbix-server.service

#Procedimentos mysql
mysql -uroot -p123456 <<MYSQL_SCRIPT
DROP DATABASE zabbix;
CREATE DATABASE zabbix character set utf8 collate utf8_bin;
#GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost' identified by 'zabbix';
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Procedimento mysql rodou"

#Descompactando arquivo .tar recebido
tar -xvzf backup.tar

#Populando base mysql com informações do backup
mysql -uzabbix -pzabbix zabbix < zabbix-1-schema.sql
mysql -uzabbix -pzabbix zabbix < zabbix-2-config.sql
mysql -uzabbix -pzabbix zabbix < zabbix-3-history.sql
mysql -uzabbix -pzabbix zabbix < zabbix-4-trends.sql

echo "Procedimento de populacao da base rodou"

#Inicializando o Zabbix Server 
systemctl start zabbix-server.service ; tail -f /var/log/zabbix/zabbix_server.log