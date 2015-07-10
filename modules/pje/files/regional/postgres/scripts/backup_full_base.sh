#!/usr/bin/env bash
#
# backup_postgres_v2.sh
#
# Backup físico das bases de dados do PostgreSql.
# Coloca o servidor em modo de backup, compacta o diretório
# PGDATA e armazena o arquivo compactado no diretório especificado
# na variável BACKUPDIR.
# Ainda apaga os arquivos de backup mais antigos. O tempo de
# permanência dos arquivos é definido na variável DIAS.
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

# Variaveis obtidas do sistema
INICIO="`date +%Y-%m-%d_%H:%M:%S`"
HOST="`hostname`"

# Variaveis que precisam ser alteradas pelo Regional
DESTINATARIO="email@trtxx.jus.br,email@trtxx.jus.br"
REMETENTE="email@trtxx.jus.br"
BACKUPDIR="/u00/app/postgres/backup/full"
ERRORLOG="/u00/app/postgres/log/error.log"
PGUSER="postgres"
PGPORT="5432"
DIAS=10


# Verificando a existencia da variável PGDATA
if [ ! -e "$PGDATA" ]
then
  echo "Variavel de ambiente PGDATA nao esta definida." >> $ERRORLOG
  echo "Abortando..."
  echo "Verifique o log para maiores informacoes. ("$ERRORLOG")"
  cat $ERRORLOG | mail -s "Erro no backup fisico do postgresql em $HOST `date`" $DESTINATARIO;
  exit 1
fi


# Verificando a existencia dos diretórios de backup
if [ ! -d "$BACKUPDIR" ]
then
  echo "Diretorio de backup informado ("$BACKUPDIR") nao encontrado." >> $ERRORLOG
  echo "Abortando..."
  echo "Verifique o log para maiores informacoes. ("$ERRORLOG")"
  cat $ERRORLOG | mail -s "[TRT-XX] Erro no backup FULL do postgresql em $HOST `date`" $DESTINATARIO;
  exit 1
fi

# efetua o backup
psql -U $PGUSER -p $PGPORT -d postgres -c "select pg_start_backup('$INICIO', true);" 2> $ERRORLOG
tar czvfh $BACKUPDIR/backupFull_`date +"%Y-%m-%d"`.tgz $PGDATA 2>> $ERRORLOG
psql -U $PGUSER -p $PGPORT -d postgres -c "select pg_stop_backup();" 2>> $ERRORLOG


# limpa os tgz dos backups antigos, mantendo os ultimos 10 dias
find $BACKUPDIR/ -name "*" -mtime +$DIAS -type f -exec rm -f {} \;


# Envio do email de confirmacao
echo ">>> envio de email de confirmacao para $DESTINATARIO"
TEXTO="Backup full do banco de dados postgresql no host $HOST ocorreu com sucesso em `date`"
TEXTO="$TEXTO.\n\nRotina inciou em: $INICIO \nRotina terminou em: `date +%Y-%m-%d_%H:%M:%S`"
echo -e $TEXTO | mail $DESTINATARIO -s "[TRT-XX] Backup FULL do postgresql em $HOST OK" -- -r $REMETENTE


