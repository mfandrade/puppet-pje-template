#!/bin/bash
# Nome: 1.5.0_postgres.sh
# Descricao: Script auxiliar necessários para atualizacao do PJe versao 1.5.0.
# Responsável: SITEC - CSJT 

### Variaveis ###
GIM=`eval cat $PGDATA/postgresql.conf | grep -Po "(?<=^search_path ).*'"|grep -o "pje_gim"`
TLS="tls"
DEBUG="debug"
HOST="host"
PORT="port"
PASS="password"
USUARIO="usuario"
#PSQL_BIN="/opt/PostgreSQL/9.3/bin/psql"
DIR_VERSAO="/tmp/instalacao_db/versao"
SEARCH_PATH='search_path = '\''"$user",public,jt,acl,client,core,eg,pje_gim,criminal'\'''

### Funcoes Auxiliares ###
function preencherParametros
{	
	echo ""
	echo "Informe o parametro [$1], para ser preenchido na tabela de parametros (parametros_smtp)."	
	read parametro	
	
	if [ "$parametro" = "" ]
	then
		parametro=$1
	fi
}

function preencherParametrosBanco
{
	echo ""
	echo "Informe o parametro [$1], de autenticacao no banco de dados."     
	read parametro

	if [ "$parametro" = "" ]
	then
		parametro=$1
	fi
}

### Funcoes Principais ###

# 01) Acressentar o schema pje_gim no serach_path do arquivo postgresql.conf
function insere_schema
{
	if [ "$GIM" != "pje_gim" ]
	then
		echo "### Acressentando o schema pje_gim ao search_path"
		sed -i -e "s/^search_path\(.*\)/$SEARCH_PATH/" $PGDATA/postgresql.conf
		if [ $TRIBUNAL == "tst" ]
			then
				psql -h $BD_SERVER_3G -U $BD_USUARIO_3G -p $BD_PORTA_3G -d $BASE_3GRAU -c "select pg_reload_conf();"
			else
				psql -h $BD_SERVER_1G -U $BD_USUARIO_1G -p $BD_PORTA_1G -d $BASE_1GRAU -c "select pg_reload_conf();"
				psql -h $BD_SERVER_2G -U $BD_USUARIO_2G -p $BD_PORTA_2G -d $BASE_2GRAU -c "select pg_reload_conf();"
		fi
	fi
}

# 02) Preenche as configuracaes do smtp: tls, debug, host, port, password, usuario.
function carrega_parametros
{
	echo "### Inicio da interacao com o usuario, a qualquer momento pode ser interrompido com CTRL+C "

	preencherParametros $TLS
	TLS=$parametro
	preencherParametros $DEBUG
	DEBUG=$parametro
	preencherParametros $HOST
	HOST=$parametro
	preencherParametros $PORT
	PORT=$parametro
	preencherParametros $USUARIO
	USUARIO=$parametro
	preencherParametros $PASS
	PASS=$parametro
}

# 03) Atualiza o parametro parametros_smtp
function atualiza_parametros_smtp
{
	echo "### Atualizando o banco de dados com os parametros informados."

	if [ $TRIBUNAL == "tst" ]
	  then
		psql -h $BD_SERVER_3G -U $BD_USUARIO_3G -p $BD_PORTA_3G -d $BASE_3GRAU -c "UPDATE core.tb_parametro SET vl_variavel = '{''tls'': ''$TLS'', ''debug'': ''$DEBUG'', ''host'':''$HOST'', ''password'': ''$PASS'', ''port'': ''$PORT'', ''username'': ''$USUARIO''}' WHERE NM_VARIAVEL = 'parametros_smtp';"
	  else
		psql -h $BD_SERVER_1G -U $BD_USUARIO_1G -p $BD_PORTA_1G -d $BASE_1GRAU -c "UPDATE core.tb_parametro SET vl_variavel = '{''tls'': ''$TLS'', ''debug'': ''$DEBUG'', ''host'':''$HOST'', ''password'': ''$PASS'', ''port'': ''$PORT'', ''username'': ''$USUARIO''}' WHERE NM_VARIAVEL = 'parametros_smtp';"
		psql -h $BD_SERVER_2G -U $BD_USUARIO_2G -p $BD_PORTA_2G -d $BASE_2GRAU -c "UPDATE core.tb_parametro SET vl_variavel = '{''tls'': ''$TLS'', ''debug'': ''$DEBUG'', ''host'':''$HOST'', ''password'': ''$PASS'', ''port'': ''$PORT'', ''username'': ''$USUARIO''}' WHERE NM_VARIAVEL = 'parametros_smtp';"
	fi

	echo "### Fim da execucao."
}

### Main ###

# 01) Acressentar o schema pje_gim no serach_path do arquivo postgresql.conf
insere_schema

# 02) Preenche as configuracoes do smtp: tls, debug, host, port, password, usuario.
carrega_parametros

# 03) Atualiza o parametro parametros_smtp
atualiza_parametros_smtp