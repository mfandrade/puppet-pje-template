#!/bin/bash
# Nome: 1.5.1.1_jboss.sh
# Descricao: Script auxiliar necessários para atualizacao do PJe versao 1.5.1.1
# Responsável: SITEC - CSJT

### Variaveis ###
PATH1="$1"
PASS_API="pje_usuario_servico_api"
PASS_GIM="pje_usuario_servico_gim"

PWD_API_DS="$1/API-ds.xml"
PWD_GIM_DS="$1/GIM-ds.xml"

### Funcoes Auxiliares ###
function preencherParametros
{
	echo ""
	echo "Defina uma senha para o usuario $1"
	read parametro

	if [ "$parametro" = "" ]
	then
		parametro=$1
	fi
}

### Funcoes Principais ###

# 01) Preenche as senhas para os usuarios pjero_usuario_servico_api e pjero_usuario_servico_gim.
function carrega_parametros
{
	echo "### Inicio da interacao com o usuario, a qualquer momento pode ser interrompido com CTRL+C "

	preencherParametros $PASS_API
	PASS_API=$parametro
	preencherParametros $PASS_GIM
	PASS_GIM=$parametro
}

# 02) Realiza o download dos arquivos API-ds.xml e GIM-ds.xml do gitlab.
function download_ds
{
  url="https://git.pje.csjt.jus.br/infra/regional/raw/master/jboss/server/pje-xgrau-default/deploy/API-ds.xml?private_token=PYQzPy47zFNtyApkdxhw"
  curl -s -k --create-dirs $url -o $PWD_API_DS
  url="https://git.pje.csjt.jus.br/infra/regional/raw/master/jboss/server/pje-xgrau-default/deploy/GIM-ds.xml?private_token=PYQzPy47zFNtyApkdxhw"
  curl -s -k --create-dirs $url -o $PWD_GIM_DS
}

# 03) Atualiza as senhas para os usuarios pje_usuario_servico_api e pje_usuario_servico_gim.
function altera_ds
{
  PJEds="$PATH1/PJE-ds.xml"
  echo "Capturando informacoes do PJE-ds..."
  DATABASE_IP=$(grep ServerName $PJEds | head -n1 | cut -d ">" -f 2 | cut -d "<" -f 1)
  DATABASE_PORT=$(grep PortNumber $PJEds | head -n1 | cut -d ">" -f 2 | cut -d "<" -f 1) 
  DATABASE_NAME=$(grep DatabaseName $PJEds | head -n1 | cut -d ">" -f 2 | cut -d "<" -f 1)

  CONNECTION_URL=$(grep -A 10 PJE_DESCANSO_BASE_REPLICADA_DS $PJEds | grep '<connection-url>')

	echo "### Atualizando arquivos DS do GIM e API."
  ### $PWD_API_DS ###
  sed -i "s#name=\"ServerName\">.*</#name=\"ServerName\">$DATABASE_IP</#" $PWD_API_DS
  sed -i "s#name=\"PortNumber\">.*</#name=\"PortNumber\">$DATABASE_PORT</#" $PWD_API_DS
  sed -i "s#name=\"DatabaseName\">.*</#name=\"DatabaseName\">$DATABASE_NAME</#" $PWD_API_DS
  sed -i "s#<connection-url>.*#$CONNECTION_URL#" $PWD_API_DS
  sed -i "s#<user-name>.*</#<user-name>pje_usuario_servico_api</#" $PWD_API_DS
  sed -i "s#<password>.*</#<password>$PASS_API</#" $PWD_API_DS

  ### $PWD_GIM_DS ###
  sed -i "s#<connection-url>.*</#<connection-url>jdbc:postgresql://$DATABASE_IP:$DATABASE_PORT/$DATABASE_NAME</#" $PWD_GIM_DS
  sed -i "s#<user-name>.*</#<user-name>pje_usuario_servico_gim</#" $PWD_GIM_DS
  sed -i "s#<password>.*</#<password>$PASS_GIM</#" $PWD_GIM_DS
}

### Main ###

# Verifica se já foi realizada a mudanca de usuario
user_gim=$(grep pje_usuario_servico_gim $PWD_GIM_DS)

if [ x = "$user_gim"x ]; then
  
  # 01) Preenche as senhas para os usuarios pjero_usuario_servico_api e pjero_usuario_servico_gim.
  carrega_parametros

  # 02) Realiza o download dos arquivos API-ds.xml e GIM-ds.xml do gitlab.
  download_ds

  # 03) Atualiza as senhas para os usuarios pje_usuario_servico_api e pje_usuario_servico_gim.
  altera_ds

  echo "### Fim da execucao do script ."
fi


