#!/usr/bin/env bash
#
# copia_banco.sh
#
# Realiza a cópia de um banco de dados do PostgreSQL.
#
# Autor: alvaro.gastal@trt12.jus.br
#
# Manutenção: Álvaro Gastal (alvaro.gastal@trt12.jus.br)
#             Eduardo Corrêa (eduardo.correa@tst.jus.br)
#             Marcus Klein (marcusk@trt7.jus.br)
#
# Modificações: christiano.carvalho@tst.jus.br
# - Criação da variável 'caminho' para definir o diretório do backup
# - Ajuste no comando para matar as conexoes do banco 
# - Modificação na lógica do usuário ownerDestino para permanecer com a mesma permissão tanto antes quanto depois da execução do script
################################################

hostOrigem=$1
userOrigem=$2
portOrigem=$3
dbOrigem=$4
hostDestino=$5
superUserDestino=$6
portDestino=$7
dbDestino=$8
ownerDestino=$9
tbspcDestino=${10}
tmpdir=/u00/app/postgres/pgprd01/tmp
ERRORLOG=/u00/app/postgres/pgprd01/tmp/copia_banco.log

if [ $# != 10 ]; then
   echo "Copia um banco de origem em um banco de destino. ATENCAO: Dropa o destino, caso exista!"
   echo "Use: copia_banco.sh hostOrigem userOrigem portOrigem dbOrigem hostDestino superUserDestino portDestino dbDestino ownerDestino tbspcDestino"
   exit 1;
fi

job=($(grep processor /proc/cpuinfo|wc -l))
# Limpa o arquivo temporario se existir
find $tmpdir/ -name "$dbOrigem.backup" -type f -exec rm -f {} \;

# Exporta o banco de origem
echo -e "\n Exportando $dbOrigem"
pg_dump -F c -Z 0 -h "$hostOrigem" -p "$portOrigem" -U "$userOrigem" -w -C -f $tmpdir/$dbOrigem.backup $dbOrigem > $ERRORLOG

# Mata as conexoes de destino
echo -e "\n Matando conexoes em $dbDestino"
psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" $dbDestino -w -c "SELECT pg_terminate_backend(procpid) FROM pg_stat_activity WHERE procpid <> pg_backend_pid() and lower(datname)='$dbDestino'" >> $ERRORLOG

# Apaga banco de destino
echo -e "\n Dropando $dbDestino"
dropdb -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -w $dbDestino  >> $ERRORLOG

# Cria banco de destino
echo -e "\n Criando $dbDestino"
createdb -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -O "$ownerDestino" -w -E "LATIN1" -T "template0" --lc-collate "C" --lc-ctype "C" $dbDestino -D "$tbspcDestino" >> $ERRORLOG


# Cria a variavel bytea_output
echo -e "\n Setando bytea_output para escape em $dbDestino"
psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -d $dbDestino -w -c "ALTER DATABASE $dbDestino SET bytea_output='escape'"  >> $ERRORLOG
psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -d $dbDestino -w -c "ALTER ROLE $superUserDestino IN DATABASE $dbDestino SET bytea_output='escape'" >> $ERRORLOG
psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -d $dbDestino -w -c "ALTER ROLE $ownerDestino IN DATABASE $dbDestino SET bytea_output='escape'" >> $ERRORLOG

# Verifica se ownerDestino e superuser ou nao
SU=(`psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -d "postgres" -w -c "select usesuper from pg_user where usename = '$ownerDestino'"`)

# Converte o owner de destino em super usuario de banco
if [ "${SU[2]}" == "f" ]; then
   echo -e "\n Concedendo superpoderes para $ownerDestino em $hostDestino"
   psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -d "postgres" -w -c "ALTER ROLE $ownerDestino SUPERUSER" >> $ERRORLOG
   psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -d "postgres" -w -c "UPDATE pg_authid SET rolcatupdate=true WHERE lower(rolname)='$ownerDestino'" >> $ERRORLOG;
fi

# importa o banco no destino
echo -e "\n Importando $dbOrigem em $dbDestino"
pg_restore -F c -h "$hostDestino" -p "$portDestino" -U "$ownerDestino" -O -w -j $job -d $dbDestino $tmpdir/$dbOrigem.backup >> $ERRORLOG

# Remove os poder de super usuario do owner de destino

if [ "${SU[2]}" == "f" ]; then
   echo -e "\n Retirando superpoderes de $ownerDestino em $hostDestino"
   psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -d "postgres" -w -c "ALTER ROLE $ownerDestino NOSUPERUSER" >> $ERRORLOG
   psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -d "postgres"  -w -c "UPDATE pg_authid SET rolcatupdate=false WHERE lower(rolname)='$ownerDestino'" >> $ERRORLOG;
fi

# limpa o arquivo temporario
find $tmpdir/ -name "$dbDestino.backup" -type f -exec rm -f {} \;
