#!/bin/bash

# Deve-se adicionar a linha abaixo ao crontab, para que execute no primeiro domingo de cada mes, a uma da manha:
# 00 01 1-7 1-12 * if [ "$(date +%a) = "Sun" ]; then /caminho_completo_do_script/boletim_estatistico.sh; fi

# -- arquivo de  configuracao
. boletim.conf

# -- se o arquivo de erro existe, renomeia e cria outro
if [ -f $ERRMSG ]; then
   mv $ERRMSG $LOGDIR/$NEWLOG
fi

# -- pega o ID do administrador da aplicacao
IDUSUARIO=($($PSQL -U $PGUSER -p $PGPORT -d $PGDATABASE -t -c "SELECT DISTINCT id_usuario FROM core.tb_usuario_localizacao  WHERE id_papel IN (SELECT id_papel FROM acl.tb_papel WHERE ds_identificador ILIKE 'administrador') LIMIT 1"))
# -- busta todos os ID's dos orgaos julgadores
ORGAOS_JULGADORES=($($PSQL -U $PGUSER -p $PGPORT -d $PGDATABASE -t -c "SELECT id_orgao_julgador FROM client.tb_orgao_julgador where in_ativo = 'S'  ORDER BY 1"))
# -- verifica a quantidade de processadores no sistema...
PROCESSADORES=($(grep processor /proc/cpuinfo|wc -l))
# ... pois ira utilizar todos menos um para o calculo do boletim...
(( PROCESSADORES-- ))
# ...a menos que haja somente um processador, entao nao tem o que fazer...
if (($PROCESSADORES==0)); then PROCESSADORES=1; fi

###########################
###       FUNCOES       ###
###########################

gera_relatorio(){
  $PSQL -U $PGUSER -p $PGPORT -d $PGDATABASE -q -t -c "SELECT jt.boletim_calcular_boletim_estatistico($1,$2,$3,$4);" > /dev/null 2>&1 &
}

monitora(){
  # monitora quantos processos estao em background
  BACKGROUND=($(ps a |grep -v grep |grep psql.bin|grep $PGDATABASE|grep boletim_calcular_boletim_estatistico|wc -l))
}

relatorio(){
  # para cada orgao julgador...
  for ((i=0;i<${#ORGAOS_JULGADORES[@]};i++)); do
    # ...gera um relatorio do mes e ano especificados...
    gera_relatorio $MES $ANO ${ORGAOS_JULGADORES[$i]} $IDUSUARIO
	# ...e preenche a variavel background atraves da funcao monitora...
    monitora
	# ...assim, se o numero de funcoes em background for igual ao numero de processadores...
     if (( $BACKGROUND==$PROCESSADORES )); then 
	   # ...entao monitora ateh que sobre processadores...
       while [ $BACKGROUND -eq $PROCESSADORES ] ; do
          read -t 5
          monitora 
       done;
    fi
	# ... para reiniciar o ciclo.
	# Quando terminar todos os ciclos com os orgaos julgadores...
  done
  # ...fica monitorando ateh que nao haja mais nenhum boletim sendo processado.
  while [ $BACKGROUND -ne 0 ]; do
    read -t 1
    monitora
  done;
}

relatorio_execusao(){
  # Obtem a quantidade de orgaos julgadores cujo boletim nao foi gerado
  erros=($($PSQL -U $PGUSER -p $PGPORT -d $PGDATABASE -t -c "SELECT COUNT(id_orgao_julgador) FROM tb_orgao_julgador WHERE id_orgao_julgador NOT IN ( SELECT DISTINCT id_orgao_julgador FROM jt.tb_relatorio_boletim WHERE nr_ano=$ANO AND nr_mes=$MES ORDER BY 1) ORDER BY 1;"))
}

erros_execusao(){
  # Gera pequeno relatorio com os orgaos julgadores cujo boletim nao foi gerado e coloca no log
  $PSQL -U $PGUSER -p $PGPORT -d $PGDATABASE -t -c "SELECT id_orgao_julgador,ds_orgao_julgador,'NAO GERADO' AS situacao FROM tb_orgao_julgador WHERE id_orgao_julgador NOT IN ( SELECT DISTINCT id_orgao_julgador FROM jt.tb_relatorio_boletim WHERE nr_ano=$ANO AND nr_mes=$MES ORDER BY 1) ;" >> $ERRMSG
}

refaz_lista_nao_executados(){
  # Cria uma lista com os orgaos julgadores cujo boletim nao foi gerado
  ORGAOS_JULGADORES=($($PSQL -U $PGUSER -p $PGPORT -d $PGDATABASE -t -c "SELECT id_orgao_julgador,ds_orgao_julgador,'NAO GERADO' AS situacao FROM tb_orgao_julgador WHERE id_orgao_julgador NOT IN ( SELECT DISTINCT id_orgao_julgador FROM jt.tb_relatorio_boletim WHERE nr_ano=$ANO AND nr_mes=$MES ORDER BY 1) ORDER BY 1;" |cut -f1 -d'|'))
}

###########################
###  PROGRAMA PRINCIPAL ###
###########################
# -- Funcao  onde o relatorio eh gerado
relatorio

# -- Gera log com todos que nao foram gerados...
relatorio_execusao

# ...e caso haja ao menos um que nao tenha sido executado...
if (($erros>0)); then
  # ...gera relatorio com os erros...
  echo -e "$(date) - ERROS ENCONTRADOS APOS EXECUTAR PELA PRIMEIRA VEZ" >> $ERRMSG
  erros_execusao
  # ...refaz a lista somente com os orgaos julgadores que faltaram e...
  refaz_lista_nao_executados
  # ...executa a funcao uma vez mais...
  relatorio

  # ...adicionando o relatorio ao arquivo existente, caso ainda haja erros...
  relatorio_execusao
  if (($erros>0)); then
     echo -e "$(date) - ERROS ENCONTRADOS APOS EXECUTAR PELA SEGUNDA VEZ, E QUE NAO PUDERAM SER CONTORNADOS" >> $ERRMSG
     erros_execusao
	 # ...e envia e-mail aos responsaveis.
     mail -s "[Boletim Estatistico] RELATORIO COM OS ERROS" "$SENDTO" < $ERRMSG
  fi
fi