#!/bin/bash
installpath=/tmp/verificarPje
. $installpath/utils.sh


# Variáveis de so.sh
PASTA_SO="SO"

# Main 

# Criando a pasta do arquivo txt do SO
mkdir -p $PASTA_DWLD/$PASTA_SO
> $PASTA_DWLD/$TEMP_CMD

check_comando 'crontab -l' 'CRONTAB'
check_comando 'cat /etc/crontab' '/ETC/CRONTAB'
check_comando 'free -mo' 'Memoria RAM'
check_comando 'df -h' 'Espaco em disco'
check_comando 'lscpu' 'Quantidade CPU'
check_comando '/etc/init.d/ntpd status' 'NTPD Status'
check_comando 'chkconfig --list' 'Servicos Subindo automaticamente'
check_comando 'ps auxf | sort -nr -k 3 | head -10' 'Maior uso de CPU'
check_comando 'ps auxf | sort -nr -k 4 | head -10' 'Maior uso de memoria'
check_comando 'netstat -tunlp' 'Portas abertas'
check_comando 'iptables -L -n' 'FIREWALL'
check_comando 'iostat' 'IOSTAT'
check_comando 'vmstat 1 10' 'VMSTAT'
check_comando 'cat /etc/redhat-release' 'Sistema Operacional'
check_comando 'cat /etc/security/limits.d/90-nproc.conf' 'Limits - 90-nproc.conf' 
check_comando 'cat /etc/security/limits.conf' 'Limits.conf'
check_comando 'cat /etc/sysconfig/i18n' 'Arquivo i18n'
check_comando 'env' 'Variáveis de ambiente'


padroniza_so "$PASTA_DWLD/$TEMP_CMD"

mv -f "$PASTA_DWLD/$TEMP_CMD" "$PASTA_DWLD/$PASTA_SO/sistema-operacional.txt"
