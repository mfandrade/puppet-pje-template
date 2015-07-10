#!/bin/bash
# Nome: pjeupdate-apache.sh
# Descricao: Excutar os procedimentos necessarios para atualizacao do PJe.
# Responsavel: SITEC - CSJT

### Variaveis ###
DIR_MOD_CACHE='/var/cache/httpd/mod_cache/'
MOD_CACHE=`eval apachectl -M |grep -ow "cache_module"`

# Verifica se o mod_cache esta carregado
function verifica_mod_cache 
{
 if [ $MOD_CACHE != 'cache_module' ]
 then
	echo '### Erro, mod_cache não está carregado !!!'
	exit 1
 fi
}

#### Funcoes Principais ####
# 0 Verificacoes iniciais
function verificacoes_iniciais
{
 verifica_mod_cache
}

# 1 - Realiza a limpeza do cache  do apache
function limpar_cache 
{
 echo '### Conteudo do diretorio de cache antes da limpeza.'
 ls -lh $DIR_MOD_CACHE
 echo '### Executando limpeza do cache do apache'
 chmod u+x /etc/init.d/htcacheclean
 service httpd stop
 killall htcacheclean
 rm -rf $DIR_MOD_CACHE*
 /etc/init.d/htcacheclean
 service httpd start

 echo '### Conteudo do diretorio de cache apos a limpeza.'
 ls -lh $DIR_MOD_CACHE
 
 echo '### Script executado com sucesso!'
}

#### MAIN ####
# 0 Verificacoes iniciais
verificacoes_iniciais

# 1 - Realiza a limpeza do cache  do apache
limpar_cache