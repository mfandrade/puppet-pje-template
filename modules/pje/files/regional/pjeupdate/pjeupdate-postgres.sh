#!/bin/bash
# Nome: pjeupdate-postgres.sh
# Descricao: Executar os procedimentos necessarios para atualizacao do PJe.
# Responsavel: SITEC - CSJT

### Variaveis ###
PROPERTIES='./pjeupdate-postgres.properties'
NEXUS_USR='atualizacao'
NEXUS_PSW='pje123456'

### Funcoes Auxiliares ###

# Verifica MD5
function verifica_md5
{
 arquivo=$1
 url="$URL_NEXUS/$VERSAO/$arquivo.md5"
 echo -e "### Verificacao do md5sum..."
 md5_csjt=$(wget --user $NEXUS_USR --password $NEXUS_PSW -q -O- $url)
 md5_local=$(md5sum $DIR_INSTALACAO/$arquivo | awk '{printf $1}')
 if [ $md5_csjt != $md5_local ]
  then
    echo -e "### Falha na verificacao do md5. Provalvemente o arquivo esta corrompido."
    exit 1
  else
    echo "### OK."
 fi
}

# Verifica o retorno da execucao do jar(0=sucesso 1=erro)
function verifica_execucao
{
  if  [ $? -eq  1 ]
  then
    echo "### Falha na execucao!"      
    exit 1
  fi
}

# Executa o DbManager no primeiro grau
function atualizar1grau
{
 echo "### Executando scripts do primeiro grau"
 java -Dfile.encoding='iso-8859-1' -jar $DIR_INSTALACAO/DBManager.jar $BD_SERVER_1G:$BD_PORTA_1G $BASE_1GRAU $BD_USUARIO_1G $BD_SENHA_1G $DIR_SCRIPTS
 verifica_execucao
}

# Executa o DbManager no segundo grau
function atualizar2grau
{
 echo "### Executando scripts do segundo grau"
 java -Dfile.encoding='iso-8859-1' -jar $DIR_INSTALACAO/DBManager.jar $BD_SERVER_2G:$BD_PORTA_2G $BASE_2GRAU $BD_USUARIO_2G $BD_SENHA_2G $DIR_SCRIPTS
 verifica_execucao
}

# Executa o DbManager no terceiro grau
function atualizar3grau
{
echo "### Executando scripts do terceiro grau"
   java -Dfile.encoding='iso-8859-1' -jar $DIR_INSTALACAO/DBManager.jar $BD_SERVER_3G:$BD_PORTA_3G $BASE_3GRAU $BD_USUARIO_3G $BD_SENHA_3G $DIR_SCRIPTS
   verifica_execucao
}

# Valida acesso url's nexus e git
function validar_urls
{
urlnexus=$URL_NEXUS/$VERSAO
echo "### Validando url do nexus: $urlnexus "
wget --user $NEXUS_USR --password $NEXUS_PSW $urlnexus --spider -q
erro

url_dbmanager="$URL_DBMANAGER?private_token=PYQzPy47zFNtyApkdxhw"
echo "### Validando url do DBManager.jar: $URL_DBMANAGER "
wget $url_dbmanager --spider -q --no-check-certificate
erro

url_zip=$URL_NEXUS/$VERSAO/$ARQUIVO.zip
echo "### Validando url dos scripts sql: $url_zip "
wget $url_zip --spider -q --no-check-certificate
erro

#url_script_aux="$URL_SCRIPT_AUX/$VERSAO""_postgres.sh?private_token=PYQzPy47zFNtyApkdxhw"
#echo "### Validando url do script auxiliar: $URL_SCRIPT_AUX/$VERSAO""_postgres.sh"
#wget $url_script_aux --spider -q --no-check-certificate
#erro

url_md5="$URL_NEXUS/$VERSAO/$ARQUIVO.zip.md5"
echo "### Validando url do md5: $url_md5"
wget $url_md5 --spider -q --no-check-certificate
erro
}

# Verifica a variavel $PGDATA, se o psql esta no path e testa a url do banco
function validacoes_iniciais_banco
{
echo "### Validando caminho da variavel de ambiente PGDATA"
if [ -f $PGDATA/PG_VERSION ]
then
  echo "### OK."
else
  echo "### A variavel de ambiente PGDATA nao esta configurada."
  exit 1
fi

echo "### Validando configuracao do psql"
psql -V
if [ $? -eq 0 ]
 then
  echo "### OK"
else
  echo "### ERRO: psql nao consta na variavel de ambiente PATH"
  exit 1
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

# Trata erros referentes ao curl
erroc(){
retorno=$?
case "$retorno" in
        0)
                echo "### OK"
                echo ""
        ;;
        1)
                echo "### Protocolo nao suportado. "
                echo ""
                exit 1
        ;;
        2)
                echo "### Falha na inicializacao."
                echo ""
                exit 1
        ;;
        3)
                echo "### Erro na URL."
                echo ""
                exit 1
        ;;
        5)
                echo "### ERRO: Nao foi possivel resolver o proxy."
                echo ""
                exit 1
        ;;
        6)
                echo "### ERRO: Não foi possivel resolver o endereco do host destino."
                echo ""
                exit 1
        ;;
        7)
                echo "### Falha ao conectar no host destino."
                echo ""
                exit 1
        ;;
        22)
                echo "### ERRO: Arquivo ou diretorio requisitados nao existem."
                echo ""
                exit 1
        ;;
        28)
                echo "### ERRO: Atingido tempo limite da transacao."
                echo ""
                exit 1
        ;;
	35)
                echo "### Erro na negociacao SSL."
                echo ""
                exit 1
        ;;
	37)
                echo "### Nao foi possivel acessar o arquivo, verifique as permissoes."
                echo ""
                exit 1
        ;;
        67)
                echo "### Falha no login, usuario ou senha invalidos."
                echo ""
                exit 1
        ;;
        *)
                echo "### Erro desconhecido. Codigo do erro: $retorno"
                echo ""
                exit 1
        ;;
esac
}

### Funcoes Principais ###

# 0) Validacoes iniciais
function validacoes_iniciais
{
# Verifica presenca do arquivo .properties
if [ -f $PROPERTIES ]
then
   source $PROPERTIES
else
  echo "Obrigatoria a presenca do arquivo $PROPERTIES."
  exit 1
fi

ARQUIVO="pje-jt-$VERSAO"

# Verifica se o java esta instalado
java -version
if [ $? -eq 0 ]
 then
  echo "### Instalacao java OK"
else
  echo "### Java nao instalado"
  exit 1
fi

# Verifica variavel de versao
if [ -z $VERSAO ]
then
  echo "Uso: Preencha no arquivo .properties o valor da variavel VERSAO, com a versao a ser atualizada "
  exit 1
fi

# Valida acesso url's nexus e git
validar_urls

# Verifica se a versao e valida
urlv=$URL_NEXUS/$VERSAO/$ARQUIVO.zip
echo "### Verificando versao..."
if ! wget --user $NEXUS_USR --password $NEXUS_PSW $urlv --spider -q
  then
    echo "A versao fornecida ($VERSAO) nao representa um arquivo .zip valido."
    exit 1
fi
echo "### OK"

# Verifica a variavel $PGDATA, se o psql esta no path e testa a url do banco
validacoes_iniciais_banco
}

# 1) Limpa diretorio
function limpa_diretorio
{
 echo "### Limpando diretorio de instalacao"
 rm -rf $DIR_INSTALACAO
 mkdir -p $DIR_INSTALACAO
 mkdir -p $DIR_INSTALACAO/versao
}

# 2) Baixa os scripts da url informada no arquivo de propriedades (pjeupdate-postgres.properties) e descompacta no dirtorio de scripts (/tmp/instalacao_db/scripts)
function baixar_scripts 
{
 echo "### Realizando dowload dos scripts..."
 wget --user $NEXUS_USR --password $NEXUS_PSW $URL_NEXUS/$VERSAO/$ARQUIVO.zip -O $DIR_INSTALACAO/$ARQUIVO.zip
 erro
 verifica_md5 $ARQUIVO.zip
 echo "### descompactando scripts"
 unzip -q $DIR_INSTALACAO/$ARQUIVO.zip -d $DIR_SCRIPTS
}

# 3) Baixa e executa o DbManager
function executar_dbmanager 
{
 echo "### Realizando dowload do DBManager..."
 url="$URL_DBMANAGER?private_token=PYQzPy47zFNtyApkdxhw"
 curl -s -k --create-dirs $url -o "$DIR_INSTALACAO/DBManager.jar"
 erroc

 echo "### Inicio da execucao do DBManager"
 
for grau in $GRAUS
  do
    case $grau in
      1) atualizar1grau ;;
      2) atualizar2grau ;;
      3) atualizar3grau ;;
      *) echo "Opcao de grau $grau fornecida invalida." ;;
    esac
done

}

# 4) Baixa e executa script auxiliar, caso exista.
function executar_script_auxiliar
{
 urlsa="$URL_SCRIPT_AUX/$VERSAO""_postgres.sh?private_token=PYQzPy47zFNtyApkdxhw"
if wget --user $NEXUS_USR --password $NEXUS_PSW $urlsa --no-check-certificate --spider -q
  then
    echo "Realizando download do script auxiliar $VERSAO""_postgres.sh"
    wget --user $NEXUS_USR --password $NEXUS_PSW $urlsa --no-check-certificate -q -O "$VERSAO""_postgres.sh"
    erro
    echo "Executando script auxiliar $VERSAO""_postgres.sh "    
    chmod +x $VERSAO""_postgres.sh
    sh $VERSAO""_postgres.sh
 fi

}

### MAIN ###

# 0) Realiza as validacoes iniciais
validacoes_iniciais

# 1) Limpa diretorio
limpa_diretorio

# 2) Baixa os scripts da url informada no arquivo de propriedades (pjeupdate-postgres.properties) e descompacta no dirtorio de scripts (/tmp/instalacao_db/scripts)
baixar_scripts

# 3) Baixa e executa o DbManager
executar_dbmanager

# 4) Executa script auxiliar
executar_script_auxiliar

echo "###########"
echo "# Atencao #"
echo "###########"
echo "Apos a execucao dos scripts e necessario realizar a manutencao basica no banco (vacuum full e analyze)."
echo "Mais detalhes no documento - Automatizar Atualizacao do PJe-JT."
