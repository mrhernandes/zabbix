#!/bin/sh
#backup zabbix config only
#Original link https://www.zabbix.com/forum/zabbix-help/22576-copying-duplicating-zabbix-configuration
#Changed by Hernandes Martins
#Date: 21/05/2018
#Update01: 02/12/2019
#Update02: 05/05/2020
#Update03: 11/05/2020
#Checked on Zabbix 4.x

###### Variables Mysql database
DBNAME=zabbix
DBUSER=zabbix
DBPASS=zabbix

###### Convert human date to timestamp
## Option default to convert date do timestamp
## comment the lines when use manually option in option "Variables time range "
echo "1 - Type Date to Backup Start. "
echo "Format: mouth day hour:minutes:sec"
echo "Example: Apr 28 07:50:01 "
read DATE_HUMAN_START

echo "2 - Date to Backup Finish. "
echo "Format: mouth day hour:minutes:sec"
echo "Example: Apr 28 07:50:01 "
read DATE_HUMAN_FINISH

DATESTART=$(date -d "${DATE_HUMAN_START}" +"%s")
DATEFINISH=$(date -d "${DATE_HUMAN_FINISH}" +"%s")

echo -e "\nDate Checked ok"
echo "Human date start: " $DATE_HUMAN_START  "| Converted to Timestamp: " $DATESTART
echo "Huamn date finish: " $DATE_HUMAN_FINISH  "| Converted to Timestamp: " $DATEFINISH

###### Variables time_range 
## Uncomment and use this options when input timestamp date manually
## Convert date to timestamp format
## Reference to convert timestamp: https://www.epochconverter.com/
#DATESTART=1587646800
#DATEFINISH=1588699551

#Path Backup Direcory
#Change if necessary and check the disk space on path directory
date=$(date +"%d-%b-%Y")
BK_DEST=/opt/backup-config-$date

#Create Dir backup
mkdir $BK_DEST

####### 01 - Copy the zabbix schema
mysqldump -u "$DBUSER"  -p"$DBPASS" "$DBNAME" --no-data  --skip-lock-tables > "$BK_DEST/$DBNAME-1-schema.sql"

####### 02 - Copy zabbix config(config from anythings, Administration,Configuration, hosts,templates,users ....) whitout large tables
mysqldump -u"$DBUSER"  -p"$DBPASS" "$DBNAME" --single-transaction --skip-lock-tables --no-create-info --no-create-db \
    --ignore-table="$DBNAME.acknowledges" \
    --ignore-table="$DBNAME.alerts" \
    --ignore-table="$DBNAME.auditlog" \
    --ignore-table="$DBNAME.auditlog_details" \
    --ignore-table="$DBNAME.events" \
    --ignore-table="$DBNAME.history" \
    --ignore-table="$DBNAME.history_log" \
    --ignore-table="$DBNAME.history_str" \
    --ignore-table="$DBNAME.history_text" \
    --ignore-table="$DBNAME.history_uint" \
    --ignore-table="$DBNAME.trends" \
    --ignore-table="$DBNAME.trends_uint" \
    > "$BK_DEST/$DBNAME-2-config.sql"

#03 - Copy data from table history by timestamp
##
########## Example data from table history
## MariaDB [zabbix]> select * from history limit 10;
## +--------+------------+--------+-----------+
## | itemid | clock      | value  | ns        |
## +--------+------------+--------+-----------+
#> |  23664 | 1587648264 | 0.1245 | 228427627 | //example view clock DATESTART = 1587648264
## |  23252 | 1587648272 | 0.0000 | 235395646 |
## |  23253 | 1587648273 | 0.0000 | 236042839 |
## |  23255 | 1587648275 | 4.3281 | 237697517 |
## |  23256 | 1587648276 | 0.2991 | 237988119 |
## |  23257 | 1587648277 | 0.3321 | 238672894 |
## |  23258 | 1587648278 | 0.0000 | 239464871 |
## |  23259 | 1587648279 | 0.0868 | 240436827 |
## |  23620 | 1587648280 | 0.2151 | 240670439 |
#> |  23260 | 1587648280 | 0.0000 | 240739797 | //example view clock DATEFINISH = 1587648280
## +--------+------------+--------+-----------+
## 10 rows in set (0.00 sec)
##
## Copy data from table history
mysqldump -u$DBUSER  -p"$DBPASS" $DBNAME history --single-transaction --no-create-info --where="clock BETWEEN '$DATESTART' and '$DATEFINISH'" > "$BK_DEST/$DBNAME-3-history.sql"
mysqldump -u$DBUSER  -p"$DBPASS" $DBNAME history --single-transaction --no-create-info --where="clock BETWEEN '$DATESTART' and '$DATEFINISH'" > "$BK_DEST/$DBNAME-3-history_log.sql"
mysqldump -u$DBUSER  -p"$DBPASS" $DBNAME history --single-transaction --no-create-info --where="clock BETWEEN '$DATESTART' and '$DATEFINISH'" > "$BK_DEST/$DBNAME-3-history_str.sql"
mysqldump -u$DBUSER  -p"$DBPASS" $DBNAME history --single-transaction --no-create-info --where="clock BETWEEN '$DATESTART' and '$DATEFINISH'" > "$BK_DEST/$DBNAME-3-history_text.sql"
mysqldump -u$DBUSER  -p"$DBPASS" $DBNAME history --single-transaction --no-create-info --where="clock BETWEEN '$DATESTART' and '$DATEFINISH'" > "$BK_DEST/$DBNAME-3-history_uint.sql"



##
##########Example data from table trends
##
## 04 - Copy data from table trends by timestamp
##MariaDB [zabbix]> select * from trends limit 10;
## +--------+------------+-----+-----------+-----------+-----------+
## | itemid | clock      | num | value_min | value_avg | value_max |
## +--------+------------+-----+-----------+-----------+-----------+
#> |  10073 | 1587646800 |  23 |    0.4163 |    0.8032 |    0.8464 | //example view clock DATESTART = 1587646800
## |  10074 | 1587646800 |  23 |    0.0000 |    0.0029 |    0.0666 |
## |  10075 | 1587646800 |  23 |    0.0000 |    0.0000 |    0.0000 |
## |  10076 | 1587646800 |  23 |    0.0500 |    0.3766 |    0.4330 |
## |  10077 | 1587646800 |  23 |    0.0000 |    0.0000 |    0.0000 |
## |  10078 | 1587646800 |  22 |    0.0000 |    0.0114 |    0.0500 |
## |  23252 | 1587646800 |  25 |    0.0000 |    0.0000 |    0.0000 |
## |  23253 | 1587646800 |  25 |    0.0000 |    0.0609 |    0.3205 |
## |  23255 | 1587646800 |  25 |    0.0000 |    0.1862 |    4.3281 |
#> |  23256 | 1587646800 |  25 |    0.0000 |    0.0595 |    0.3093 | //example view clock DATEFINISH = 1587646800
## +--------+------------+-----+-----------+-----------+-----------+
## 10 rows in set (0.00 sec)
## 
## Copy data from table trends
mysqldump -u$DBUSER  -p"$DBPASS" $DBNAME trends --single-transaction --no-create-info --where="clock BETWEEN '$DATESTART' and '$DATEFINISH'" > "$BK_DEST/$DBNAME-4-trends.sql"
#
## 05 - Add to file.tar 
tar -zcf $BK_DEST/backup.tar $DBNAME-1-schema.sql $DBNAME-2-config.sql $DBNAME-3-history.sql $DBNAME-4-trends.sql
