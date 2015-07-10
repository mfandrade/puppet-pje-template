#!/bin/bash
# verifica_conf_httpd - Verifica as configuracoes do httpd para o PJe.

# Variaveis globais
## APACHE
APACHE_PASTA_CONF='/etc/httpd'
APACHE_PATH_GIT='apache/conf/'
APACHE_PATH_LOCAL='conf'

#PASTA_DWLD="/tmp/$(date | md5sum | awk '{print $1}')"
PASTA_DWLD="/tmp/result"

# ---------------------------------------------------
# Utilidades

function padroniza_arquivo
{
    # Remove comentário, linhas em branco, espaços e tabulações
    arquivo=$1
    sed -i -e 's/#.*$//' -e 's/[ |\t]*//' -e '/^ *$/d' -e 's/[ |\t]*$//' $arquivo
}

function download_arquivo
{
    arquivo=$1
    url="https://git.pje.csjt.jus.br/infra/regional/raw/master/$APACHE_PATH_GIT$arquivo?private_token=PYQzPy47zFNtyApkdxhw"
    curl -s -k --create-dirs $url -o "$PASTA_DWLD/$arquivo.remoto"
    padroniza_arquivo "$PASTA_DWLD/$arquivo.remoto"
}

# ---------------------------------------------------
# Funções de checagem

function check_conf_file
{
    conf_path=$1
    download_arquivo $conf_path
    cp $APACHE_PASTA_CONF/$APACHE_PATH_LOCAL/$conf_path "$PASTA_DWLD/$conf_path.original"
	padroniza_arquivo "$PASTA_DWLD/$conf_path.original"

    echo "#### Verificação do arquivo $conf_path ####"
    md5_original=$(md5sum "$PASTA_DWLD/$conf_path.original" | awk '{print $1}')
    md5_remoto=$(md5sum "$PASTA_DWLD/$conf_path.remoto" | awk '{print $1}')
    if [ $md5_original = $md5_remoto ]
    then
      echo "Configuração OK."
    else
      echo "Configuração com problema."
      diff -u "$PASTA_DWLD/$conf_path.original" "$PASTA_DWLD/$conf_path.remoto" > $PASTA_DWLD/$conf_path'_diff'
    fi
   # rm -rf $PASTA_DWLD
    #read -p "Aperte Enter para continuar..."
}

# Main 
check_conf_file 'httpd.conf'
#check_conf_file 'conf/workers.properties'
#check_conf_file 'conf.d/modjk.conf'
#check_conf_file 'conf.d/modsecurity.conf'
#check_conf_file 'conf.d/vhosts.conf'
#check_conf_file 'conf.d/mod_deflate.include'