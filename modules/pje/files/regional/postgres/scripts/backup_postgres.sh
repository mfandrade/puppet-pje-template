#!/usr/bin/env bash
#
# backup_postgres.sh
#
# Backup lógico das bases de dados do PostgreSql.
# Captura todas as bases de dados, realiza o backup, compacta
# e armazena o arquivo compactado no diretório especificado
# na variável BACKUPDIR.
# Ainda apaga os arquivos de backup mais antigos (criados ha
# mais de 10 dias).
#
# Autor     : Alvaro Gastal (alvaro.gastal@trt12.jus.br) e
#             Christiano Carvalho (christiano.carvalho@tst.jus.br)
# Manutenção: Eduardo Corrêa (eduardo.correa@tst.jus.br)
#             Marcus Klein (marcusk@trt7.jus.br)
#
# Esse script encontra-se versionado no git em
# http://git.pje.csjt.jus.br/infra/regional/tree/master/postgresql/scripts
#
# Qualquer dívida sobre este script mande um email para
# pje-infraestrutura@csjt.jus.br
#
#
# Execução:
# ./backup_postgres_v2.sh
#
# Oservações:
# É preciso alterar as variáveis DESTINATARIO, REMETENTE, BACKUPDIR,
# ERRORLOG, PGUSER e PGPORT conforme for a realidade do Regional.
#
############################################################################

#!/bin/bash
# Backup das Bases de Dados do PostgreSql #
# Captura todas as bases de dados, faz backup, compactada, mantem os utlimos 10 backups de cada base e envia emails #
# Contato: christiano.carvalho@tst.jus.br #
# Ultima atualizacao: 08-08-2012 - Christiano #
##################################

#@ Variaveis
INICIO="`date +%Y-%m-%d_%H:%M:%S`"
HOST="`hostname`"
DESTINATARIO="email@trtxx.jus.br,email@trtxx.jus.br"
REMETENTE="email@trtxx.jus.br"
DIAS=30
DIR=/u00/app/postgres/backup/data
ERRORLOG="/u00/app/postgres/log/error.log"
ERROR=0
PGUSER="postgres"
PGPORT="5432"
FORMATO="c"
BASES=""

#@ Pega todas as bases de dados direto do Postgres
DATABASES=(`psql -U $PGUSER -p $PGPORT -d postgres -c "select datname from pg_database where datname not like 'template%';"`)
if [ "$?" -ne 0 ]; then
   echo "ERRO: Bases de dados não encontradas !";
   ERROR=1;
fi

#@ Para cada database encontrada no Postgres, executa o dump e compacta
cd $DIR
#@ Exclui as duas primeiras e as duas ultimas linhas pois nao sao bases de dados
for((i=2;i<${#DATABASES[@]}-2;i++))
do
   echo ">>> dump DB ${DATABASES[$i]}"
   BASES="$BASES${DATABASES[$i]}\n"
   pg_dump -U $PGUSER -p $PGPORT -C -f ./${DATABASES[$i]}.backup -F $FORMATO ${DATABASES[$i]} 2> $ERRORLOG
   if [ "$?" -ne 0 ]; then
      echo "ERRO ao gerar dump DB $i: '${DATABASES[$i]}'";
      ERROR=1;
   fi
   echo ">>> compactando dump do DB ${DATABASES[$i]}"
   tar -cvzf ${DATABASES[$i]}_`date +"%Y-%m-%d"`.tgz ./${DATABASES[$i]}.backup 2>> $ERRORLOG
   if [ "$?" -ne 0 ]; then
      echo "ERRO ao compactar dump do DB $i: '${DATABASES[$i]}'";
      ERROR=1;
   fi
done

#@ Apaga os arquivos de backup e mantem apenas os arquivos compactados
rm $DIR/*.backup

#@ limpa os arquivos antigos, mantendo os ultimos dias definido na variavel DIAS 
find $DIR/ -name "*.tgz" -mtime +$DIAS -type f -exec rm -f {} \;

#@ Envia email de confirmacao
echo ">>> envio de email de confirmacao para $EMAIL"
if [ "$ERROR" -eq 1 ]; then
   cat $ERRORLOG | mail $DESTINATARIO -s "[TRT-XX] Erro no backup $HOST `date`";
else
   TEXTO="Backup das bases de dados do PJe-JT do host $HOST foi gerado com sucesso em `date`:"
   TEXTO="$TEXTO\n\n$BASES\nRotina inciou em: $INICIO \nRotina terminou em: `date +%Y-%m-%d_%H:%M:%S`"
   echo -e $TEXTO | mail $DESTINATARIO -s "[TRT-XX] Backup PJe $HOST OK" -- -r $REMETENTE
fi

#@ Mostra duracao da rotina
echo "Rotina inciou em: $INICIO"
echo "Rotina terminou em: `date +%Y-%m-%d_%H:%M:%S`"
