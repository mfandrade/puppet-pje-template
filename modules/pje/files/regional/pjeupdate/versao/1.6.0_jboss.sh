#!/bin/bash

DIRks=/usr/java/default/jre/lib/security
#DIRks=/tmp
KEYSTORE='aplicacaojt.keystore'
SENHA=${1:-'654321'}
STATUS=
RFBCER='consultarfb.pje.tst.redejt'
GIT="https://git.pje.csjt.jus.br/infra/regional/raw/master/jboss/certificados/$RFBCER.crt"

function baixa_cer() {
   echo "Realizando download do certificado..."
   wget $GIT?private_token=PYQzPy47zFNtyApkdxhw --no-check-certificate -O /tmp/$RFBCER.crt
   if [ $? -ne 0 ]
   then
      echo "Erro no download do certificado."
      echo "Favor, reexecutar o script extra 1.6.0_jboss.sh ou realizar o procedimento
de inclusao do novo certificado no aplicacaojt.keystore.
O certificado esta disponivel em:
$GIT"
      exit 1
   fi
}

function insere_cer() {
  echo "Inserindo certificado $RFBCER"
  echo "$SENHA" | keytool -import -trustcacerts -noprompt -alias $RFBCER -file /tmp/$RFBCER.crt -keystore $DIRks/$KEYSTORE
}

function checa_cer() {
  echo $SENHA | keytool --v -list -alias $RFBCER -file $RFBCER.crt -keystore $DIRks/$KEYSTORE
  STATUS=$?
}

### MAIN ###

baixa_cer
#insere_cer
#checa_cer

cd /tmp
echo "
=================================================
===  NOVO CERTIFICADO PARA aplicacao.keystore ===
=================================================

Insira o novo certificado baixado em /tmp/$RFBCER para aplicacao.keystore.
Para isso, execute o comando abaixo (como root):
keytool -import -trustcacerts -alias $RFBCER -file /tmp/$RFBCER.crt -keystore $DIRks/$KEYSTORE

Confira a inclusao do certificado com o comando:
keytool --v -list -alias $RFBCER -file $RFBCER.crt -keystore $DIRks/$KEYSTORE
"


