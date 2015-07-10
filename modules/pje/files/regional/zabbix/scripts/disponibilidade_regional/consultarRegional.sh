#!/bin/bash
#VARIAVEIS
REGIONAL_SIGLA=$1
REGIONAL_GRAU=$2
REGIONAL_URL="http://pje.$REGIONAL_SIGLA.jus.br/$REGIONAL_GRAU/login.seam"
ARQUIVO_PG_LOGIN="/usr/lib/zabbix/externalscripts/disponibilidade_regional/login_${REGIONAL_SIGLA}_${REGIONAL_GRAU}.seam"
ARQUIVO_RETORNO="/usr/lib/zabbix/externalscripts/disponibilidade_regional/disponibilidadeRegional_$REGIONAL_GRAU"
ARQUIVO_LOG="/var/log/zabbix/log_${REGIONAL_SIGLA}_${REGIONAL_GRAU}.log"
ARQUIVO_LOG_TEMP="/var/log/zabbix/log_${REGIONAL_SIGLA}_${REGIONAL_GRAU}.log.temp"

#CONFIGURAR O PROXY
export http_proxy=http://proxy.tst.jus.br:3128
export https_proxy=http://proxy.tst.jus.br:3128

# BAIXAR PAGINA PRINCIPAL
#wget -T 10 -t 3 --quiet --no-check-certificate -O $ARQUIVO_PG_LOGIN $REGIONAL_URL
wget -T 10 -t 3 -o $ARQUIVO_LOG_TEMP --no-check-certificate -O $ARQUIVO_PG_LOGIN $REGIONAL_URL

#VERIFICAR A VERSAO
if grep -q '[1][.][1-9][.][1-9]' $ARQUIVO_PG_LOGIN; then
	sed -i "s/$1 .*/$1 1/" $ARQUIVO_RETORNO
else
	sed -i "s/$1 .*/$1 0/" $ARQUIVO_RETORNO
	if [ ! -e $ARQUIVO_LOG ]; then
	    touch $ARQUIVO_LOG
	fi
	cat $ARQUIVO_LOG_TEMP >> $ARQUIVO_LOG
	echo '---------------------TENTATIVA--------------------' >> $ARQUIVO_LOG
fi

#APAGA ARQUIVO TEMPORARIO DE LOG
rm -rf $ARQUIVO_LOG_TEMP
