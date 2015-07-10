#!/bin/bash
# Nome: 1.5.0_postgres.sh
# Descricao: Script auxiliar necessários para atualizacao do PJe versao 1.5.0.
# Responsável: SITEC - CSJT 

### Variaveis ###
TLS="tls"
PASS_API="pje_usuario_servico_api"
PASS_GIM="pje_usuario_servico_gim"
DIR_VERSAO="/tmp/instalacao_db/versao"
PROPERTIES='./pjeupdate-postgres.properties'

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

function atualizar1grau
{	
	echo "### Atualizando o banco do primeiro grau"
	psql -h $BD_SERVER_1G -U $BD_USUARIO_1G -p $BD_PORTA_1G -d $BASE_1GRAU -c "ALTER ROLE pje_usuario_servico_api WITH PASSWORD '$PASS_API';"
	psql -h $BD_SERVER_1G -U $BD_USUARIO_1G -p $BD_PORTA_1G -d $BASE_1GRAU -c "ALTER ROLE pje_usuario_servico_gim WITH PASSWORD '$PASS_GIM';"
}

function atualizar2grau
{
	echo "### Atualizando o banco do segundo grau"
	psql -h $BD_SERVER_2G -U $BD_USUARIO_2G -p $BD_PORTA_2G -d $BASE_2GRAU -c "ALTER ROLE pje_usuario_servico_api WITH PASSWORD '$PASS_API';"
	psql -h $BD_SERVER_2G -U $BD_USUARIO_2G -p $BD_PORTA_2G -d $BASE_2GRAU -c "ALTER ROLE pje_usuario_servico_gim WITH PASSWORD '$PASS_GIM';"
}

function atualizar3grau
{
	echo "### Atualizando o banco do terceiro grau"
	psql -h $BD_SERVER_3G -U $BD_USUARIO_3G -p $BD_PORTA_3G -d $BASE_3GRAU -c "ALTER ROLE pje_usuario_servico_api WITH PASSWORD '$PASS_API';"
	psql -h $BD_SERVER_3G -U $BD_USUARIO_3G -p $BD_PORTA_3G -d $BASE_3GRAU -c "ALTER ROLE pje_usuario_servico_gim WITH PASSWORD '$PASS_GIM';"
}

### Funcoes Principais ###
# 01) Verifica se o script PJE_1.5.1_024 foi executado anteriormente
function validacoes_iniciais
{
SQL=$(psql -h $BD_SERVER_1G -U $BD_USUARIO_1G -p $BD_PORTA_1G -d $BASE_1GRAU -c "select installed_on from schema_version where version = 'PJE_1.5.1_024';")
SCRIPT_EXECUTADO=$(echo $SQL | grep -o $(date +%Y-%m-%d))


if [ x != "$SCRIPT_EXECUTADO"x ]
  then
  exit 1
fi

}

# 00) Carregar o arquivo de propriedades
function carregar_properties
{
if [ -f $PROPERTIES ]
then
   source $PROPERTIES
else
  echo "Obrigatoria a presenca do arquivo $PROPERTIES."
  exit 1
fi
}



# 02) Preenche as senhas para os usuarios pjero_usuario_servico_api e pjero_usuario_servico_gim.
function carrega_parametros
{
	echo "### Inicio da interacao com o usuario, a qualquer momento pode ser interrompido com CTRL+C "

	preencherParametros $PASS_API
	PASS_API=$parametro
	preencherParametros $PASS_GIM
	PASS_GIM=$parametro
}

# 03) Atualiza as senhas para os usuarios pjero_usuario_servico_api e pjero_usuario_servico_gim.
function atualiza_senha
{
	echo "### Atualizando o banco de dados com as senhas informadas."

	for grau in $GRAUS
	 do
    	  case $grau in
      	   1) atualizar1grau ;;
           2) atualizar2grau ;;
      	   3) atualizar3grau ;;
      	   *) echo "Opcao de grau $grau fornecida invalida." ;;
    	  esac
	done

	echo "### Fim da execucao."
}

### Main ###

# 00) Carregar o arquivo de propriedades
carregar_properties

# 01) Verifica se o script PJE_1.5.1_024 foi executado anteriormente
validacoes_iniciais

# 02) Preenche as senhas para os usuarios pjero_usuario_servico_api e pjero_usuario_servico_gim.
carrega_parametros

# 03) Atualiza as senhas para os usuarios pjero_usuario_servico_api e pjero_usuario_servico_gim.
atualiza_senha
