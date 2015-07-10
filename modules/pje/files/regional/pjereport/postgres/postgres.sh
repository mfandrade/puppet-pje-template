# Grupo do CSJT/Infraestrutura                                                                       #
#                                                                                                    #
#                                                                                                    #
#  Contato:  pje-infraestrutura@csjt.jus.br                                                          #
#                                                                                                    #
#  Atualizacoes:                                                                                     #
#  22/07/2014 - Disponibilizada a primeira versao do script                                          #
#     Ref.     											     										 #
#	.Tabelas de estatisticas:								                                         #
#	   -http://www.postgresql.org/docs/9.2/static/monitoring-stats.html#PG-STAT-ACTIVITY-VIEW        #
#   .Planilha Atividades/Script.                                                                     #
#                                                                                                    #
#  "08/06/2015"                                                                                      #
#   Reformulação do código para facilitar manutenção                                                 #
#   Adicao de consultas para coletar dados das instancias e das bases                                #
#                                                                                                    #
#                                                                                                    #
#====================================================================================================#
########################################################
#IMPORTA ARQUIVO, VARIAVEIS E FUNCOES GERAIS#
########################################################
#Será utilizado a variavel $PASTA_DWLD
#Será utilizado a função de compare (diff)

installpath=/tmp/verificarPje
. $installpath/utils.sh
. $installpath/so.sh

########################################################
#DEFINICAO DE VARIAVEIS#
########################################################
#Define arquivos onde serão armazenados os logs
dir_db="$PASTA_DWLD/Postgres"
dir_db_log="$dir_db/pg_log"
file_name=""

#Variaveis de tempo
INICIO="`date +%Y-%m-%d_%H:%M:%S`"
FINAL=""

#Variaveis do Banco de Dados
pguser=`echo $PGUSER`
pgport=`echo $PGPORT`
database="postgres"
path_db=`echo $PGDATA`
data_pg_log=`date +%Y-%m-%d`

#Variaveis auxiliares
error=false
error_file=false
erro_log_db=""
erro_log_so=""
erro_log_pgbadger=""
testa="0"
count_pg_log="0"
count_pg_twopahse="0"
erro_array=( " " )
streamFile="streamFile"
streamFileError="streamFileError"
notifyErroConsulta=false
notifyErro=false
####################################################
#FUNCOES
####################################################

#FUNÇÃO: que trata as variaveis utilizadas no script. 
#Indica um valor mas da a opção para que o executor do script insira os valores que desejar.
confirma_variaveis ()
{
	desc=$1
	var=$2
	#Verifica usuario
	echo "$3"
	echo "Tecle [ENTER] para confirmar [Q] para sair ou altere para o valor correto !!!"
	
	echo "$desc: [$var]"
	read a
	if [ "$a" == "Q" ] || [ "$a" == "q" ] ; then
        	exit 0
	fi

        if test "$a" != "" ; then
		var=$a
		echo ""
	fi
}

#FUNÇÃO: que trata erros de execução de comando 
#sintaxe: erro "Mensagem de erro"
erroConsulta ()
{

if [ "$error_file" = true ]; 
then
	echo "--->Error"
	notifyErroConsulta=true
else
	echo "--->ok"
fi
	error_file=false
	
}

erro ()
{
if [ "$?" -ne 0 ]; 
then
	echo "--->Error"
	echo "$1" >> "$dir_db""ERROR"
	echo ""
	notifyErro=true	
else
	echo "--->ok"
fi
	
}

#FUNÇÃO:Executa a consulta "select now();" na base de dados "postgres" para caputurar a data atual no servidor de banco de dados.
#sintaxe: timestamp
timestamp () {

	psql -U $pguser -p $pgport -d postgres -t -c "select now ();"

}

#FUNÇÃO:Executa uma consulta SQL de acordo com os parâmetros pguser, pgport, database e filename. No arquivo ainda é registrada o timestamp antes e depois da consulta.
#sintaxe: consultaPSQL "consulta SQL"
consultaPSQL () {
	
	echo "" > $streamFile
	echo "Iniciado em:  $(timestamp)" >> $streamFile
	query="$1"
	echo "##############################################################" >> $streamFile
	echo "$query" >> $streamFile
	echo "##############################################################" >> $streamFile
	psql -U $pguser -p $pgport -d $database -c "$query" >> $streamFile 2>> $streamFile	
	
	if [ "$?" -ne 0 ]; 
    then
		error_file=true
		printError=true
	fi 
	
	echo "Finalizado em:  $(timestamp)" >> $streamFile
	echo "" >> $streamFile
	echo "" >> $streamFile
	
	if [ "$printError" = true ]; 
	then
		echo "Path: $file_name" >> "$dir_db""ERROR"
		cat streamFile >> "$dir_db""ERROR"
		echo "Houve um erro na consulta: " >> $file_name
		echo "##############################################################" >> $file_name
		echo "$query" >> $file_name
		echo "##############################################################" >> $file_name
		echo "" >> $file_name
		
		printError=false
	else
		cat streamFile >> $file_name
	fi
	
	rm $streamFile
	
}

#FUNÇÃO:Imprime uma string em um arquivo.
#sintaxe: echoFile "nome do arquivo"
echoFile(){

	echo $1 >> $file_name
	
}

nameFile() {

file_name_error="$1"
file_name="$dir_db$1" 
echo "" >> $file_name
echo "Criando $1"

}

#FUNÇÃO:Recupera diversas informações do banco, das bases de dados e do filesystem, dependendo do parâmetro passado (banco,bases,filesystem);
#sintaxe: recuperaInformacoes parametro
recuperaInformacoes ()
{
case "$1" in

	server)
		echo "==============================================================================="
		echo "Server" 
		echo "==============================================================================="	
		echo "Recuperando informações do postgres porta $pgport"
			nameFile "version"			
			echoFile "Recuperando versao do Banco de Dados..."
            consultaPSQL "select version ();" 			
			consultaPSQL "select current_timestamp;" 
			erroConsulta
			
			nameFile "database"
			echoFile "Recuperando configuracao dos Banco de Dados..." 
            consultaPSQL "select * from pg_database;" 
			erroConsulta
			
			nameFile "postgresql.conf.running"
			echoFile "Recuperando do Banco de Dados:  Parâmetros (running)..." 
			consultaPSQL "select name,current_setting(name) from pg_settings;" 
            erroConsulta

			nameFile "conexoes"
			echoFile "Informações sobre o pg_stat_activity"
			consultaPSQL "select * from pg_stat_activity;" 			
			echoFile "Informações sobre o conexoes ativas" 
			consultaPSQL "SELECT current_timestamp - least(query_start,xact_start) AS runtime, substr(query,1,65) AS query FROM pg_stat_activity WHERE NOT pid=pg_backend_pid() AND state='active' AND waiting = false AND (current_timestamp - least(query_start,xact_start)) > '00:00' ORDER BY 1 DESC;" 		
			erroConsulta			

			nameFile "datfrozenxid"			
			echoFile "Informações sobre o datfrozenxid" 
			consultaPSQL "SELECT datname, age(datfrozenxid) FROM pg_database;" 
			erroConsulta
			
			echo ""
			
			
	;;
		
	DB)
	
		#Busca as bases do PJE no padrão (pje\_grau%) e salva em uma array
		echo "Procurando as bases de dados do PJE"			
			arrayDatabases=( $(psql -U $pguser -p $pgport -d $database -t -c "select datname from pg_database where datname like 'pje\__grau%';") )
			erroConsulta
		echo ""
		# Iteração sobre cada base de dados encontrado na instância 
		for database in ${arrayDatabases[@]}; do		
		
			echo "==============================================================================="
			echo "Base: $database"
			echo "==============================================================================="
				
				#Consultas de tabelas que só existem na base principal do PJE
				if [[ $database == pje_[a-zA-Z0-9]*grau ]];
				then
					nameFile "$database""#jbpm"
					echoFile  "Informações das tabelas Jbpm" 							
					consultaPSQL "SELECT COUNT (*) FROM jbpm_byteblock;" 
					consultaPSQL "SELECT pg_size_pretty(pg_total_relation_size('JBPM_BYTEBLOCK'));"
					consultaPSQL "SELECT COUNT (*) FROM jbpm_bytearray;"
					consultaPSQL "SELECT pg_size_pretty(pg_total_relation_size('JBPM_BYTEARRAY'));"
					consultaPSQL "SELECT COUNT (*) FROM jbpm_variableinstance;" 				
					consultaPSQL "SELECT pg_size_pretty(pg_total_relation_size('JBPM_VARIABLEINSTANCE'));"
					erroConsulta
				fi
				
				nameFile "$database""#locks"
				echoFile "Informações sobre o pg_locks"
				consultaPSQL "select relation::regclass,* FROM pg_locks;"				
				echoFile "Informações sobre locks"
				consultaPSQL "select locked.pid AS locked_pid, locker.pid AS locker_pid,locked_act.usename AS locked_user,locker_act.usename AS locker_user,locked.virtualtransaction,locked.transactionid,relname FROM pg_locks locked LEFT OUTER JOIN pg_class ON (locked.relation = pg_class.oid),pg_locks locker,pg_stat_activity locked_act,pg_stat_activity locker_act WHERE locker.granted=true AND locked.granted=false AND locked.pid=locked_act.pid AND locker.pid=locker_act.pid AND locked.relation=locker.relation;"	
				echoFile "Informações sobre o pg_class"
				consultaPSQL "select pg_class.relname, pg_locks.transactionid, pg_locks.mode, pg_locks.granted as \"g\", pg_stat_activity.query,  pg_stat_activity.query_start, age(now(),pg_stat_activity.query_start) as \"age\",    pg_stat_activity.pid  from pg_stat_activity, pg_locks left outer join pg_class on (pg_locks.relation = pg_class.oid) where pg_locks.pid=pg_stat_activity.pid order by query_start;"
				echoFile "Informações sobre consultas bloqueadas..."
                consultaPSQL "SELECT blockeda.pid AS blocked_pid, blockeda.query as blocked_query, blockinga.pid AS blocking_pid, blockinga.query as blocking_query FROM pg_catalog.pg_locks blockedl JOIN pg_stat_activity blockeda ON blockedl.pid = blockeda.pid JOIN pg_catalog.pg_locks blockingl ON(blockingl.transactionid=blockedl.transactionid AND blockedl.pid != blockingl.pid) JOIN pg_stat_activity blockinga ON blockingl.pid = blockinga.pid WHERE NOT blockedl.granted AND blockinga.datname='$database';"
				erroConsulta

				nameFile "$database""#conexoesAtivas"
				echoFile "Informações sobre o conexoes ativas da base $database" 
				consultaPSQL "SELECT current_timestamp - least(query_start,xact_start) AS runtime, substr(query,1,65) AS query FROM pg_stat_activity WHERE NOT pid=pg_backend_pid() AND state='active' AND waiting = false  AND datname = '$database' AND (current_timestamp - least(query_start,xact_start)) > '00:00' ORDER BY 1 DESC;"
				erroConsulta
				
				nameFile "$database""#pg_stat_all_tables"
				echoFile "Last time at which this table/schema was manually vacuumed - not counting VACUUM FULL" 
				consultaPSQL "select schemaname, max(last_vacuum)  from pg_stat_all_tables group by schemaname;" 
				echoFile "Last time at which this table/schema was vacuumed by the autovacuum daemon" 
				consultaPSQL "select schemaname, max(last_autovacuum) from pg_stat_all_tables group by schemaname;" 	
				echoFile "Last time at which this table/schema was manually analyzed" 
				consultaPSQL "select schemaname, max(last_analyze) from pg_stat_all_tables group by schemaname;" 			
				echoFile "Last time at which this table/schema was analyzed by the autovacuum daemon" 
				consultaPSQL "select schemaname, max(last_autoanalyze) from pg_stat_all_tables group by schemaname;" 			
				echoFile "Demais informacoes estatísticas para cada tabela" 
				consultaPSQL "select schemaname, relid, relname,last_vacuum, last_autovacuum,last_analyze,last_autoanalyze, vacuum_count, autovacuum_count, analyze_count, autoanalyze_count from pg_stat_all_tables;" 					
				erroConsulta
				
				nameFile "$database""#outras_estatisticas"
				echoFile "pg_size_pretty"
				consultaPSQL "select pg_size_pretty(pg_database_size(current_database()));" 
				echoFile "Informações sobre o pg_prepared_xacts" 
				consultaPSQL "select * from pg_prepared_xacts;" 				
				echoFile "Informações sobre o pg_stat_activity" 
				consultaPSQL "select * from pg_stat_activity where datname = '$database';"				
				echoFile "Informações sobre o pg_locks"
				consultaPSQL "select relation::regclass,* FROM pg_locks;" 				
				echoFile "Informações sobre locks" 
				consultaPSQL "select locked.pid AS locked_pid, locker.pid AS locker_pid,locked_act.usename AS locked_user,locker_act.usename AS locker_user,locked.virtualtransaction,locked.transactionid,relname FROM pg_locks locked LEFT OUTER JOIN pg_class ON (locked.relation = pg_class.oid),pg_locks locker,pg_stat_activity locked_act,pg_stat_activity locker_act WHERE locker.granted=true AND locked.granted=false AND locked.pid=locked_act.pid AND locker.pid=locker_act.pid AND locked.relation=locker.relation;"			
				echoFile "Informações sobre locks" 
				consultaPSQL "select bl.pid AS blocked_pid, a.usename AS blocked_user, ka.query AS blocking_statement, now() - ka.query_start AS blocking_duration, kl.pid AS blocking_pid, ka.usename AS blocking_user, a.query  AS blocked_statement, now() - a.query_start  AS blocked_duration  FROM  pg_catalog.pg_locks bl  JOIN pg_catalog.pg_stat_activity a  ON a.pid = bl.pid JOIN pg_catalog.pg_locks kl ON kl.transactionid = bl.transactionid AND kl.pid != bl.pid JOIN pg_catalog.pg_stat_activity ka ON ka.pid = kl.pid WHERE NOT bl.granted;" 				
				echoFile "Informações sobre locks" 
				consultaPSQL "select pg_class.relname, pg_locks.transactionid, pg_locks.mode, pg_locks.granted as \"g\", pg_stat_activity.query,  pg_stat_activity.query_start, age(now(),pg_stat_activity.query_start) as \"age\",    pg_stat_activity.pid  from pg_stat_activity, pg_locks left outer join pg_class on (pg_locks.relation = pg_class.oid) where pg_locks.pid=pg_stat_activity.pid order by query_start;" 
				erroConsulta				

				echo ""
				
		done
		
	;;
	
	fs)
		echo "==============================================================================="
		echo "FS"
		echo "==============================================================================="
		echo "Recuperando ocorrencias de arquivos em pg_twophase..."
			ls -la "$path_db"/pg_twophase  > "$dir_db/pg_twophase" 2>> "$dir_db""ERROR"
			erro "Falha ao tentar listar arquivos em $path_db/pg_twophase" 
			count_pg_twophase=`eval "ls "$path_db"/pg_twophase | wc -l "`
			if test "$erro" == "0"
			then
				echo "    $count_pg_twophase ocorrencias em pg_twophase"
			fi

		echo "Recuperando Arquivos de log (pg_log)..."
			cp "$path_db"/pg_log/*"$data_pg_log"*.log "$dir_db_log" 2>> "$dir_db""ERROR"
			erro "Falha ao copiar arquivos de log (pg_log)" 
		if test "$erro" == "0" 
		then 
			echo "    $count_pg_log arquivo(s) copiado(s)."
		fi

		echo "Recuperando arquivo postgresql.conf..."
			cat "$path_db"/postgresql.conf > "$dir_db/"postgresql.conf 2>> "$dir_db""ERROR"
			erro "Falha ao copiar arquivo postgresql.conf"
			
		echo "Recuperando arquivo pg_hba.conf..."
			cat "$path_db"/pg_hba.conf > "$dir_db/"pg_hba.conf 2>> "$dir_db""ERROR"
			erro "Falha ao copiar arquivo pg_hba.conf"
		echo ""
	
	;;
esac

}

echo "==============================================================================="
echo "INICIANDO: TESTANDO VARIAVEIS...CRIANDO DIRETORIOS ETC."
echo "==============================================================================="

echo ""
echo "Verificando Variaveis de ambiente..."
echo ""

#Chama função e em seguida testa se as variaveis do banco estao corretas.
confirma_variaveis "Usuario do Banco de Dados." "$pguser" "PGUSER: Usuario do Banco de Dados." "db"; pguser=$var
confirma_variaveis "Porta do Banco de Dados." "$pgport" "PGPORT: Porta do Banco de Dados." "db"; pgport=$var

# Linha removida
#confirma_variaveis "Nome do Banco de Dados." "$database" "DATABASE: Nome do Banco de Dados." "db"; database=$var

#Chama função e em seguida testa se o valor do Diretorio é correto
confirma_variaveis "Diretorio pgdata" "$path_db" "PGDATA: Diretorio de instalacao do Banco de Dados" "so"
        testa="0"
        while test "$testa" == "0"
        do
                if [ -d "$var/pg_twophase" ]
                then
                        testa="1"
                        path_db=$var
                else
                        echo ""
                        echo "O diretorio '"$var"' nao existe, não é o diretório desejado ou pode ser problema de permissão."
			echo "Verifique novamente!!!";
                        confirma_variaveis "Diretorio pgdata" "$path_db" "PGDATA: Diretorio de instalacao do Banco de Dados" "so"
                fi
        done

#Chama função e em seguida testa se existe arquivo com a Data informada
confirma_variaveis "Arquivo de log (pg_log.)" "$data_pg_log" "Data do arquivo de log (/pg_log.)" "so";
	testa="0"
        while test "$testa" == "0"
        do
		count_pg_log=`eval "ls -la $path_db/pg_log/ | grep $var | wc -l"`
		if [ $count_pg_log != 0 ]
                then
                        testa="1"
                        data_pg_log=$var
                else
                        echo ""
                        echo "Não existe arquivo com a data informada. Verifique novamente!!!";
                        confirma_variaveis "Arquivo de log (pg_log.)" "$data_pg_log" "Data do arquivo de log (/pg_log.)" "so"
		fi
        done	

#Cria diretório para armazenamento dos dados
mkdir $dir_db
mkdir $dir_db_log

echo ""
echo "==============================================================================="
echo "RECUPERANDO INFORMACOES"
echo "==============================================================================="
echo ""
#Chama função para recuperar dados do Banco
dir_db="$PASTA_DWLD/Postgres/server#"
recuperaInformacoes server

#Chama função para recuperar dados das bases de dados
dir_db="$PASTA_DWLD/Postgres/DB#"
recuperaInformacoes DB

#Chama função para recuperar arquivos de sistema
dir_db="$PASTA_DWLD/Postgres/"
recuperaInformacoes fs

echo ""
echo "==============================================================================="
echo "Procedimentos finais"
echo "==============================================================================="
echo ""
#Chama função para comparar arquivos
echo "Comparando 'postgresql.conf' recomendado (GIT) e o 'postgresql.conf' da Regional"
check_conf_file "postgresql.conf" "postgres/configuracao" "$dir_db" "Postgres/Postgres-Diff"
echo ""

#Gera relaório pgbadger
echo "Gerando relatórios pgbadger..."
pgbadger -q "$dir_db_log"/* -o "$dir_db_log"/pgbadger.html 2>> "$dir_db""ERROR"
erro "Falha ao executar o pgbadger"
echo ""


#Chama função para compactar o resultado dos arquivos
echo "Compactando arquivos..."
compactar_pasta "POSTGRES"
echo ""


if   [ "$notifyErroConsulta" = true ] || [ "$notifyErro" = true ]; then
	
	echo ""
	echo "==============================================================================="
	echo "ERROS"
	echo "==============================================================================="
	echo ""

fi

if [ "$notifyErro" = true ]; then
	
	echo "Houveram erros na coleta dos arquivos de configuração."
	echo "Verifique o arquivo ERROR"
	echo ""

fi

if [ "$notifyErroConsulta" = true ]; then
	
	echo "Houveram erros nas consultas SQL."
	echo "Verifique os arquivos DB#ERROR e server#ERROR"
	echo ""

fi


echo ""
echo "==============================================================================="
echo "RESULTADO"
echo "==============================================================================="
echo ""

echo "..O arquivo /tmp/$NOME_ZIP foi criado."
echo "  Por favor anexe esse arquivo na issue."
echo ""

if [ "$check_file" != "OK" ] ; then
	echo "..Problemas:"
	echo "  A configuração do 'postgresql.conf' está diferente do padrão recomendado."
	echo ""
fi

echo "..Tempo de execução:"
FINAL="`date +%Y-%m-%d_%H:%M:%S`"

echo "  Rotina inciou em: $INICIO"
echo "  Rotina terminou em: $FINAL"
echo ""
echo ""
