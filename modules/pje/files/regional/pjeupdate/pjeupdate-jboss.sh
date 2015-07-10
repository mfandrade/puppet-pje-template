#!/bin/bash
# Nome: pjeupdate-jboss.sh
# Descricao: Excutar os procedimentos necessarios para atualizacao do PJe.
# Responsavel: SITEC - CSJT

### Variaveis ###
ARQUIVO=""
JBOSS_USER=${JBOSS_USER:-"jboss"}
PROPERTIES='./pjeupdate-jboss.properties'
DATA_HORA=$(date +%Y%m%d-%H%M%S)
NEXUS_USR='atualizacao'
NEXUS_PSW='pje123456'

### Verificacoes iniciais ###

# Verifica presenca do arquivo .properties
if [ -f $PROPERTIES ]
then
  source ./pjeupdate-jboss.properties
else
  echo "e obrigatoria a presenca do arquivo pjeupdate-jboss.properties."
  exit 1
fi

ARQUIVO="pje-jt-$VERSAO"
DIR_DEPLOY=($DIR_DEPLOY1 $DIR_DEPLOY2)

#### UTILS ####

function regressivo
{
  start=$1
  echo -e -n "\tTempo: "
  for (( c=$start; c>=1; c-- ))
  do
    echo -n "$c "
    sleep 1
  done
  echo
}

function existe_diretorio
{
  diretorio=$1
  if [ -d $diretorio ]
  then
    echo -e "Nao e possível realizar a operacao. Diretorio ja existe."
    exit 1
  fi
}

function verifica_md5
{
  arquivo=$1
  url="$URL_NEXUS/$VERSAO/$arquivo.md5"
  echo -e "## Verificacao do md5sum..."
  md5_csjt=$(wget --user $NEXUS_USR --password $NEXUS_PSW -q -O- $url)
  md5_local=$(md5sum /tmp/$arquivo | awk '{printf $1}')
  if [ $md5_csjt != $md5_local ]
  then
    echo -e "Falha na verificacao do md5. Provalvemente o arquivo esta corrompido."
    exit 1
  else
    echo -e "Verificacao concluída com sucesso.\n"
  fi
}

# Trata erros referentes ao wget
erro(){
retorno=$?
case "$retorno" in
	0)
                echo "### OK "
                echo ""
        ;;
 	1)
		echo "### Erro desconhecido. "
                echo ""
		exit 1
	;;
	2)
	        echo "### Erro nas opcoes do wget."
		echo ""
                exit 1
	;;
	3)
	        echo "### Falha ao ler ou escrever arquivos no servidor."
                echo ""
		exit 1
	;;
	4)
	        echo "### Falha de Rede. Verifique sua conexao de rede, resolucao de nome, Firewall etc."
		echo ""
		exit 1
	;;
	5)
	        echo "### Falha na verificacao SSL."
		echo ""
		exit 1
	;;
	6)
		echo "### Falha de autenticacao. Verifique usuario e senha."
		echo ""
		exit 1
	;;
	7)
		echo "### Erro de Protocolo. Tente novamente."
                echo ""
		exit 1
	;;
	8)
	        echo "### Servidor retornou um erro. Provavelmente o arquivo '$FILE' nao existe."
		echo ""
		exit 1
	;;
esac
}

#### FUNCOES ####

# Verifica se a versao e valida
function verifica_versao
{
  if [ -z $VERSAO ]
  then
    echo "Uso: forneca a versao a ser atualizada no arquivo .properties."
    exit 1
  fi
  urlv=$URL_NEXUS/$VERSAO/$ARQUIVO.war
  echo -e "Verificando versao...\n"
  if ! wget --user $NEXUS_USR --password $NEXUS_PSW $urlv --spider -q
  then
    echo "A versao fornecida ($VERSAO) nao representa um arquivo .war valido."
    exit 1
  fi
}

# Recomendacoes quanto ao backup do banco de dados
function recomendacoes_banco
{
  echo -e "### Recomendacoes:"

  echo -e "\tVerificar se os backups dos bancos foram executados com sucesso.\n"

  echo -e "\tAntes de iniciar a atualizacao da versao, executar os scripts de
  banco de dados. Caso ocorra algum erro, interromper a atualizacao da versao e
  reportar à equipe do PJe atraves do Jira no projeto PJEJT, com o tipo
  \"Problema na Instalacao\".\n"

  echo -e "\tA CTPJe recomenda a execucao do Vaccum Analyze e do Vaccum Full a
  cada atualizacao da versao. Este procedimento pode ser feito em paralelo com
  a atualizacao da versao, lembrando que A APLICACAO SO DEVE SER INICIALIZADA
  APOS A CONCLUSAO OU O CORRETO CANCELAMENTO DO VACCUM FULL.\n"

  echo -e "\tPara cancelar a execucao desse script aperte CTRL+c.\n"

  echo -e "\tA atualizacao se iniciara automaticamente em $TEMPO segundos.\n"
  regressivo $TEMPO
}

# Parar a execucao de todos os JBoss
function parar_jboss
{
  echo "### Parando a execucao de todos os JBoss..."
  for grau in $GRAUS
  do
    initd="pje-$grau""grau-default.sh"
    $JBOSS_BIN/$initd stop
    $JBOSS_BIN/$initd kill
  done
}

# Efetuar copias de seguranca das bases de dados e dos diretorios do PJe
# correspondentes (ex.: primeirograu.war, segundograu.war).
function backup
{
  echo "### Realizando copias de seguranca..."
  if [ ! -d $DIR_BACKUP ]
  then
    echo "Criando diretorio de backup $DIR_BACKUP..."
    mkdir -p $DIR_BACKUP
  fi
  if [ $GRAU = '3' ]
  then
    mv $DIR_DEPLOY1/tst.war $DIR_BACKUP/tst.war_$DATA_HORA
  else
    mv $DIR_DEPLOY1/primeirograu.war $DIR_BACKUP/primeirograu.war_$DATA_HORA
    mv $DIR_DEPLOY2/segundograu.war $DIR_BACKUP/segundograu.war_$DATA_HORA
  fi
}

# Download do pje.war e descompactacao na pasta deploy
# Excluir o arquivo WAR copiado
function baixar_war
{
  # Download de wars...
  echo "### Realizando download da aplicacao..."
  rm -f /tmp/$ARQUIVO.war
  wget -t 1 --user $NEXUS_USR --password $NEXUS_PSW $URL_NEXUS/$VERSAO/$ARQUIVO.war -O /tmp/$ARQUIVO.war
  erro
  verifica_md5 $ARQUIVO.war
}

function instalar_war
{
  if [ ! -d $DIR_BACKUP ]
  then
    echo "Criando diretorio de backup $DIR_BACKUP..."
    mkdir -p $DIR_BACKUP
  fi
  
  for grau in $GRAUS
  do
    case $grau in
      1) instalagrau 0 "primeirograu" ;;
      2) instalagrau 1 "segundograu" ;;
      3) instalagrau 0 "tst" ;;
      *) echo "Opcao de grau $grau fornecida invalida." ;;
    esac
  done
}

function instalagrau
{
  DIRGRAU="${DIR_DEPLOY[$1]}"
  NOMEGRAU=$2
  echo "### Realizando instalacao de $NOMEGRAU"
  echo "## Realizando copias de seguranca..."
  mv $DIRGRAU/$NOMEGRAU.war $DIR_BACKUP/$NOMEGRAU.war_$DATA_HORA
  echo -e "## Descompactando arquivo para $DIRGRAU"
  existe_diretorio $DIRGRAU/$NOMEGRAU.war
  unzip -n -q /tmp/$ARQUIVO.war -d $DIRGRAU/$NOMEGRAU.war
  chown -R jboss.jboss $DIRGRAU
}

# Restabelecer o servico no JBoss apos a conclusao do procedimento anterior.
function iniciar_jboss
{
  [ -z "$INICIO_AUTO" ] && INICIO_AUTO=$GRAUS
  [ "$INICIO_AUTO" = '0' ] && INICIO_AUTO=''
  
  for grau in $INICIO_AUTO
  do
    initd="pje-$grau""grau-default.sh"
    $JBOSS_BIN/$initd start
  done
  
  [ -z "$INICIO_AUTO" ] && echo -e "A aplicacao deve ser inicializada manualmente.\n"
}

# Segue o log do servidor, caso definido pelo usuario
function seguir_log
{
  [ -z "$INICIO_AUTO" ] && ( echo "Servidor nao iniciado."; exit 1 )
  if [ $LOG = '1' ]
  then
    echo -e "\n## Seguindo log do servidor JBoss 1grau..."
    tail -f $DIR_DEPLOY1/../log/server.log
  elif [ $LOG = '2' ]
  then
    echo -e "\n## Seguindo log do servidor JBoss 2grau..."
    tail -f $DIR_DEPLOY2/../log/server.log
  fi
}

# Roda script adicional de acordo com a versao requisitada
function script_extra
{
  urlse="$URL_SCRIPT_AUX/$VERSAO""_jboss.sh?private_token=PYQzPy47zFNtyApkdxhw"
  if wget --user $NEXUS_USR --password $NEXUS_PSW $urlse --no-check-certificate --spider -q
  then
    script_extra="/tmp/$VERSAO""_jboss.sh"
    wget --user $NEXUS_USR --password $NEXUS_PSW $urlse --no-check-certificate -q -O $script_extra
    erro
    chmod +x $script_extra
    ARGS_SE=''
    for grau in $GRAUS
    do
      case $grau in
        1 | 3) ARGS_SE="$DIR_DEPLOY1" ;;
        2) ARGS_SE="$DIR_DEPLOY2" ;;
      esac
      . $script_extra $ARGS_SE
    done
  fi
}

#### MAIN ####

verifica_versao

# Recomendacoes quanto ao backup do banco de dados
recomendacoes_banco

# Parar a execucao de todos os JBoss
parar_jboss

# Download do pje.war e descompactacao na pasta deploy
# Excluir o arquivo WAR copiado
baixar_war

# Efetuar copias de seguranca das bases de dados e dos diretorios do PJe
# correspondentes (ex.: primeirograu.war, segundograu.war).
instalar_war

# Rodar script adicional, caso exista
script_extra

# Restabelecer o servico no JBoss apos a conclusao
iniciar_jboss

[ -z $LOG ] || seguir_log

