#!/bin/bash
# Realizar a verificacao do ambiente do jboss
installpath=/tmp/verificarPje
. $installpath/utils.sh
. $installpath/so.sh

PASTA_JBOSS='jboss'
PASTA_JBOSS1G='jboss1G'
PASTA_JBOSS2G='jboss2G' 
PJE_PROFILE_HOME_1G='/srv/jboss/server/pje-1grau-default'
PJE_PROFILE_HOME_2G='/srv/jboss/server/pje-2grau-default'
PJE_DEPLOYS_HOME_1G='/srv/jboss/server/pje-1grau-default/deploy/'
PJE_DEPLOYS_HOME_2G='/srv/jboss/server/pje-2grau-default/deploy/'
PJE_INIT_1G='pje-1grau-default.sh'
PJE_INIT_2G='pje-2grau-default.sh'

function verificarCaminho
{	
	echo ""
	echo "Caminho da configuracao do jboss [$1],[Enter] para confirmar ou novo caminho."	
	read path	
	
	if [ "$path" = "" ]; then
		path=$1
	fi
}

function verificarNome
{	
	echo ""
	echo "Nome do arquivo de inicializacao[$1],[Enter] para confirmar ou novo nome."	
	read path	
	
	if [ "$path" = "" ]; then
		path=$1
	fi
}

verificarCaminho $PJE_PROFILE_HOME_1G
PJE_PROFILE_HOME_1G=$path
verificarCaminho $PJE_PROFILE_HOME_2G
PJE_PROFILE_HOME_2G=$path
verificarCaminho $PJE_DEPLOYS_HOME_1G
PJE_DEPLOYS_HOME_1G=$path
verificarCaminho $PJE_DEPLOYS_HOME_2G
PJE_DEPLOYS_HOME_2G=$path
verificarNome $PJE_INIT_1G
PJE_INIT_1G=$path
verificarNome $PJE_INIT_2G
PJE_INIT_2G=$path

# Main 
#check_conf_file 'aplicacaojt.keystore' 'jboss/' '/usr/java/latest/jre/lib/security/' $PASTA_JBOSS
baixa_arquivo_regional 'aplicacaojt.keystore' '/usr/java/latest/jre/lib/security/' $PASTA_JBOSS
baixa_arquivo_regional $PJE_INIT_1G '/srv/jboss/bin/' $PASTA_JBOSS
baixa_arquivo_regional $PJE_INIT_2G '/srv/jboss/bin/' $PASTA_JBOSS

#arquivos do primeiro grau
check_conf_file 'run.conf' 'jboss/server/pje-xgrau-default/' $PJE_PROFILE_HOME_1G'/' $PASTA_JBOSS1G
check_conf_file 'PJE-ds.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_1G $PASTA_JBOSS1G
check_conf_file 'GIM-ds.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_1G $PASTA_JBOSS1G
check_conf_file 'API-ds.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_1G $PASTA_JBOSS1G
check_conf_file 'jboss-log4j.xml' 'jboss/server/pje-xgrau-default/conf/' $PJE_PROFILE_HOME_1G'/conf/' $PASTA_JBOSS1G
check_conf_file 'transaction-jboss-beans.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_1G'/' $PASTA_JBOSS1G
#check_conf_file 'components.xml' 'jboss/server/pje-xgrau-default/deploy/pje.war/' $PJE_DEPLOYS_HOME_1G'primeirograu.war/WEB-INF/' $PASTA_JBOSS1G
#check_conf_file 'web.xml' 'jboss/server/pje-xgrau-default/deploy/pje.war/' $PJE_DEPLOYS_HOME_1G'primeirograu.war/WEB-INF/' $PASTA_JBOSS1G
check_conf_file 'server.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_1G'/jbossweb.sar/' $PASTA_JBOSS1G
check_conf_file 'jca-jboss-beans.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_1G'/' $PASTA_JBOSS1G
check_conf_file 'jboss-beans.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_PROFILE_HOME_1G'/deployers/jbossws.deployer/META-INF/' $PASTA_JBOSS1G
#check_conf_file 'versao.xml' 'jboss/server/pje-xgrau-default/deploy/pje.war/' $PJE_DEPLOYS_HOME_1G'primeirograu.war/' $PASTA_JBOSS1G

#arquivos do segundo grau
check_conf_file 'run.conf' 'jboss/server/pje-xgrau-default/' $PJE_PROFILE_HOME_2G'/' $PASTA_JBOSS2G
check_conf_file 'PJE-ds.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_2G $PASTA_JBOSS2G
check_conf_file 'GIM-ds.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_2G $PASTA_JBOSS2G
check_conf_file 'API-ds.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_2G $PASTA_JBOSS2G
check_conf_file 'jboss-log4j.xml' 'jboss/server/pje-xgrau-default/conf/' $PJE_PROFILE_HOME_2G'/conf/' $PASTA_JBOSS2G
check_conf_file 'transaction-jboss-beans.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_2G'/' $PASTA_JBOSS2G
#check_conf_file 'components.xml' 'jboss/server/pje-xgrau-default/deploy/pje.war/' $PJE_DEPLOYS_HOME_2G'segundograu.war/WEB-INF/' $PASTA_JBOSS2G
#check_conf_file 'web.xml' 'jboss/server/pje-xgrau-default/deploy/pje.war/' $PJE_DEPLOYS_HOME_2G'segundograu.war/WEB-INF/' $PASTA_JBOSS2G
check_conf_file 'server.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_2G'/jbossweb.sar/' $PASTA_JBOSS2G
check_conf_file 'jca-jboss-beans.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_DEPLOYS_HOME_2G'/' $PASTA_JBOSS2G
check_conf_file 'jboss-beans.xml' 'jboss/server/pje-xgrau-default/deploy/' $PJE_PROFILE_HOME_2G'/deployers/jbossws.deployer/META-INF/' $PASTA_JBOSS2G
#check_conf_file 'versao.xml' 'jboss/server/pje-xgrau-default/deploy/pje.war/' $PJE_DEPLOYS_HOME_2G'segundograu.war/' $PASTA_JBOSS2G

baixa_arquivo_regional 'web.xml' $PJE_DEPLOYS_HOME_1G'primeirograu.war/WEB-INF/' $PASTA_JBOSS1G
baixa_arquivo_regional 'components.xml' $PJE_DEPLOYS_HOME_1G'primeirograu.war/WEB-INF/' $PASTA_JBOSS1G
baixa_arquivo_regional 'versao.xml' $PJE_DEPLOYS_HOME_1G'primeirograu.war/' $PASTA_JBOSS1G
baixa_arquivo_regional 'web.xml' $PJE_DEPLOYS_HOME_2G'segundograu.war/WEB-INF/' $PASTA_JBOSS2G
baixa_arquivo_regional 'components.xml' $PJE_DEPLOYS_HOME_2G'segundograu.war/WEB-INF/' $PASTA_JBOSS2G
baixa_arquivo_regional 'versao.xml' $PJE_DEPLOYS_HOME_2G'segundograu.war/' $PASTA_JBOSS2G

echo "#### Verificacao do status do primeirograu"
check_comando '/srv/jboss/bin/'$PJE_INIT_1G' status' 'PJE 1 GRAU'
echo "#### Verificacao do status do segundograu"
check_comando '/srv/jboss/bin/'$PJE_INIT_2G' status' 'PJE 2 GRAU'

check_comando 'ls /srv/jboss/common/lib/po*' 'Driver PJE'

check_comando 'ls -lh '$PJE_PROFILE_HOME_1G'/deploy/' 'Conteudo do diretorio deploy do primeiro grau'

check_comando 'ls -lh '$PJE_PROFILE_HOME_2G'/deploy/' 'Conteudo do diretorio deploy do segundo grau'

padroniza_so "$PASTA_DWLD/$TEMP_CMD"

mv "$PASTA_DWLD/$TEMP_CMD" "$PASTA_DWLD/$PASTA_JBOSS/pje-status.txt"

check_comando 'tail -5000  '$PJE_PROFILE_HOME_1G'/log/server.log' 'Log do Jboss Primeiro Grau'
mv "$PASTA_DWLD/$TEMP_CMD" "$PASTA_DWLD/$PASTA_JBOSS/server_log_1g.txt"

check_comando 'tail -5000  '$PJE_PROFILE_HOME_2G'/log/server.log' 'Log do Jboss Segundo Grau'
mv "$PASTA_DWLD/$TEMP_CMD" "$PASTA_DWLD/$PASTA_JBOSS/server_log_2g.txt"



#Compactar o resultado
compactar_pasta 'JBOSS'
