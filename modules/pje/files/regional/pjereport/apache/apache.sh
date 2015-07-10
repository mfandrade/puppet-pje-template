#!/bin/bash
installpath=/tmp/verificarPje
. $installpath/utils.sh
. $installpath/so.sh

PASTA_APACHE='APACHE'
PATH_SECURITY_LOG=`eval cat /etc/httpd/conf.d/*sec*.conf| grep -Po "(?<=^SecAuditLog ).*"`
PATH_JK_LOG=`eval cat /etc/httpd/conf.d/*jk*.conf| grep -Po "(?<=^JkLogFile ).*"`


# Main 
check_conf_file 'httpd.conf' 'apache/conf' '/etc/httpd/conf' $PASTA_APACHE
check_conf_file 'workers.properties' 'apache/conf' '/etc/httpd/conf' $PASTA_APACHE
check_conf_file 'vhosts.conf' 'apache/conf.d' '/etc/httpd/conf.d' $PASTA_APACHE
check_conf_file 'ssl.conf' 'apache/conf.d' '/etc/httpd/conf.d' $PASTA_APACHE

check_conf_file 'mod_cache.include' 'apache/conf.d' '/etc/httpd/conf.d' $PASTA_APACHE
check_conf_file 'mod_deflate.include' 'apache/conf.d' '/etc/httpd/conf.d' $PASTA_APACHE
check_conf_file 'mod_expires.include' 'apache/conf.d' '/etc/httpd/conf.d' $PASTA_APACHE
check_conf_file 'modjk.conf' 'apache/conf.d' '/etc/httpd/conf.d' $PASTA_APACHE
check_conf_file 'modsecurity.conf' 'apache/conf.d' '/etc/httpd/conf.d' $PASTA_APACHE

# Copia o server status
wget http://localhost/server-status
mv server-status $PASTA_DWLD/$PASTA_APACHE/server-status.html

# Gera informaçoes para arquivo pje-apache.txt
check_comando  'apachectl -V' 'apachectl'
check_comando 'ps -ef | grep httpd | grep -Ev grep' 'Processos httpd'
check_comando 'grep HTTPD= /etc/sysconfig/httpd ' 'HTTPD em /etc/sysconfig'
check_comando 'ps -ef | grep htcacheclean | grep -Ev grep || echo "*** Nenhum processo encontrado ***"' 'Processo htcacheclean'
padroniza_so "$PASTA_DWLD/$TEMP_CMD"
mv "$PASTA_DWLD/$TEMP_CMD" "$PASTA_DWLD/$PASTA_APACHE/pje-apache.txt"

# Copia o log do mod_security
cp $PATH_SECURITY_LOG $PASTA_DWLD/$PASTA_APACHE

# Copia o log do mod_jk
cp /etc/httpd/$PATH_JK_LOG $PASTA_DWLD/$PASTA_APACHE

# Copia o error.log
cp /etc/httpd/logs/error_log $PASTA_DWLD/$PASTA_APACHE

# Copia o access.log
cp /etc/httpd/logs/access_log $PASTA_DWLD/$PASTA_APACHE

# Copia logs pje
cp /etc/httpd/logs/pje-error_log $PASTA_DWLD/$PASTA_APACHE
cp /etc/httpd/logs/pje-access_log $PASTA_DWLD/$PASTA_APACHE

#Compactar o resultado
compactar_pasta 'APACHE'
