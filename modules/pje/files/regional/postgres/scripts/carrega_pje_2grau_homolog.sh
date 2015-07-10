dbDestino=pje_2grau_homolog
dbDestino_bin=pje_2grau_homolog_bin
hostOrigem=pje17-db-a
userOrigem=pje
portOrigem=5432
dbOrigem=pje_2grau
dbOrigem_bin=pje_2grau_bin
hostDestino=pje17-db-homolog
superUserDestino=postgres
portDestino=5432
ownerDestino=pje
tbspcDestino=pje2tsd01
tbspcDestino_bin=pjebin2tsd01
senhaBanco=8103459dc6a3e251f5d44542f1fd96a3
log=/u00/app/postgres/pgprd01/tmp/carga.log
tipo=homolog

/u00/app/postgres/pgprd01/scripts/copia_banco.sh $hostOrigem $userOrigem $portOrigem $dbOrigem $hostDestino $superUserDestino $portDestino $dbDestino $ownerDestino $tbspcDestino
echo -e "\n Permitindo login sem certificado"
psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -w -d $dbDestino -c "update core.tb_parametro set vl_variavel='false' where nm_variavel ='loginComCertificado'" >> $log
echo -e "\n Ajustando tb_remessa_processo_host de 1 e 2grau"
psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -w -d $dbDestino -c "update client.tb_remessa_processo_host set ds_url = '$hostDestino:$portDestino/pje_2grau_$tipo', ds_url_homologacao = '$hostDestino:$portDestino/pje_2grau_$tipo', ds_login = '$ownerDestino', ds_senha = '$senhaBanco' where id_sessao_destino=0" >> $log
psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -w -d $dbDestino -c "update client.tb_remessa_processo_host set ds_url = '$hostDestino:$portDestino/pje_1grau_$tipo', ds_url_homologacao = '$hostDestino:$portDestino/pje_1grau_$tipo', ds_login = '$ownerDestino', ds_senha = '$senhaBanco' where id_sessao_destino=4" >> $log
echo -e "\n Ajustando core.tb_parametro enderecoWSDLPublicaDEJT e enderecoWSDLConsultaDEJT"
psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -w -d $dbDestino -c "UPDATE core.tb_parametro SET vl_variavel='http://homologacao.jt.jus.br:80/dejt/PublicaMateriaService?wsdl', dt_atualizacao=now() WHERE id_parametro=(SELECT id_parametro FROM core.tb_parametro WHERE nm_variavel='enderecoWSDLPublicaDEJT')" >> $log
psql -h "$hostDestino" -p "$portDestino" -U "$superUserDestino" -w -d $dbDestino -c "UPDATE core.tb_parametro SET vl_variavel='http://homologacao.jt.jus.br/dejt/dejt?wsdl', dt_atualizacao=now() WHERE id_parametro=(SELECT id_parametro FROM core.tb_parametro WHERE nm_variavel='enderecoWSDLConsultaDEJT')" >> $log
/u00/app/postgres/pgprd01/scripts/copia_banco.sh $hostOrigem $userOrigem $portOrigem $dbOrigem_bin $hostDestino $superUserDestino $portDestino $dbDestino_bin $ownerDestino $tbspcDestino_bin
