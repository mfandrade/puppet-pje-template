#!/bin/bash
# Verifica as configuracoes do httpd para o PJe.
# Variaveis globais
DATA_HORA="$(date +'%y-%m-%d_%Hh%Mm')"
HOSTNAME=`eval hostname`
PASTA_DWLD="/tmp/PJE_CONF_"$HOSTNAME"_"$DATA_HORA
TEMP_CMD="temp_cmd.txt"


function limpar_verificacao_antiga
{
    # Limpar verificacoes antigas
    echo "Limpar verificacoes antigas..." 
    rm -rf $PASTA_DWLD
}

# ---------------------------------------------------
# Utilidades
function padroniza_arquivo
{
    # Remove comentário, linhas em branco, espaços e tabulações
    ARQUIVO=$1
    sed -i -e 's/#.*$//' -e 's/[ |\t]*//' -e '/^ *$/d' -e 's/[ |\t]*$//' $ARQUIVO
}

function padroniza_so
{
    # Remove linhas de comentários
    ARQUIVO=$1
    sed -i -e '/^#/ d' $ARQUIVO
}

function download_arquivo
{
    ARQUIVO=$1
    PATH_GIT=$2

    url="https://git.pje.csjt.jus.br/infra/regional/raw/master/$PATH_GIT/$ARQUIVO?private_token=PYQzPy47zFNtyApkdxhw"
    curl -s -k --create-dirs $url -o "$PASTA_DWLD/$ARQUIVO.csjt"
    padroniza_arquivo "$PASTA_DWLD/$ARQUIVO.csjt"
}

# ---------------------------------------------------
# Funções de checagem

function check_conf_file
{
    if [ $# -ne 4 ]; then
      echo "******************************************************"
      echo "As quantidades de parametros informados deveram ser 4."
      echo "1. Nome do arquivo que sera feito a comparacao."
      echo "2. Caminho do arquivo no repositorio GIT."
      echo "3. Caminho do arquivo na maquina local."
      echo "4. Nome da pasta que sera gravada o resultado."
      echo "******************************************************"
      exit 1
    fi

    CONF_PATH=$1 #ARQUIVO QUE SERA FEITA A VERIFICACAO
    PATH_GIT=$2 #CAMINHO DO ARQUIVO NO GIT
    PATH_LOCAL=$3 #CAMINHOO DO ARQUIVO LOCAL
    PATH_RESULT=$4 #CAMINHO DO DIRETORIO DE RESULTADO
    PASTA_RESULTADO=$PASTA_DWLD/$PATH_RESULT

    mkdir -p $PASTA_RESULTADO

    download_arquivo $CONF_PATH $PATH_GIT
    cp $PATH_LOCAL/$CONF_PATH "$PASTA_RESULTADO/$CONF_PATH.regional"
    mv "$PASTA_DWLD/$CONF_PATH.csjt" "$PASTA_RESULTADO/$CONF_PATH.csjt"
    padroniza_arquivo "$PASTA_RESULTADO/$CONF_PATH.regional"

    echo "#### Verificacao do arquivo $CONF_PATH"
    md5_original=$(md5sum "$PASTA_RESULTADO/$CONF_PATH.regional" | awk '{print $1}')
    md5_remoto=$(md5sum "$PASTA_RESULTADO/$CONF_PATH.csjt" | awk '{print $1}')
    if [ $md5_original = $md5_remoto ]
    then
	  check_file="OK"      
    else
      check_file="NOK"	  
	  echo "$CONF_PATH.regional | $CONF_PATH.csjt" > $PASTA_RESULTADO/'diff_'$CONF_PATH
      diff -y -t -W 200 --suppress-common-lines "$PASTA_RESULTADO/$CONF_PATH.regional" "$PASTA_RESULTADO/$CONF_PATH.csjt" >> $PASTA_RESULTADO/'diff_'$CONF_PATH
    fi
   # rm -rf $PASTA_DWLD
   #read -p "Aperte Enter para continuar..."
}

function baixa_arquivo_regional
{
if [ $# -ne 3 ]; then
      echo "******************************************************"
      echo "As quantidades de parametros informados deveram ser 3."
      echo "1. Nome do arquivo que sera baixado."
      echo "2. Caminho do arquivo na maquina local."
      echo "3. Nome da pasta que sera gravada o resultado."
      echo "******************************************************"
      exit 1
    fi
	CONF_PATH=$1 #ARQUIVO QUE SERA BAIXADO
    PATH_LOCAL=$2 #CAMINHO DO ARQUIVO LOCAL
    PATH_RESULT=$3 #CAMINHO DO DIRETORIO DE RESULTADO
    PASTA_RESULTADO=$PASTA_DWLD/$PATH_RESULT

    mkdir -p $PASTA_RESULTADO
	cp $PATH_LOCAL/$CONF_PATH "$PASTA_RESULTADO/regional.$CONF_PATH"
}

# ----------------------------------------------------
# Função para compactar a pasta
function compactar_pasta
{
    echo "Compatando arquivos para ser anexado na issue...."	
    cd /tmp
    NOME_ZIP="PJE_CONF_"$1"_"$HOSTNAME"_"$DATA_HORA".zip"
    /usr/bin/zip -rq "$NOME_ZIP" "$PASTA_DWLD"
    rm -rf "$PASTA_DWLD/"
    #mv "/tmp/$NOME_ZIP" "$PASTA_DWLD"
    echo "O arquivo /tmp/$NOME_ZIP foi gerado, por favor anexar na issue criado pelo regional."
}

# ----------------------------------------------------
# Função para rodar comando e imprimir o resultado
function check_comando 
{
    # Captura comando e coloca seu resultado em $CMD
    CMD=`eval "$1"`
    
    # Escreve a linha de titulo com "===" antes e depois
    TITULO="$2"
    TAM=$((80-${#TITULO}))
    LINHA_TITULO=""
    for i in $(seq $(($TAM/2))); do LINHA_TITULO=$LINHA_TITULO"="; done
    LINHA_TITULO="$LINHA_TITULO"" $TITULO "
    for i in $(seq $(($TAM/2))); do LINHA_TITULO=$LINHA_TITULO"="; done
    if [ $(($TAM%2)) = 1 ]; then LINHA_TITULO=$LINHA_TITULO"="; fi

    # Imprime o comando no arquivo temporario $TEMP_CMD
    echo "$LINHA_TITULO" >> "$PASTA_DWLD/$TEMP_CMD"
    echo "$CMD" >> "$PASTA_DWLD/$TEMP_CMD"
    echo "" >> "$PASTA_DWLD/$TEMP_CMD"
}
