#!/bin/bash

# pje-stack.sh - Coleta de threaddumps para aplicações java.        
#
# Esse script deve ser executado somente sob demanda da equipe da CTPJE.
#
# A linha abaixo deve ser acrescentada no arquivo /etc/crontab e desabilitada/
# comentada.
#
# */1 7-19 * * 1-5 root <pasta_do_script>/pje-jstack.sh
#
# A linha acima só deve ser habilitada/descomentada quando solicitado pela 
# CTPJE.

## Variáveis
DIR_SAIDA='/tmp/pje-jstack'
DATA=$(date +%Y-%m-%d)
TWIDDLE='/srv/jboss/bin/twiddle.sh'
PROFILE=${1:-'pje-1grau-default'}
CONEXOES_DS=${2:-20}
JMX_USER=''
JMX_PWD=''

## Funções

# Verifica a não existência do diretório e, caso seja verdadeiro, cria todas as
# pastas e subpastas
function existe_diretorio {
  diretorio=$1
  if [ ! -d $diretorio ]
  then
    echo -e "Criando diretório $DIR_SAIDA."
    mkdir -p $diretorio
  fi
}

function set_jmx_credentials {
  # JMX Credentials
  JMX_CREDETIALS_FILE="/srv/jboss/server/$PROFILE/conf/props/jmx-console-users.properties"
  JMX_USER=$(grep -v '#' $JMX_CREDETIALS_FILE | cut -d '=' -f 1 | head -n 1)
  JMX_PWD=$(grep -v '#' $JMX_CREDETIALS_FILE | cut -d '=' -f 2 | head -n 1 | tr -d '\r')
}

function gerar_dump {
  jps='/usr/java/default/bin/jps'
  jstack='/usr/java/default/bin/jstack'
  pid=$($jps -m | grep $PROFILE | awk '{print $1}')
  ip=$($jps -m | grep $PROFILE | awk '{print $6}')

  # Informações JMX
  chave='jboss.jca:service=ManagedConnectionPool,name=PJE_DESCANSO_DS'
  valor='InUseConnectionCount'

  # Coleta do número de conexões
  num_conexoes=$($TWIDDLE -s $ip -u $JMX_USER -p $JMX_PWD get "$chave" $valor | awk -F= '{print $2}')

  # Verificação do número de conexões coletado vs o valor padrão definido e, 
  # se necessário, execução do jstack para gerar o threaddump.
  if [ $num_conexoes -ge $CONEXOES_DS ]
  then
    existe_diretorio $DIR_SAIDA/$DATA
    chown -R jboss.jboss $DIR_SAIDA/$DATA
    thread="$DIR_SAIDA/$DATA/threaddump_$(hostname)_${PROFILE}_$(date +"%d%m%Y_%Hh%Mm%Ss")_${num_conexoes}.log"
    su - jboss -c "$jstack -l $pid > $thread"
    if [ $? == 0 ]
    then
      echo -e "Arquivo \e[1m$thread\e[m gerando com sucesso."
    fi
  fi
}

## MAIN ##
set_jmx_credentials
gerar_dump

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
