#!/bin/bash                                                                                          
# Grupo do CSJT/Infraestrutura                                                                       #
#                                                                                                    #
#                                                                                                    #
#  Contato:  pje-infraestrutura@csjt.jus.br                                                          #
#                                                                                                    #
#  Atualizacoes:                                                                                     #
#   Criacao de documento unico para verificacao dos ambientes                                        #
#                                                                                                    #
#                                                                                                    #
#====================================================================================================#

echo "================================================================================================"
echo "| pjereport (versao 1.1)                                                                       |"
echo "|                                                                                              |"
echo "| Este utilitario ira coletar algumas informacoes sobre o hardware e sobre as configuracoes do |"
echo "| PJe. As informacoes serao coletadas e empacotadas dentro do dirorio /tmp/PJE_CONF_(data).    |"
echo "| O CSJT ira utilizar essas informacoes somente com o proposito de diagnosticar os problemas   |"
echo "| relacionada na issue. Todas informacoes sera considerada confidencial                        |"
echo "|                                                                                              |"
echo "| Esse processo podera levar alguns minutos                                                    |"
echo "| Nenhuma alteracao sera feita no seu sistema.                                                 |"
echo "|                                                                                              |"
echo "|----------------------------Digite a opcao desejada:------------------------------------------|"
echo "|                                                                                              |"
echo "| 1 Verificar servidor APACHE.                                                                 |"
echo "| 2 Verificar servidor JBOSS.                                                                  |"
echo "| 3 Verificar servidor POSTGRESQL.                                                             |"
echo "| 4 Sair.                                                                                      |"
echo "|                                                                                              |"
echo "================================================================================================"

read command
if [ "$command" = "4" ]; then
	exit 0
fi


WORKSPACE="/tmp/verificarPje"
SO_SH="so.sh"
UTILS_SH="utils.sh"

PACKAGE_APACHE="apache/apache.sh"
PACKAGE_JBOSS="jboss/jboss.sh"
PACKAGE_POSTGRESQL="postgres/postgres.sh"

# Baixar os arquvios
function download_arquivo
{
    ARQUIVO=$1
    PATH_GIT='pjereport'
	#echo "#### Baixando arquivo: "$ARQUIVO
    url="https://git.pje.csjt.jus.br/infra/regional/raw/master/$PATH_GIT/$ARQUIVO?private_token=PYQzPy47zFNtyApkdxhw"
    curl -s -k --create-dirs $url -o "$WORKSPACE/$ARQUIVO"    
}

function executar
{
	download_arquivo $UTILS_SH
	download_arquivo $SO_SH
	download_arquivo $1
	
	chmod +x $WORKSPACE/$UTILS_SH $WORKSPACE/$SO_SH $WORKSPACE/$1
	sh $WORKSPACE/$1
	rm -rf $WORKSPACE		
}

case "$command" in
	1)		
		executar $PACKAGE_APACHE
		;;
	2)
		executar $PACKAGE_JBOSS
		;;
	3)
		executar $PACKAGE_POSTGRESQL
		;;
	*)
		echo $"Usage: {1-apache|2-jboss|3-postgresql|4-sair}"
esac