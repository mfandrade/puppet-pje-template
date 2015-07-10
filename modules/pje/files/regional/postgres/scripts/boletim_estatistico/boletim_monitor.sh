#!/bin/bash

. boletim.conf
until false; do
clear
echo -e "$PGDATABASE"
ps a -o pid,args |grep -v grep |grep psql.bin |grep $PGDATABASE; ps aux |grep -v grep |grep psql.bin |grep $PGDATABASE|wc -l
read -t 3
done
