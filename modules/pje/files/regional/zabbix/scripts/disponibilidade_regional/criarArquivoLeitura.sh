ARQUIVO_RETORNO_PRIMEIRO="/usr/lib/zabbix/externalscripts/disponibilidade_regional/disponibilidadeRegional_primeirograu"
ARQUIVO_RETORNO_SEGUNDO="/usr/lib/zabbix/externalscripts/disponibilidade_regional/disponibilidadeRegional_segundograu"

#VERIFICAR SE O ARQUIVO JA EXISTE, CASO NAO EXISTA, ENTAO CRIA-LO
if [ ! -e $ARQUIVO_RETORNO_PRIMEIRO ]; then
        for i in $(seq 1 24); do
                echo "trt$i" 0 >> $ARQUIVO_RETORNO_PRIMEIRO;
        done;
fi
if [ ! -e $ARQUIVO_RETORNO_SEGUNDO ]; then
        for i in $(seq 1 24); do
                echo "trt$i" 0 >> $ARQUIVO_RETORNO_SEGUNDO;
        done;
fi
