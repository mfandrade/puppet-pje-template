#!/bin/bash
. logs.conf



# HISTORICO
# 0 = faz o backup do(s) mese(s) anteriores, e nao mantem historico no banco de dados
# 1 = faz o backup do(s) mese(s) anterior(es), mantendo um mes de historico no banco de dados
# 2 = faz o backup do(s) mese(s) anterior(es), mantendo dois meses de historico no banco de dados
# n = faz o backup do(s) mese(s) anterior(es), mantendo "n"  meses de historico no banco de dados, ateh o limite de 48 meses
# 99 = faz o backup do(s) meses(s) anterior(es), e nao apaga o historico no banco de dados

apaga_tabelas_log(){
if [[ $HISTORICO == 0 ]];then
  date +%F\ %Hh%Mm%Ss >> $LOG
  gera_log delete tb_log_detalhe 0
  $PSQL  "TRUNCATE FROM core.tb_log_detalhe" $NOME_DO_BANCO_DE_DADOS
  date +%F\ %Hh%Mm%Ss >> $LOG
  gera_log delete tb_log 0
  $PSQL  "TRUNCATE FROM core.tb_log" $NOME_DO_BANCO_DE_DADOS
elif [[ $HISTORICO <=48 ]];then
  # Se o arquivo "arquiva.dt" existe, apague...
  rm arquiva.dt -f
  # ... e popule com as datas que serão apagadas. 
  $PSQL "SELECT DISTINCT '|'||date_part('year',dt_log)||'|'||date_part('month',dt_log) as data FROM tb_log WHERE dt_log <  to_date(to_char((now() - INTERVAL '$HISTORICO month'),'YYYY-MM'),'YYYY-MM') ORDER BY data" $NOME_DO_BANCO_DE_DADOS | sed '/^$/d' >  arquiva.dt
  # verifica quantas linhas foram criadas no arquivo
  tamanho=$(wc -l arquiva.dt |cut -d' ' -f1)
  (( tamanho++ ))


  # para cada linha do arquivo arquiva.dt...
  for (( i=1,j=1; i<$tamanho;i++,j++));do
    # ... identifique o mes e ano, e coloque na variavel MES e ANO...
    ANO=$( sed -n "$i,$i p" arquiva.dt |cut -d '|' -f 2 )
    MES=$( sed -n "$j,$j p" arquiva.dt |cut -d '|' -f 3 )
    # ... e apaga os logs do mês/ano selecionado.
    date +%F\ %Hh%Mm%Ss >> $LOG
    gera_log delete tb_log_detalhe
    $PSQL "DELETE FROM core.tb_log_detalhe WHERE id_log IN (SELECT id_log FROM core.tb_log WHERE dt_log  BETWEEN '$ANO-$MES-01' AND (DATE '$ANO-$MES-01' + INTERVAL '1 month'))" $NOME_DO_BANCO_DE_DADOS
    date +%F\ %Hh%Mm%Ss >> $LOG
    gera_log delete tb_log
   $PSQL "DELETE FROM core.tb_log WHERE  dt_log BETWEEN '$ANO-$MES-01' AND (DATE '$ANO-$MES-01' + INTERVAL '1 month')" $NOME_DO_BANCO_DE_DADOS
  done
else
  gera_log delete nulo
fi
  rm arquiva.dt -f
}


gera_log(){
  case $1 in # case 01
    drop) 
      case $2 in  # case 02
        tb_log_temp) echo -e "$PSQL \"DROP TABLE IF EXISTS core.tb_log_temp\" $NOME_DO_BANCO_DE_DADOS"
                     echo -e " \"DROP TABLE IF EXISTS core.tb_log_temp\" $NOME_DO_BANCO_DE_DADOS " >> $LOG
                  ;; #tb_log_temp
        tb_log_detalhe_temp)  echo -e "$PSQL  \"DROP TABLE IF EXISTS core.tb_log_detalhe_temp\" $NOME_DO_BANCO_DE_DADOS"
                              echo -e " \"DROP TABLE IF EXISTS core.tb_log_detalhe_temp\" $NOME_DO_BANCO_DE_DADOS" >> $LOG
                  ;; #tb_log_detalhe_temp
      esac # esac 02
        ;; # drop
    create)
      case $2 in # case 03
        tb_log_temp)  echo -e "$PSQL  \"CREATE TABLE core.tb_log_temp AS (SELECT * FROM core.tb_log WHERE dt_log BETWEEN '$ANO-$MES-01' AND (DATE '$ANO-$MES-01' + INTERVAL '1 month'))\" $NOME_DO_BANCO_DE_DADOS"
                      echo -e " \"CREATE TABLE core.tb_log_temp AS (SELECT * FROM core.tb_log WHERE dt_log BETWEEN '$ANO-$MES-01' AND (DATE '$ANO-$MES-01' + INTERVAL '1 month'))\" $NOME_DO_BANCO_DE_DADOS" >> $LOG
                  ;;
        tb_log_detalhe_temp)  echo -e "$PSQL  \"CREATE TABLE core.tb_log_detalhe_temp AS (SELECT * FROM core.tb_log_detalhe tld WHERE tld.id_log IN(SELECT id_log FROM core.tb_log_temp ORDER BY 1) )\" $NOME_DO_BANCO_DE_DADOS"
                              echo -e " \"CREATE TABLE core.tb_log_detalhe_temp AS (SELECT * FROM core.tb_log_detalhe tld WHERE tld.id_log IN(SELECT id_log FROM core.tb_log_temp ORDER BY 1) )\" $NOME_DO_BANCO_DE_DADOS" >> $LOG
                  ;;
      esac # esac 03
         ;; # create
    dump)
      case $2 in # case 04
        tb_log_temp)  echo -e "$DUMP core.tb_log_temp   $NOME_DO_BANCO_DE_DADOS |sed 's/tb_log_temp/tb_log/g' > core.tb_log_temp"
                      echo -e "$DUMP core.tb_log_temp   $NOME_DO_BANCO_DE_DADOS |sed 's/tb_log_temp/tb_log/g' > core.tb_log_temp" >> $LOG
                 ;;
        tb_log_detalhe_temp)   echo -e "$DUMP core.tb_log_detalhe_temp   $NOME_DO_BANCO_DE_DADOS |sed 's/tb_log_detalhe_temp/tb_log_detalhe/g' > core.tb_log_detalhe"
                               echo -e "$DUMP core.tb_log_detalhe_temp   $NOME_DO_BANCO_DE_DADOS |sed 's/tb_log_detalhe_temp/tb_log_detalhe/g' > core.tb_log_detalhe" >> $LOG
                ;;
      esac # esac 04
       ;;
    consolida)
              if (( $MES <10 )); then 
                echo -e "cat core.tb_log_temp core.tb_log_detalhe_temp | pbzip2 -c > $NOME_DO_BANCO_DE_DADOS.core.tb_logs-$ANO-0$MES.sql.bz2" 
                echo -e " " 
                echo -e "cat core.tb_log_temp core.tb_log_detalhe_temp | pbzip2 -c > $NOME_DO_BANCO_DE_DADOS.core.tb_logs-$ANO-0$MES.sql.bz2" >> $LOG
              else
                echo -e "cat core.tb_log_temp core.tb_log_detalhe_temp | pbzip2 -c > $NOME_DO_BANCO_DE_DADOS.core.tb_logs-$ANO-$MES.sql.bz2"
                 echo -e " "
                 echo -e "cat core.tb_log_temp core.tb_log_detalhe_temp | pbzip2 -c > $NOME_DO_BANCO_DE_DADOS.core.tb_logs-$ANO-$MES.sql.bz2" >> $LOG
              fi
            ;;
      delete)
            case $2 in # case 05
               tb_log)
                     if [[ $3 == 0 ]]; then
                       echo -e "\"TRUNCATE FROM core.tb_log\"" $NOME_DO_BANCO_DE_DADOS 
                       echo -e "\"TRUNCATE FROM core.tb_log\"" $NOME_DO_BANCO_DE_DADOS >> $LOG
                     else
                       echo -e  "\"DELETE FROM core.tb_log WHERE  dt_log BETWEEN '$ANO-$MES-01' AND (DATE '$ANO-$MES-01' + INTERVAL '1 month')\"" $NOME_DO_BANCO_DE_DADOS
                       echo -e  "\"DELETE FROM core.tb_log WHERE  dt_log BETWEEN '$ANO-$MES-01' AND (DATE '$ANO-$MES-01' + INTERVAL '1 month')\"" $NOME_DO_BANCO_DE_DADOS >> $LOG
                     fi
                     ;;
               tb_log_detalhe)
                     if [[ $3 == 0 ]]; then
                       echo -e  "\"DELETE FROM core.tb_log_detalhe\"" $NOME_DO_BANCO_DE_DADOS
                       echo -e  "\"DELETE FROM core.tb_log_detalhe\"" $NOME_DO_BANCO_DE_DADOS >> $LOG
                     else
                       echo -e "\"DELETE FROM core.tb_log_detalhe WHERE id_log IN (SELECT id_log FROM core.tb_log WHERE dt_log  BETWEEN '$ANO-$MES-01' AND (DATE '$ANO-$MES-01' + INTERVAL '1 month'))\"" $NOME_DO_BANCO_DE_DADOS
                       echo -e "\"DELETE FROM core.tb_log_detalhe WHERE id_log IN (SELECT id_log FROM core.tb_log WHERE dt_log  BETWEEN '$ANO-$MES-01' AND (DATE '$ANO-$MES-01' + INTERVAL '1 month'))\"" $NOME_DO_BANCO_DE_DADOS >> $LOG
                     fi
                            ;;
                nulo)
                      echo -e "A opção \"99\" foi atribuída à variável \"HISTORICO\". Os logs não serão apagados do banco."
                      echo -e "A opção \"99\" foi atribuída à variável \"HISTORICO\". Os logs não serão apagados do banco." >> $LOG
                    ;;
            esac # esac 05
            ;;
         *) echo -e " " >> $LOG
         ;;
  esac # esac 01
}



cria_arquivo(){
  # ... gera log para a tela e para arquivo de log ...
  gera_log drop tb_log_temp
  # ... deleta tabela temporaria, caso exista ...
  $PSQL  "DROP TABLE IF EXISTS core.tb_log_temp" $NOME_DO_BANCO_DE_DADOS >> $LOG
  # ... sem parametros, a procedure apenas loga uma linha em branco, para fins de layout...
  gera_log

  # ... gera log para a tela e para arquivo de log ...
  gera_log drop tb_log_detalhe_temp
  # ... deleta tabela temporaria, caso exista ...
  $PSQL  "DROP TABLE IF EXISTS core.tb_log_detalhe_temp" $NOME_DO_BANCO_DE_DADOS >> $LOG
  # ... sem parametros, a procedure apenas loga uma linha em branco, para fins de layout...
  gera_log

  # ... cria uma tabela temporaria contendo os logs de apenas um mes...
  gera_log create tb_log_temp
  $PSQL   "CREATE TABLE core.tb_log_temp AS (SELECT * FROM core.tb_log WHERE dt_log BETWEEN '$ANO-$MES-01' AND (DATE '$ANO-$MES-01' + INTERVAL '1 month'))" $NOME_DO_BANCO_DE_DADOS >> $LOG
  gera_log

  # ... cria uma tabela temporaria contendo os logs de apenas um mes ...
  gera_log create tb_log_detalhe_temp
  $PSQL  "CREATE TABLE core.tb_log_detalhe_temp AS (SELECT * FROM core.tb_log_detalhe tld WHERE tld.id_log IN(SELECT id_log FROM core.tb_log_temp ORDER BY 1) )" $NOME_DO_BANCO_DE_DADOS >> $LOG
  gera_log

 #  ... faz o dump das tabelas core.tb_log_temp e core.tb_log_detalhe_temp, tirando o sufixo "_temp" donome da tabela...
  gera_log dump tb_log_temp
  $DUMP  core.tb_log_temp   $NOME_DO_BANCO_DE_DADOS |sed 's/tb_log_temp/tb_log/g'  > core.tb_log_temp 
  gera_log

  gera_log dump tb_log_detalhe_temp
  $DUMP  core.tb_log_detalhe_temp   $NOME_DO_BANCO_DE_DADOS |sed 's/tb_log_detalhe_temp/tb_log_detalhe/g' > core.tb_log_detalhe_temp 
  gera_log

 # ... criando um arquivo bzipado com os as duas tabelas.
  gera_log consolida
  if (( $MES <10 )) ; then
    cat core.tb_log_temp core.tb_log_detalhe_temp | pbzip2 -c > $DIRETORIO$NOME_DO_BANCO_DE_DADOS.core.tb_logs-$ANO-0$MES.sql.bz2
  else
    cat core.tb_log_temp core.tb_log_detalhe_temp | pbzip2 -c > $DIRETORIO$NOME_DO_BANCO_DE_DADOS.core.tb_logs-$ANO-$MES.sql.bz2
  fi
  gera_log
}
arquivo(){

# para cada linha do arquivo arquiva.dt...
for (( i=1,j=1; i<$tamanho;i++,j++));do
  # ... identifique o mes e ano, e coloque na variavel MES e ANO...
  ANO=$( sed -n "$i,$i p" arquiva.dt |cut -d '|' -f 2 )
  MES=$( sed -n "$j,$j p" arquiva.dt |cut -d '|' -f 3 )
  date +%F\ %Hh%Mm%Ss >> $LOG

  # Pesquisa se o arquivo a ser criado já existe. Se existe, não re-arquiva.
  # Essa situação pode ocorrer caso já se tenha arquivado os logs,
  # e depois tenha voltado um mês anterior já arquivado para realizar
  # auditoria.
  # Se não existe, cria_arquivo
  if (( $MES <10 )) ; then
    if [ -f $DIRETORIO$NOME_DO_BANCO_DE_DADOS.core.tb_logs-$ANO-0$MES.sql.bz2 ]; then
       echo -e "As tabelas tb_log e tb_log_detalhe de 0$MES-$ANO, já foram arquivadas. Este mês/ano será ignorado."
       echo -e "As tabelas tb_log e tb_log_detalhe de 0$MES-$ANO, já foram arquivadas. Este mês/ano será ignorado." >> $LOG
    else
       cria_arquivo
    fi 
  else
    if [ -f $DIRETORIO$NOME_DO_BANCO_DE_DADOS.core.tb_logs-$ANO-$MES.sql.bz2 ]; then
       echo -e "As tabelas tb_log e tb_log_detalhe de $MES-$ANO, já foram arquivadas. Este mês/ano será ignorado." 
       echo -e "As tabelas tb_log e tb_log_detalhe de $MES-$ANO, já foram arquivadas. Este mês/ano será ignorado." >> $LOG
    else
       cria_arquivo
    fi 
  fi
done
}

pesquisa_ano_mes(){
# Se o arquivo "arquiva.dt" existe, apague...
rm arquiva.dt -f
# ... e verifique o valor da variavel historico (significado dos valores no inicio deste documento)
if [[ $HISTORICO == 0 ]] || [[ $HISTORICO == 99 ]] || [[ $HISTORICO <=48 ]]; then
  $PSQL "SELECT DISTINCT '|'||date_part('year',dt_log)||'|'||date_part('month',dt_log) as data FROM tb_log WHERE dt_log < date_trunc('month',current_date) ORDER BY data" $NOME_DO_BANCO_DE_DADOS | sed '/^$/d' >  arquiva.dt
else
 echo -e " O valor da variavel \$HISTORICO = $HISTORICO, deve ser 0 (zero), 99 (noventa e nove) ou entre 1 (um) e 48 (quarenta e oito"
fi
}


#########################
#### inicio dso script ##
########################
for ((bs=0;bs<${#BANCO_E_SERVIDOR[@]};bs++)); do
   NOME_DO_BANCO_DE_DADOS=$(echo ${BANCO_E_SERVIDOR[$bs]} | cut -d '@' -f1)
   IP_DO_SERVIDOR_DE_BANCO_DE_DADOS=$(echo ${BANCO_E_SERVIDOR[$bs]} | cut -d '@' -f2)
   PSQL="$PSQL_BIN -U $NOME_DO_USUARIO_DO_BANCO_DE_DADOS -h $IP_DO_SERVIDOR_DE_BANCO_DE_DADOS -t -c "
   DUMP="$DUMP_BIN -U $NOME_DO_USUARIO_DO_BANCO_DE_DADOS -h $IP_DO_SERVIDOR_DE_BANCO_DE_DADOS -a -O -x -t "
   echo -e "$NOME_DO_BANCO_DE_DADOS  $IP_DO_SERVIDOR_DE_BANCO_DE_DADOS"
   # verifica quanto tempo há de log armazenado, e coloca em um arquivo no formato: ano - mes
   pesquisa_ano_mes $HISTORICO
   # verifica quantas linhas foram criadas no arquivo
   tamanho=$(wc -l arquiva.dt |cut -d' ' -f1)
   (( tamanho++ ))
   # cria arquivo zipado, um por mês, contendo as tabelas tb_log e tb_log_detalhe do periodo
   arquivo
   # apaga arquivos temporarios
   rm arquiva.dt core.tb_log_temp core.tb_log_detalhe_temp -f
   # deleta o conteudo das tabelas
   apaga_tabelas_log
   # realiza um vacuum full das tabelas de log
   $PSQL "VACUUM FULL core.tb_log" $NOME_DO_BANCO_DE_DADOS
   $PSQL "VACUUM FULL core.tb_log_detalhe" $NOME_DO_BANCO_DE_DADOS
done
# saio do programa
exit 0
