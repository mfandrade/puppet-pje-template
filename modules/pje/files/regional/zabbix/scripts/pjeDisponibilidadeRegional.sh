#!/bin/bash
#VARIAVEIS
REGIONAL=$( echo $1 | cut -d. -f2 )
GRAU=$2
ARQUIVO="/usr/lib/zabbix/externalscripts/disponibilidade_regional/disponibilidadeRegional_$GRAU"

if grep -wq "${REGIONAL} 1" $ARQUIVO; then
    echo 1
else
    echo 0 
fi
#apos a leitura do zabbix. Reiniciar a variavel
#sed -i "s/${REGIONAL} .*/${REGIONAL} 0/" $ARQUIVO
