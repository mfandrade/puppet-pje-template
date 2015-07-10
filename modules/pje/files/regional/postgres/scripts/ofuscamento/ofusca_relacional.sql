--script que faz ofuscamento de bases de dados relacionais.

SET client_encoding = 'LATIN1';

SET search_path = public,client,core,jt,acl,pje_backup,pje_gim,pje_mnt,pg_catalog;

BEGIN; -- Ofuscar documentos (binários)

-- Desabilitar triggers
ALTER TABLE tb_processo_documento_bin DISABLE TRIGGER ALL;

update tb_processo_documento_bin
set ds_modelo_documento = '<html>
<body>
<b>CONTEÚDO DO DOCUMENTO APAGADO PELO ADMINISTRADOR PARA SEGURANÇA DAS INFORMAÇÕES</b>
</body>
</html>',
ob_processo_documento = null;

-- Reabilitar triggers
ALTER TABLE tb_processo_documento_bin ENABLE TRIGGER ALL;

update tb_documento_pessoa
set ds_documento_html = '<html>
<body>
<b>CONTEÚDO DO DOCUMENTO APAGADO PELO ADMINISTRADOR PARA SEGURANÇA DAS INFORMAÇÕES</b>
</body>
</html>',
ds_documento_bin = null;

COMMIT; -- Ofuscar documentos (binários)

BEGIN; -- Ofuscar alguns dados e alterar parâmetros

-- Ofusca nomes dos genitores e telefones
update tb_pessoa_fisica
set nm_genitora = null,
nm_genitor = null,
nr_celular = null,
nr_tel_residencial = null,
nr_tel_comercial = null;

-- Ofusca nome e cpf do responsável de uma PJ
update tb_pessoa_juridica
set nr_cpf_responsavel = null,
nm_responsavel = null;

update tb_meio_contato
set vl_meio_contato = clock_timestamp(),
ds_complemento_contato = null,
ds_observacao = null;

-- Ofusca emails
update tb_dado_oab_pess_advogado set ds_email = 'testes@catete.errejota';
update tb_orgao_julgador set ds_email = 'testes@gloria.errejota';
update tb_orgao_julgador_colgiado set ds_email = 'testes@lapa.errejota';
update tb_procuradoria set ds_email = 'testes@botafogo.errejota';
update tb_usuario_login set ds_email = 'testes@flamengo.errejota';

-- Altera parâmetros da aplicação
update client.tb_remessa_processo_host
set ds_url = 'tijuca.errejota',
ds_url_homologacao = 'copacabana.errejota',
ds_senha='senhador';

update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'urlWsdlConsultaOab';

update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'dslinkprevencao';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'urlWsdlReceitaCnpj';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'hashDocumentoUrl';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'urlWsdlReceita';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'enderecoWSDLPublicaDiario';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'enderecoWSDLConsultaDiario';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'urlWsdlAplicacaoOrigemConsulta';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'usuarioWebserviceBNDT';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'urlWsdlAplicacaoOrigemConsulta';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'urlWsdlEnvioInstanciaSuperior';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'urlWsdlAplicacaoOrigem';
update tb_parametro
   set vl_variavel = 'Variavel_ofuscada'
 where nm_variavel = 'urlWsdlPJeInstanciaSuperior';

update tb_parametro
   set vl_variavel = 'Tribunal do Trabalho da Região'
 where nm_variavel = 'nomeSecaoJudiciaria';

update tb_parametro
	set vl_variavel = '{''tls'': ''false'', ''debug'': ''false'', ''host'':'''', ''password'': '''', ''port'': ''666'', ''username'': ''''}'
where nm_variavel = 'parametros_smtp';

COMMIT; -- Ofuscar alguns dados e alterar parâmetros

-- Altera o owner para postgres (necessário para o alter table)
ALTER TABLE pje_backup.tb_proc_parte_exped_visita_old OWNER TO postgres;
ALTER TABLE pje_backup.tb_visita_old OWNER TO postgres;
ALTER TABLE pje_backup.tb_diligencia_old OWNER TO postgres;
ALTER TABLE pje_backup.tb_proc_exped_cntral_mnddo_old OWNER TO postgres;
GRANT ALL ON SCHEMA pje_backup TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA pje_backup TO postgres;

BEGIN; -- Remover processos, e dados relacionados, que tramitam em segredo de justiça (tb_processo_trf.in_segredo_justica='S')

-- Remove constraints
alter table tb_posse_expediente drop constraint tb_posse_expediente_id_expediente_central_fkey;
alter table tb_expediente_central drop constraint tb_expediente_central_id_posse_expediente_atual_fkey;
alter table tb_expediente_central drop constraint tb_expediente_central_id_situacao_expediente_atual_fkey;
alter table tb_diligencia drop constraint tb_diligencia_id_posse_expediente_fkey;
alter table tb_situacao_bem drop constraint tb_situacao_bem_id_bem_penhorado_fkey;
alter table tb_bem_penhorado drop constraint tb_bem_penhorado_id_situacao_bem_penhora_atual_fkey;
alter table tb_bem_penhorado drop constraint tb_bem_penhorado_id_localizacao_bem_atual_fkey;
alter table tb_bem_penhorado drop constraint tb_bem_penhorado_id_avaliacao_bem_atual_fkey;

-- Altera constraints para ON DELETE CASCADE (para evitar usar selects aninhados na remoção de itens que violam FKs)
ALTER TABLE pje_backup.tb_proc_parte_exped_visita_old
	DROP CONSTRAINT tb_processo_parte_expediente_visita_id_visita_fkey,
	ADD CONSTRAINT tb_processo_parte_expediente_visita_id_visita_fkey FOREIGN KEY (id_visita)
      REFERENCES pje_backup.tb_visita_old (id_visita) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE pje_backup.tb_visita_old
	DROP CONSTRAINT tb_visita_id_diligencia_fkey,
	ADD CONSTRAINT tb_visita_id_diligencia_fkey FOREIGN KEY (id_diligencia)
      REFERENCES pje_backup.tb_diligencia_old (id_diligencia) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE pje_backup.tb_diligencia_old
	DROP CONSTRAINT tb_diligencia_id_processo_expediente_central_mandado_fkey,
	ADD CONSTRAINT tb_diligencia_id_processo_expediente_central_mandado_fkey FOREIGN KEY (id_proc_exped_central_mandado)
      REFERENCES pje_backup.tb_proc_exped_cntral_mnddo_old (id_proc_expedi_central_mandado) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE pje_backup.tb_proc_exped_cntral_mnddo_old
	DROP CONSTRAINT tb_processo_expediente_centra_id_processo_expediente_centr_fkey,
	ADD CONSTRAINT tb_processo_expediente_centra_id_processo_expediente_centr_fkey FOREIGN KEY (id_proc_expd_cntrl_mndo_antror)
      REFERENCES pje_backup.tb_proc_exped_cntral_mnddo_old (id_proc_expedi_central_mandado) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_parte_endereco
	DROP CONSTRAINT tb_processo_parte_endereco_processo_parte_fkey,
	ADD CONSTRAINT tb_processo_parte_endereco_processo_parte_fkey FOREIGN KEY (id_processo_parte)
      REFERENCES client.tb_processo_parte (id_processo_parte) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_result_sentenca_parte
	DROP CONSTRAINT fkc44fb07322f47581,
	ADD CONSTRAINT fkc44fb07322f47581 FOREIGN KEY (id_processo_parte)
      REFERENCES client.tb_processo_parte (id_processo_parte) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_proc_parte_represntante
	DROP CONSTRAINT tb_processo_parte_representante_id_processo_parte_fkey,
	ADD CONSTRAINT tb_processo_parte_representante_id_processo_parte_fkey FOREIGN KEY (id_processo_parte)
      REFERENCES client.tb_processo_parte (id_processo_parte) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE jt.tb_evento_assincrono
	DROP CONSTRAINT tb_evento_assincrono_fk01,
	ADD CONSTRAINT tb_evento_assincrono_fk01 FOREIGN KEY (nr_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_resultado_sentenca
	DROP CONSTRAINT fk225daaa06b20166d,
	ADD CONSTRAINT fk225daaa06b20166d FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_proc_parte_expediente
	DROP CONSTRAINT fk_processo_parte_expediente,
	ADD CONSTRAINT fk_processo_parte_expediente FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH FULL
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_alerta
	DROP CONSTRAINT fk_tb_processo_alerta_1,
	ADD CONSTRAINT fk_tb_processo_alerta_1 FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_trf_log
	DROP CONSTRAINT fk_tb_processo_trf_log,
	ADD CONSTRAINT fk_tb_processo_trf_log FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_assunto
  DROP CONSTRAINT tb_processo_assunto_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_assunto_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_audiencia
  DROP CONSTRAINT tb_processo_audiencia_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_audiencia_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_expediente
  DROP CONSTRAINT tb_processo_expediente_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_expediente_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_trf_impresso
  DROP CONSTRAINT tb_processo_trf_impresso_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_trf_impresso_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_proc_parte_expediente
  DROP CONSTRAINT fk_processo_parte_expediente,
  ADD CONSTRAINT fk_processo_parte_expediente FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH FULL
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_habilitacao_autos
  DROP CONSTRAINT fk_habilitacao_processo_trf,
  ADD CONSTRAINT fk_habilitacao_processo_trf FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE jt.tb_processo_jt
  DROP CONSTRAINT fk_tb_processo_jt_tb_proc_trf,
  ADD CONSTRAINT fk_tb_processo_jt_tb_proc_trf FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_proc_parte_expediente
  DROP CONSTRAINT tb_processo_parte_expediente_id_processo_expediente_fkey,
  ADD CONSTRAINT tb_processo_parte_expediente_id_processo_expediente_fkey FOREIGN KEY (id_processo_expediente)
      REFERENCES client.tb_processo_expediente (id_processo_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_expediente
  DROP CONSTRAINT tb_processo_expediente_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_expediente_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_pericia
  DROP CONSTRAINT tb_processo_pericia_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_pericia_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_hist_desloca_oj
  DROP CONSTRAINT tb_hist_desloca_oj_id_processo_trf_fkey,
  ADD CONSTRAINT tb_hist_desloca_oj_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_trf
  DROP CONSTRAINT tb_processo_trf_id_proc_referencia_fkey,
  ADD CONSTRAINT tb_processo_trf_id_proc_referencia_fkey FOREIGN KEY (id_proc_referencia)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_items_log
  DROP CONSTRAINT fk_items_log,
  ADD CONSTRAINT fk_items_log FOREIGN KEY (id_processo_trf_log)
      REFERENCES client.tb_processo_trf_log (id_processo_trf_log) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_trf_log_dist
  DROP CONSTRAINT fk_processo_trf_log_dist_2,
  ADD CONSTRAINT fk_processo_trf_log_dist_2 FOREIGN KEY (id_processo_trf_log)
      REFERENCES client.tb_processo_trf_log (id_processo_trf_log) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_processo_trf_log_prev
  DROP CONSTRAINT fk_processo_trf_log_prev,
  ADD CONSTRAINT fk_processo_trf_log_prev FOREIGN KEY (id_processo_trf_log)
      REFERENCES client.tb_processo_trf_log (id_processo_trf_log) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_proc_parte_represntante
  DROP CONSTRAINT tb_processo_parte_representante_id_parte_representante_fkey,
  ADD CONSTRAINT tb_processo_parte_representante_id_parte_representante_fkey FOREIGN KEY (id_parte_representante)
      REFERENCES client.tb_processo_parte (id_processo_parte) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE jt.tb_processo_audiencia_jt
  DROP CONSTRAINT fk_tb_proc_aud_jt_tb_proc_aud,
  ADD CONSTRAINT fk_tb_proc_aud_jt_tb_proc_aud FOREIGN KEY (id_processo_audiencia)
      REFERENCES client.tb_processo_audiencia (id_processo_audiencia) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE jt.tb_acordo
  DROP CONSTRAINT tb_processo_audiencia_fk,
  ADD CONSTRAINT tb_processo_audiencia_fk FOREIGN KEY (id_processo_audiencia)
      REFERENCES client.tb_processo_audiencia (id_processo_audiencia) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_proc_parte_exp_endereco
  DROP CONSTRAINT fk_proc_parte_exp,
  ADD CONSTRAINT fk_proc_parte_exp FOREIGN KEY (id_proc_parte_exp)
      REFERENCES client.tb_proc_parte_expediente (id_processo_parte_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE client.tb_proc_doc_expediente
  DROP CONSTRAINT tb_processo_documento_expediente_id_processo_expediente_fkey,
  ADD CONSTRAINT tb_processo_documento_expediente_id_processo_expediente_fkey FOREIGN KEY (id_processo_expediente)
      REFERENCES client.tb_processo_expediente (id_processo_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE jt.tb_jt_mtra_diario_eletronico
  DROP CONSTRAINT fk708c86d2f4af27d1,
  ADD CONSTRAINT fk708c86d2f4af27d1 FOREIGN KEY (id_processo_expediente)
      REFERENCES client.tb_processo_expediente (id_processo_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

delete from tb_processo_parte_sigilo where id_processo_parte in (select id_processo_parte from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_obrigacao_fazer where id_devedor in  (select id_processo_parte from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_obrigacao_atomica where id_devedor in (select id_participante_obrigacao  from tb_devedor where id_participante_obrigacao in (select id_participante_obrigacao from tb_participante_obrigacao where id_processo_parte in (select id_processo_parte from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')))));
delete from tb_devedor where id_participante_obrigacao in (select id_participante_obrigacao from tb_participante_obrigacao where id_processo_parte in (select id_processo_parte from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_credor where id_participante_obrigacao in (select id_participante_obrigacao from tb_participante_obrigacao where id_processo_parte in (select id_processo_parte from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_participante_obrigacao where id_processo_parte in (select id_processo_parte from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_habilitacao_representados where id_processo_parte in (select id_processo_parte from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_unificacao_pessoas_parte where id_parte in (select id_processo_parte from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_proc_parte_visib_sigilo where id_processo_parte in (select id_processo_parte from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_processo_segredo where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_proc_visibilida_segredo where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_proc_prioridde_processo where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_obrigacao_atomica where id_obrigacao_pagar in ( select id_obrigacao_pagar  from tb_obrigacao_pagar where id_processo_jt in ( select id_processo_jt from tb_processo_jt where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_rubrica where id_obrigacao_pagar in (select id_obrigacao_pagar from tb_obrigacao_pagar where id_processo_jt in ( select id_processo_jt from tb_processo_jt where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_obrigacao_pagar where id_processo_jt in ( select id_processo_jt from tb_processo_jt where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_proc_trf_log_prev_item where id_processo_trf_log_prev in (select id_processo_trf_log_prev from tb_processo_trf_log_prev where id_processo_trf_log in (select id_processo_trf_log from tb_processo_trf_log where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_pericia where id_processo_audiencia in (select id_processo_audiencia from tb_processo_audiencia where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_habilitacao_documentos where id_habilitacao_autos in (select id_habilitacao_autos from tb_habilitacao_autos where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_proc_doc_ptcao_nao_lida where id_habilitacao_autos in (select id_habilitacao_autos from tb_habilitacao_autos where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_proc_parte_exped_visita where id_processo_parte_expediente in (select id_processo_parte_expediente from tb_proc_parte_expediente where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_proc_parte_exped_visita_old where id_processo_parte_expediente in (select id_processo_parte_expediente from tb_proc_parte_expediente where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_proc_exped_doc_certidao where id_processo_parte_expediente in (select id_processo_parte_expediente from tb_proc_parte_expediente where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_solicitacao_no_desvio where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_hist_motivo_aces_terc where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_motivo_nao_distribuicao where id_expediente_central in ( select id_expediente_central from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_movimentacao_expediente where id_expediente_central in ( select id_expediente_central from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_motivo_nao_distribuicao where id_expediente_central in (select id_expediente_central from tb_expediente_central where id_posse_expediente_atual in (select id_expediente_central from tb_posse_expediente where id_expediente_central in ( select id_expediente_central from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))))));
delete from tb_posse_expediente where id_expediente_central in (select id_expediente_central from tb_expediente_central where id_situacao_expediente_atual in (select id_situacao_expediente from tb_situacao_expediente_central where id_expediente_central in (select id_expediente_central from tb_expediente_central where id_posse_expediente_atual in (select id_posse_expediente from tb_posse_expediente where id_expediente_central in ( select id_expediente_central from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))))))));
delete from tb_expediente_central where id_situacao_expediente_atual in (select id_situacao_expediente from tb_situacao_expediente_central where id_expediente_central in (select id_expediente_central from tb_expediente_central where id_posse_expediente_atual in (select id_posse_expediente from tb_posse_expediente where id_expediente_central in ( select id_expediente_central from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')))))));
delete from tb_situacao_expediente_central where id_expediente_central in (select id_expediente_central from tb_expediente_central where id_posse_expediente_atual in (select id_posse_expediente from tb_posse_expediente where id_expediente_central in ( select id_expediente_central from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))))));
delete from tb_expediente_central where id_posse_expediente_atual in (select id_posse_expediente from tb_posse_expediente where id_expediente_central in ( select id_expediente_central from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')))));
delete from tb_posse_expediente where id_expediente_central in ( select id_expediente_central from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_situacao_expediente_central where id_expediente_central in (select id_expediente_central from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_expediente_central where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in  (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_visita where id_diligencia in (select id_diligencia from tb_diligencia where id_posse_expediente in (select id_posse_expediente from tb_posse_expediente where id_expediente_central not in ( select id_expediente_central from tb_expediente_central)));
delete from tb_diligencia where id_posse_expediente in (select id_posse_expediente from tb_posse_expediente where id_expediente_central not in ( select id_expediente_central from tb_expediente_central));
delete from tb_posse_expediente where id_expediente_central not in ( select id_expediente_central from tb_expediente_central) ;
delete from tb_proc_exped_cntral_mnddo_old where id_processo_expediente in (select id_processo_expediente from tb_processo_expediente where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_hist_proc_doc_est_topico where id_proc_doc_estruturado_topico in (select id_proc_doc_estruturado_topico  from tb_proc_doc_est_topico where id_proc_doc_estruturado in ( select id_proc_doc_estruturado from tb_proc_doc_estruturado where id_processo_trf in ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_hist_anotacao where id_anotacao in (select id_anotacao from tb_anotacao where id_proc_doc_est_topico in (select id_proc_doc_estruturado_topico from tb_proc_doc_est_topico where id_proc_doc_estruturado in ( select id_proc_doc_estruturado from tb_proc_doc_estruturado where id_processo_trf in ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')))));
delete from tb_anotacao where id_proc_doc_est_topico in (select id_proc_doc_estruturado_topico from tb_proc_doc_est_topico where id_proc_doc_estruturado in ( select id_proc_doc_estruturado from tb_proc_doc_estruturado where id_processo_trf in ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_proc_doc_est_topico where id_proc_doc_estruturado in ( select id_proc_doc_estruturado from tb_proc_doc_estruturado where id_processo_trf in ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_proc_doc_estruturado where id_processo_trf in ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_processo_caixa_adv_proc where id_processo_trf in  ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_processo_trf_conexao where id_processo_trf in  ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_processo_trf_conexao where id_processo_trf_conexo in  ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_proc_trf_redistribuicao where id_processo_trf  in  ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_processo_parte where id_processo_trf in (select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S')));
delete from tb_processo_clet where id_processo_trf in ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_complem_classe_proc_trf where id_processo_trf in ( select id_processo_trf from tb_processo_trf where in_segredo_justica='S' union all select id_processo_trf from tb_processo_trf where id_proc_referencia in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_processo_parte where id_processo_trf in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S');
delete from tb_pergunta_bem_penhorado where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_avaliacao_bem_atual in ( select id_avaliacao_bem from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_propriedade_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_avaliacao_bem_atual in ( select id_avaliacao_bem from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_situacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_situacao_bem_penhora_atual in (select id_situacao_bem from tb_situacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_avaliacao_bem_atual in ( select id_avaliacao_bem from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S')))))));
delete from tb_bem_penhorado where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_situacao_bem_penhora_atual in (select id_situacao_bem from tb_situacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_avaliacao_bem_atual in ( select id_avaliacao_bem from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S'))))));
delete from tb_bem_penhorado where id_situacao_bem_penhora_atual in (select id_situacao_bem from tb_situacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_avaliacao_bem_atual in ( select id_avaliacao_bem from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S')))));
delete from tb_situacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_avaliacao_bem_atual in ( select id_avaliacao_bem from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_avaliacao_bem_atual in ( select id_avaliacao_bem from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S'))));
delete from tb_bem_penhorado where id_avaliacao_bem_atual in ( select id_avaliacao_bem from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S')));
delete from tb_avaliacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S'));
delete from tb_situacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S'));
delete from tb_localizacao_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S'));
delete from tb_pessoa_bem where id_bem_penhorado in (select id_bem_penhorado from tb_bem_penhorado where id_processo in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_bem_penhorado where id_processo in (select id_processo_trf  from tb_processo_trf where in_segredo_justica='S');
delete from tb_anexo_penhora where id_penhora in (select id_penhora from tb_penhora where id_processo in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_penhora where id_processo in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S');
delete from tb_rubrica_boleto where id_boleto in (select id_boleto from tb_boleto where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_boleto where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S');
delete from tb_hist_situacao_pauta where  id_pauta_sessao in (select id_pauta_sessao from tb_pauta_sessao where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_composicao_proc_sessao where id_pauta_sessao in (select id_pauta_sessao from tb_pauta_sessao where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_pauta_sessao where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S');
delete from tb_hist_relator where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S');
delete from tb_hist_tipo_voto where  id_voto in (select id_voto from tb_voto where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_documento_voto where id_voto in (select id_voto from tb_voto where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_voto where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S');
delete from tb_manifestacao_proc_doc where id_manifestacao_processual in (select id_manifestacao_processual from tb_manifestacao_processual where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S'));
delete from tb_manifestacao_processual where id_processo_trf in (select id_processo_trf from tb_processo_trf where in_segredo_justica='S');

-- Remover processos que tramitam em segredo de justiça
delete from tb_processo_trf where in_segredo_justica='S';

-- Limpeza
delete from tb_visita where id_diligencia in (select id_diligencia from tb_diligencia where id_posse_expediente not in (select id_posse_expediente from tb_posse_expediente));
delete from tb_diligencia where id_posse_expediente not in (select id_posse_expediente from tb_posse_expediente);

-- Restaura constraints originais
alter table tb_posse_expediente add 
 CONSTRAINT tb_posse_expediente_id_expediente_central_fkey FOREIGN KEY (id_expediente_central)
      REFERENCES jt.tb_expediente_central (id_expediente_central) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table tb_expediente_central add
 CONSTRAINT tb_expediente_central_id_posse_expediente_atual_fkey FOREIGN KEY (id_posse_expediente_atual)
      REFERENCES jt.tb_posse_expediente (id_posse_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table tb_diligencia add
 CONSTRAINT tb_diligencia_id_posse_expediente_fkey FOREIGN KEY (id_posse_expediente)
      REFERENCES jt.tb_posse_expediente (id_posse_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
	  
alter table tb_expediente_central add
CONSTRAINT tb_expediente_central_id_situacao_expediente_atual_fkey FOREIGN KEY (id_situacao_expediente_atual)
      REFERENCES jt.tb_situacao_expediente_central (id_situacao_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
	  
alter table tb_situacao_bem add 
CONSTRAINT tb_situacao_bem_id_bem_penhorado_fkey FOREIGN KEY (id_bem_penhorado)
REFERENCES jt.tb_bem_penhorado (id_bem_penhorado) MATCH SIMPLE
ON UPDATE NO ACTION ON DELETE NO ACTION;
	  
alter table tb_bem_penhorado add 
CONSTRAINT tb_bem_penhorado_id_situacao_bem_penhora_atual_fkey FOREIGN KEY (id_situacao_bem_penhora_atual)
REFERENCES jt.tb_situacao_bem (id_situacao_bem) MATCH SIMPLE
ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table tb_bem_penhorado add
CONSTRAINT tb_bem_penhorado_id_localizacao_bem_atual_fkey FOREIGN KEY (id_localizacao_bem_atual)
REFERENCES jt.tb_localizacao_bem (id_localizacao_bem) MATCH SIMPLE
ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table tb_bem_penhorado add
CONSTRAINT tb_bem_penhorado_id_avaliacao_bem_atual_fkey FOREIGN KEY (id_avaliacao_bem_atual)
      REFERENCES jt.tb_avaliacao_bem (id_avaliacao_bem) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE pje_backup.tb_proc_exped_cntral_mnddo_old
	DROP CONSTRAINT tb_processo_expediente_centra_id_processo_expediente_centr_fkey,
	ADD CONSTRAINT tb_processo_expediente_centra_id_processo_expediente_centr_fkey FOREIGN KEY (id_proc_expd_cntrl_mndo_antror)
      REFERENCES pje_backup.tb_proc_exped_cntral_mnddo_old (id_proc_expedi_central_mandado) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE pje_backup.tb_diligencia_old
	DROP CONSTRAINT tb_diligencia_id_processo_expediente_central_mandado_fkey,
	ADD CONSTRAINT tb_diligencia_id_processo_expediente_central_mandado_fkey FOREIGN KEY (id_proc_exped_central_mandado)
      REFERENCES pje_backup.tb_proc_exped_cntral_mnddo_old (id_proc_expedi_central_mandado) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE pje_backup.tb_visita_old
	DROP CONSTRAINT tb_visita_id_diligencia_fkey,
	ADD CONSTRAINT tb_visita_id_diligencia_fkey FOREIGN KEY (id_diligencia)
      REFERENCES pje_backup.tb_diligencia_old (id_diligencia) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE pje_backup.tb_proc_parte_exped_visita_old
	DROP CONSTRAINT tb_processo_parte_expediente_visita_id_visita_fkey,
	ADD CONSTRAINT tb_processo_parte_expediente_visita_id_visita_fkey FOREIGN KEY (id_visita)
      REFERENCES pje_backup.tb_visita_old (id_visita) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_parte_endereco
	DROP CONSTRAINT tb_processo_parte_endereco_processo_parte_fkey,
	ADD CONSTRAINT tb_processo_parte_endereco_processo_parte_fkey FOREIGN KEY (id_processo_parte)
      REFERENCES client.tb_processo_parte (id_processo_parte) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_result_sentenca_parte
	DROP CONSTRAINT fkc44fb07322f47581,
	ADD CONSTRAINT fkc44fb07322f47581 FOREIGN KEY (id_processo_parte)
      REFERENCES client.tb_processo_parte (id_processo_parte) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_proc_parte_represntante
	DROP CONSTRAINT tb_processo_parte_representante_id_processo_parte_fkey,
	ADD  CONSTRAINT tb_processo_parte_representante_id_processo_parte_fkey FOREIGN KEY (id_processo_parte)
      REFERENCES client.tb_processo_parte (id_processo_parte) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE jt.tb_evento_assincrono
	DROP CONSTRAINT tb_evento_assincrono_fk01,
	ADD CONSTRAINT tb_evento_assincrono_fk01 FOREIGN KEY (nr_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_resultado_sentenca
	DROP CONSTRAINT fk225daaa06b20166d,
	ADD CONSTRAINT fk225daaa06b20166d FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_proc_parte_expediente
	DROP CONSTRAINT fk_processo_parte_expediente,
	ADD CONSTRAINT fk_processo_parte_expediente FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_alerta
	DROP CONSTRAINT fk_tb_processo_alerta_1,
	ADD CONSTRAINT fk_tb_processo_alerta_1 FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_trf_log
	DROP CONSTRAINT fk_tb_processo_trf_log,
	ADD CONSTRAINT fk_tb_processo_trf_log FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_assunto
  DROP CONSTRAINT tb_processo_assunto_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_assunto_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_audiencia
  DROP CONSTRAINT tb_processo_audiencia_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_audiencia_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_expediente
  DROP CONSTRAINT tb_processo_expediente_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_expediente_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_trf_impresso
  DROP CONSTRAINT tb_processo_trf_impresso_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_trf_impresso_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_proc_parte_expediente
  DROP CONSTRAINT fk_processo_parte_expediente,
  ADD CONSTRAINT fk_processo_parte_expediente FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_habilitacao_autos
  DROP CONSTRAINT fk_habilitacao_processo_trf,
  ADD CONSTRAINT fk_habilitacao_processo_trf FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE jt.tb_processo_jt
  DROP CONSTRAINT fk_tb_processo_jt_tb_proc_trf,
  ADD CONSTRAINT fk_tb_processo_jt_tb_proc_trf FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_proc_parte_expediente
  DROP CONSTRAINT tb_processo_parte_expediente_id_processo_expediente_fkey,
  ADD CONSTRAINT tb_processo_parte_expediente_id_processo_expediente_fkey FOREIGN KEY (id_processo_expediente)
      REFERENCES client.tb_processo_expediente (id_processo_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_expediente
  DROP CONSTRAINT tb_processo_expediente_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_expediente_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_pericia
  DROP CONSTRAINT tb_processo_pericia_id_processo_trf_fkey,
  ADD CONSTRAINT tb_processo_pericia_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_hist_desloca_oj
  DROP CONSTRAINT tb_hist_desloca_oj_id_processo_trf_fkey,
  ADD CONSTRAINT tb_hist_desloca_oj_id_processo_trf_fkey FOREIGN KEY (id_processo_trf)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_trf
  DROP CONSTRAINT tb_processo_trf_id_proc_referencia_fkey,
  ADD CONSTRAINT tb_processo_trf_id_proc_referencia_fkey FOREIGN KEY (id_proc_referencia)
      REFERENCES client.tb_processo_trf (id_processo_trf) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_items_log
  DROP CONSTRAINT fk_items_log,
  ADD CONSTRAINT fk_items_log FOREIGN KEY (id_processo_trf_log)
      REFERENCES client.tb_processo_trf_log (id_processo_trf_log) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_trf_log_dist
  DROP CONSTRAINT fk_processo_trf_log_dist_2,
  ADD CONSTRAINT fk_processo_trf_log_dist_2 FOREIGN KEY (id_processo_trf_log)
      REFERENCES client.tb_processo_trf_log (id_processo_trf_log) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_processo_trf_log_prev
  DROP CONSTRAINT fk_processo_trf_log_prev,
  ADD CONSTRAINT fk_processo_trf_log_prev FOREIGN KEY (id_processo_trf_log)
      REFERENCES client.tb_processo_trf_log (id_processo_trf_log) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_proc_parte_represntante
  DROP CONSTRAINT tb_processo_parte_representante_id_parte_representante_fkey,
  ADD CONSTRAINT tb_processo_parte_representante_id_parte_representante_fkey FOREIGN KEY (id_parte_representante)
      REFERENCES client.tb_processo_parte (id_processo_parte) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE jt.tb_processo_audiencia_jt
  DROP CONSTRAINT fk_tb_proc_aud_jt_tb_proc_aud,
  ADD CONSTRAINT fk_tb_proc_aud_jt_tb_proc_aud FOREIGN KEY (id_processo_audiencia)
      REFERENCES client.tb_processo_audiencia (id_processo_audiencia) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE jt.tb_acordo
  DROP CONSTRAINT tb_processo_audiencia_fk,
  ADD CONSTRAINT tb_processo_audiencia_fk FOREIGN KEY (id_processo_audiencia)
      REFERENCES client.tb_processo_audiencia (id_processo_audiencia) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_proc_parte_exp_endereco
  DROP CONSTRAINT fk_proc_parte_exp,
  ADD CONSTRAINT fk_proc_parte_exp FOREIGN KEY (id_proc_parte_exp)
      REFERENCES client.tb_proc_parte_expediente (id_processo_parte_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE client.tb_proc_doc_expediente
  DROP CONSTRAINT tb_processo_documento_expediente_id_processo_expediente_fkey,
  ADD CONSTRAINT tb_processo_documento_expediente_id_processo_expediente_fkey FOREIGN KEY (id_processo_expediente)
      REFERENCES client.tb_processo_expediente (id_processo_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE jt.tb_jt_mtra_diario_eletronico
  DROP CONSTRAINT fk708c86d2f4af27d1,
  ADD CONSTRAINT fk708c86d2f4af27d1 FOREIGN KEY (id_processo_expediente)
      REFERENCES client.tb_processo_expediente (id_processo_expediente) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

COMMIT; -- Remover processos, e dados relacionados, que tramitam em segredo de justiça (tb_processo_trf.in_segredo_justica='S')

BEGIN; -- Ofuscar nomes

-- Criar tabela temporária com os nomes e emails utilizados no ofuscamento
CREATE TEMPORARY TABLE fakenames (
  id serial,
  gender varchar(6) NOT NULL,
  givenname varchar(20) NOT NULL,
  surname varchar(23) NOT NULL,
  emailaddress varchar(100) NOT NULL
);

-- Obrigatória a inclusão de uma entrada com id=0
insert into fakenames (id,gender,givenname,surname,emailaddress) values(0,'male','Kristian','Bürger','KristianBurger@superrito.com');

insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Kuefer','HeikeKuefer@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralph','Kunze','RalphKunze@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Osterhagen','MichelleOsterhagen@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sebastian','Hertz','SebastianHertz@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katharina','Kirsch','KatharinaKirsch@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mario','Biermann','MarioBiermann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Uta','Kohler','UtaKohler@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Loewe','JanLoewe@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Herman','InesHerman@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Propst','LenaPropst@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Walter','NicoleWalter@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Franziska','Strauss','FranziskaStrauss@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Köhler','EricKohler@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kristin','Drescher','KristinDrescher@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Angelika','Koertig','AngelikaKoertig@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Gabriele','Mahler','GabrieleMahler@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Vanessa','Abend','VanessaAbend@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Jaeger','DavidJaeger@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Manuela','Rothschild','ManuelaRothschild@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Dresner','KatrinDresner@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Amsel','JurgenAmsel@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Torsten','Klug','TorstenKlug@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Wirtz','LeahWirtz@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dominik','Meyer','DominikMeyer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Michael','Wurfel','MichaelWurfel@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Kuester','JurgenKuester@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Trommler','JonasTrommler@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Patrick','Duerr','PatrickDuerr@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Herzog','DieterHerzog@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Freitag','LeonieFreitag@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Markus','Baum','MarkusBaum@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Alexander','Wirtz','AlexanderWirtz@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Lemann','DennisLemann@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Erik','Glockner','ErikGlockner@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Zimmer','HeikeZimmer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophie','Schaefer','SophieSchaefer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Melanie','Schweizer','MelanieSchweizer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Phillipp','Bader','PhillippBader@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Hertz','LeahHertz@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Monika','Strauss','MonikaStrauss@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Werner','KathrinWerner@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Wurfel','DavidWurfel@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Farber','InesFarber@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabrina','Schiffer','SabrinaSchiffer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Wannemaker','FrankWannemaker@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Beyer','PaulBeyer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Gärtner','LukasGartner@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Robert','Kunze','RobertKunze@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Julia','Muench','JuliaMuench@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Erik','Hoover','ErikHoover@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sebastian','Neustadt','SebastianNeustadt@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Christian','Junker','ChristianJunker@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thorsten','Eisenhauer','ThorstenEisenhauer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Eichmann','LukasEichmann@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Wurfel','PaulWurfel@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kristian','Beckenbauer','KristianBeckenbauer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Klein','SarahKlein@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anja','Fassbinder','AnjaFassbinder@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Christian','Reinhardt','ChristianReinhardt@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Patrick','Grunewald','PatrickGrunewald@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Fink','SarahFink@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Pabst','JonasPabst@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Sankt','LeonieSankt@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lisa','Moench','LisaMoench@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mario','Ackermann','MarioAckermann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Ehrlichmann','LenaEhrlichmann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lucas','Freud','LucasFreud@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Frankfurter','LenaFrankfurter@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Freud','FlorianFreud@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mike','Schmidt','MikeSchmidt@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jessica','Abt','JessicaAbt@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Faber','MichelleFaber@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Bach','JanBach@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Simone','Freud','SimoneFreud@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Wirth','FlorianWirth@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kristin','Kastner','KristinKastner@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sven','Köhler','SvenKohler@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Walter','HeikeWalter@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katharina','Ackermann','KatharinaAckermann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kevin','Luft','KevinLuft@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Philipp','Weiß','PhilippWeiss@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Uwe','Schulze','UweSchulze@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Laura','Becker','LauraBecker@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Steffen','Lehmann','SteffenLehmann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Shuster','KatrinShuster@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Annett','Schweizer','AnnettSchweizer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Frey','FelixFrey@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ulrich','Holzman','UlrichHolzman@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dominik','Hueber','DominikHueber@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Diederich','SarahDiederich@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Fuerst','EricFuerst@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Tanja','Wirtz','TanjaWirtz@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Juliane','Eberhardt','JulianeEberhardt@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Steffen','Hofmann','SteffenHofmann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kerstin','Duerr','KerstinDuerr@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Kastner','DennisKastner@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Wolfgang','Zimmer','WolfgangZimmer@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Annett','Hoffmann','AnnettHoffmann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lea','Nacht','LeaNacht@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Daecher','DieterDaecher@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Andrea','Herzog','AndreaHerzog@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Hoch','FlorianHoch@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralph','Amsel','RalphAmsel@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sebastian','Fruehauf','SebastianFruehauf@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralph','Junker','RalphJunker@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Faust','LukasFaust@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Andrea','Schmid','AndreaSchmid@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jörg','Zimmerman','JorgZimmerman@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Yvonne','Abt','YvonneAbt@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Mandy','Schwartz','MandySchwartz@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jens','Muench','JensMuench@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Herman','JonasHerman@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Bernd','Moench','BerndMoench@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ursula','Weiss','UrsulaWeiss@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Beike','LukasBeike@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karolin','Müller','KarolinMuller@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Steffen','Cole','SteffenCole@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kevin','Reiniger','KevinReiniger@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ute','Pfeifer','UtePfeifer@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Annett','Herman','AnnettHerman@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ulrike','Waechter','UlrikeWaechter@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marco','Konig','MarcoKonig@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jana','Weber','JanaWeber@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Juliane','Eiffel','JulianeEiffel@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Andrea','Pabst','AndreaPabst@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabine','Schaefer','SabineSchaefer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jessica','Schmitt','JessicaSchmitt@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Grunewald','HeikeGrunewald@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Daniela','Gottlieb','DanielaGottlieb@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Vanessa','Baumgartner','VanessaBaumgartner@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dominik','Klein','DominikKlein@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Michael','Hoch','MichaelHoch@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stefanie','Bauer','StefanieBauer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marcel','Drechsler','MarcelDrechsler@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katharina','Eichmann','KatharinaEichmann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Petra','Hartmann','PetraHartmann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Möller','LeahMoller@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Leon','Ritter','LeonRitter@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anke','Neustadt','AnkeNeustadt@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ursula','Theissen','UrsulaTheissen@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anja','Fruehauf','AnjaFruehauf@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jens','Dietrich','JensDietrich@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Birgit','Eichel','BirgitEichel@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Susanne','Abendroth','SusanneAbendroth@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ute','Vogler','UteVogler@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Ackerman','MaxAckerman@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Antje','Mauer','AntjeMauer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Schmitz','FelixSchmitz@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tobias','Luft','TobiasLuft@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katharina','Jaeger','KatharinaJaeger@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Kaestner','HeikeKaestner@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophia','Werner','SophiaWerner@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stefanie','Braun','StefanieBraun@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Beich','DieterBeich@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Mandy','Nagel','MandyNagel@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mathias','Huber','MathiasHuber@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Maria','Fried','MariaFried@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Freeh','InesFreeh@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Johanna','Freud','JohannaFreud@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jens','Ritter','JensRitter@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anja','Ziegler','AnjaZiegler@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Brigitte','Kirsch','BrigitteKirsch@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Uwe','Maier','UweMaier@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Peter','Baumgaertner','PeterBaumgaertner@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stephanie','Ackermann','StephanieAckermann@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Faerber','LukasFaerber@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marko','Freytag','MarkoFreytag@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Baader','FrankBaader@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marcel','Faust','MarcelFaust@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sebastian','Eberhart','SebastianEberhart@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christina','Gaertner','ChristinaGaertner@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Ackermann','LenaAckermann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Maier','PaulMaier@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Eggers','SarahEggers@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Frueh','PaulFrueh@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kerstin','Frei','KerstinFrei@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anne','Wexler','AnneWexler@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Franziska','Sankt','FranziskaSankt@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophia','Waechter','SophiaWaechter@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Yvonne','Weissmuller','YvonneWeissmuller@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marco','Werfel','MarcoWerfel@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maximilian','Koenig','MaximilianKoenig@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Bar','NicoleBar@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jörg','Ostermann','JorgOstermann@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karolin','Lehmann','KarolinLehmann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Tanja','Fassbinder','TanjaFassbinder@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kerstin','Naumann','KerstinNaumann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ute','Roth','UteRoth@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stephanie','Biermann','StephanieBiermann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Susanne','Probst','SusanneProbst@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kristian','Abendroth','KristianAbendroth@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christine','Reiniger','ChristineReiniger@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Hirsch','LukasHirsch@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Rothschild','JurgenRothschild@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophie','Unger','SophieUnger@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jana','Neumann','JanaNeumann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anne','Eisenberg','AnneEisenberg@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lisa','Mayer','LisaMayer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabine','Busch','SabineBusch@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Leon','Pfeffer','LeonPfeffer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Uta','Osterhagen','UtaOsterhagen@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Kohler','MaxKohler@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Robert','Gaertner','RobertGaertner@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stephanie','Reiniger','StephanieReiniger@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Baumgartner','FlorianBaumgartner@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Vanessa','Schwartz','VanessaSchwartz@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Baecker','KatrinBaecker@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stephan','Seiler','StephanSeiler@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Torsten','Maier','TorstenMaier@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Mandy','Propst','MandyPropst@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stefan','Moeller','StefanMoeller@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Andreas','Kastner','AndreasKastner@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maximilian','Schwab','MaximilianSchwab@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anna','Nacht','AnnaNacht@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Niklas','Schmidt','NiklasSchmidt@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jessica','Kohl','JessicaKohl@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Kohler','JonasKohler@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Andrea','Eisenberg','AndreaEisenberg@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Ritter','KathrinRitter@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Theissen','SaraTheissen@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marko','Maurer','MarkoMaurer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mathias','Naumann','MathiasNaumann@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Susanne','Schiffer','SusanneSchiffer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Claudia','Becker','ClaudiaBecker@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kevin','Hirsch','KevinHirsch@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Klaudia','Schroeder','KlaudiaSchroeder@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophie','Urner','SophieUrner@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Uta','Propst','UtaPropst@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Niklas','Oster','NiklasOster@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Diana','Ebersbach','DianaEbersbach@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kevin','Gersten','KevinGersten@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Silke','Lange','SilkeLange@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Gottlieb','DavidGottlieb@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Mueller','TimMueller@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Bernd','Weisz','BerndWeisz@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Johanna','Freud','JohannaFreud@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Gärtner','HeikeGartner@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Wirth','LeahWirth@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stefanie','Fink','StefanieFink@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tom','Fisher','TomFisher@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Steffen','Eisenberg','SteffenEisenberg@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ute','Friedmann','UteFriedmann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karolin','Kohler','KarolinKohler@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Schultheiss','DieterSchultheiss@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Doreen','Urner','DoreenUrner@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Silke','Achen','SilkeAchen@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Koehler','JanKoehler@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Laura','Hahn','LauraHahn@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Wolfgang','Pfeiffer','WolfgangPfeiffer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Niklas','Wagner','NiklasWagner@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Werfel','DennisWerfel@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Moench','InesMoench@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lisa','Becker','LisaBecker@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Uta','Bergmann','UtaBergmann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Seiler','LeonieSeiler@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Steffen','Reinhardt','SteffenReinhardt@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karolin','Baumgartner','KarolinBaumgartner@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','René','Wirtz','ReneWirtz@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Yvonne','Weber','YvonneWeber@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Birgit','Gottschalk','BirgitGottschalk@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Lang','PaulLang@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marko','Baader','MarkoBaader@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabine','Maurer','SabineMaurer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Uta','Lang','UtaLang@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Sankt','DavidSankt@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sven','Hahn','SvenHahn@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anna','Papst','AnnaPapst@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Brauer','LeonieBrauer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Baumgartner','KathrinBaumgartner@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Weber','DavidWeber@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kerstin','Beckenbauer','KerstinBeckenbauer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Dreher','KatrinDreher@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Tanja','Frueh','TanjaFrueh@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Nadel','NicoleNadel@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Angelika','Baumgaertner','AngelikaBaumgaertner@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Kuster','LukasKuster@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lea','Eberhardt','LeaEberhardt@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Wurfel','MichelleWurfel@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Daniela','Foerster','DanielaFoerster@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Pfaff','KatrinPfaff@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christine','Hoffmann','ChristineHoffmann@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Kruger','JurgenKruger@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Mandy','Busch','MandyBusch@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Uwe','Becker','UweBecker@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Benjamin','Wulf','BenjaminWulf@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Luca','Ackermann','LucaAckermann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Torsten','Dietrich','TorstenDietrich@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katharina','Bach','KatharinaBach@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Robert','Engel','RobertEngel@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Daniel','Dresdner','DanielDresdner@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jessika','Huber','JessikaHuber@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Pfeffer','SarahPfeffer@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thomas','Herrmann','ThomasHerrmann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Diana','Friedman','DianaFriedman@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anna','Eichelberger','AnnaEichelberger@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Angelika','Gersten','AngelikaGersten@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Urner','DavidUrner@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Erik','Braun','ErikBraun@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anja','Zweig','AnjaZweig@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Vogt','JanVogt@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kerstin','Daecher','KerstinDaecher@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Krause','EricKrause@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Bauer','JanBauer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Robert','Fenstermacher','RobertFenstermacher@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ursula','Fleischer','UrsulaFleischer@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Wolfgang','Zimmerman','WolfgangZimmerman@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anne','Kluge','AnneKluge@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Schulz','MatthiasSchulz@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marco','Wagner','MarcoWagner@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Angelika','Beike','AngelikaBeike@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','René','Kluge','ReneKluge@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kristin','Ackermann','KristinAckermann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jana','Fleischer','JanaFleischer@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Junker','DieterJunker@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Moeller','SarahMoeller@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Leon','Kuhn','LeonKuhn@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Bernd','Kluge','BerndKluge@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kevin','Naumann','KevinNaumann@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jörg','Drescher','JorgDrescher@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Luft','DennisLuft@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Birgit','Pfeifer','BirgitPfeifer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Patrick','Gloeckner','PatrickGloeckner@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jörg','Mayer','JorgMayer@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karolin','Brandt','KarolinBrandt@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Koch','InesKoch@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Patrick','Hoover','PatrickHoover@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Susanne','Hertz','SusanneHertz@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','René','Lehrer','ReneLehrer@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stephanie','Braun','StephanieBraun@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Patrick','Junker','PatrickJunker@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Phillipp','Gaertner','PhillippGaertner@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Phillipp','Rothschild','PhillippRothschild@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Annett','Muench','AnnettMuench@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Hueber','DavidHueber@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Traugott','SaraTraugott@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Niklas','Bar','NiklasBar@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Martin','Gersten','MartinGersten@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stephan','Rothstein','StephanRothstein@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Michael','Scherer','MichaelScherer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Seiler','LenaSeiler@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thomas','Unger','ThomasUnger@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Klaus','Lemann','KlausLemann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marina','Wolf','MarinaWolf@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Andreas','Strauss','AndreasStrauss@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thomas','Mahler','ThomasMahler@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Nacht','PaulNacht@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Hertzog','MaxHertzog@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Susanne','Koenig','SusanneKoenig@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Brigitte','Glockner','BrigitteGlockner@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Manuela','Bar','ManuelaBar@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Brigitte','Fleischer','BrigitteFleischer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Steffen','Egger','SteffenEgger@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Laura','Werner','LauraWerner@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Philipp','Jaeger','PhilippJaeger@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Leon','Baum','LeonBaum@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Manuela','Reiniger','ManuelaReiniger@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','René','Gruenewald','ReneGruenewald@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Gerste','KathrinGerste@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Muench','HeikeMuench@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Vogt','SaraVogt@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anja','Wagner','AnjaWagner@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anja','Friedman','AnjaFriedman@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Doreen','Ebersbacher','DoreenEbersbacher@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marie','Probst','MarieProbst@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mario','Eiffel','MarioEiffel@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marco','Meyer','MarcoMeyer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Yvonne','Schwartz','YvonneSchwartz@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karin','Bergmann','KarinBergmann@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jennifer','Wirtz','JenniferWirtz@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','René','Schäfer','ReneSchafer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Phillipp','Gerber','PhillippGerber@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Daniela','Ackerman','DanielaAckerman@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Traugott','LeonieTraugott@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Rothschild','MichelleRothschild@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Wolf','LeahWolf@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Markus','Vogt','MarkusVogt@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Kuster','KathrinKuster@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maximilian','Osterhagen','MaximilianOsterhagen@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Maria','Holzman','MariaHolzman@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophia','Farber','SophiaFarber@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Robert','Wechsler','RobertWechsler@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Koertig','KatrinKoertig@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Martin','Rothstein','MartinRothstein@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stephan','Oster','StephanOster@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marina','Kaiser','MarinaKaiser@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Melanie','Schreiner','MelanieSchreiner@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Daniel','Lowe','DanielLowe@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lisa','Bürger','LisaBurger@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Herrmann','FelixHerrmann@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marie','Kaiser','MarieKaiser@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Doreen','Vogel','DoreenVogel@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Beike','TimBeike@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Franziska','Mayer','FranziskaMayer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ulrich','Seiler','UlrichSeiler@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karin','Faber','KarinFaber@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thorsten','Wannemaker','ThorstenWannemaker@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Hartmann','MichelleHartmann@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabine','Keller','SabineKeller@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Zweig','DennisZweig@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Frankfurter','SaraFrankfurter@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Bergmann','KathrinBergmann@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Köhler','SarahKohler@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Neumann','JonasNeumann@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Steffen','Drechsler','SteffenDrechsler@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Fuchs','LukasFuchs@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Tanja','Theissen','TanjaTheissen@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ulrich','Jaeger','UlrichJaeger@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Austerlitz','MaxAusterlitz@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Theissen','FlorianTheissen@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Werner','FlorianWerner@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ulrich','Strauss','UlrichStrauss@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anke','Lange','AnkeLange@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mario','Weissmuller','MarioWeissmuller@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Phillipp','Ackerman','PhillippAckerman@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Nussbaum','DennisNussbaum@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dirk','Krüger','DirkKruger@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabrina','Baader','SabrinaBaader@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marcel','Weissmuller','MarcelWeissmuller@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Egger','SarahEgger@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marko','Jager','MarkoJager@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Michael','Duerr','MichaelDuerr@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Peter','Gaertner','PeterGaertner@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anke','Abendroth','AnkeAbendroth@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marie','Gerste','MarieGerste@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Janina','Schweitzer','JaninaSchweitzer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katja','Weiss','KatjaWeiss@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anja','Eisenhower','AnjaEisenhower@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Torsten','Möller','TorstenMoller@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stefanie','Kruger','StefanieKruger@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katja','Schneider','KatjaSchneider@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maik','Pfeifer','MaikPfeifer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Ostermann','KatrinOstermann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Antje','Sanger','AntjeSanger@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Julia','Hertz','JuliaHertz@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Tanja','Wurfel','TanjaWurfel@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dominik','Schroeder','DominikSchroeder@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lea','Schulz','LeaSchulz@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Franziska','Keller','FranziskaKeller@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jennifer','Freud','JenniferFreud@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anne','Lowe','AnneLowe@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anke','Rothstein','AnkeRothstein@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Bernd','Ostermann','BerndOstermann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marcel','Schiffer','MarcelSchiffer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Klaus','Beckenbauer','KlausBeckenbauer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Nacht','EricNacht@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lucas','Pabst','LucasPabst@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Vogt','MatthiasVogt@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Mayer','InesMayer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Annett','Baum','AnnettBaum@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Mueller','JanMueller@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Friedmann','HeikeFriedmann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Pfeffer','SarahPfeffer@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Julia','Fenstermacher','JuliaFenstermacher@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Cole','JonasCole@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kevin','Schmid','KevinSchmid@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Swen','Kuefer','SwenKuefer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Metzger','FelixMetzger@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Torsten','Rothschild','TorstenRothschild@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Schröder','FrankSchroder@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Klaus','Duerr','KlausDuerr@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Klaus','Ackerman','KlausAckerman@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Petra','Kastner','PetraKastner@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Gärtner','TimGartner@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Daniel','Papst','DanielPapst@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Bergmann','InesBergmann@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lucas','Fisher','LucasFisher@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Michael','Ebersbach','MichaelEbersbach@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Peter','Vogt','PeterVogt@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jens','Schmidt','JensSchmidt@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mario','Durr','MarioDurr@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Hofmann','MatthiasHofmann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Brandt','EricBrandt@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Pfeifer','MaxPfeifer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anja','Reinhard','AnjaReinhard@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jens','Faust','JensFaust@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mario','Pfeifer','MarioPfeifer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Torsten','Freitag','TorstenFreitag@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Foerster','JurgenFoerster@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Maria','König','MariaKonig@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Robert','Rothschild','RobertRothschild@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Monika','Kohl','MonikaKohl@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Mandy','Farber','MandyFarber@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Uwe','Himmel','UweHimmel@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Simone','Ackerman','SimoneAckerman@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Janina','Boehm','JaninaBoehm@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christin','Mayer','ChristinMayer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Antje','Busch','AntjeBusch@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Maurer','LeonieMaurer@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Daniel','Maurer','DanielMaurer@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Kaestner','JanKaestner@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ute','Schulz','UteSchulz@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Hoover','NicoleHoover@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mathias','Lang','MathiasLang@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Faust','FlorianFaust@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maik','Trommler','MaikTrommler@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marco','Naumann','MarcoNaumann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Neudorf','DennisNeudorf@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anke','Klug','AnkeKlug@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Alexander','Ebersbach','AlexanderEbersbach@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jennifer','Ostermann','JenniferOstermann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Vanessa','Waechter','VanessaWaechter@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Maria','Herman','MariaHerman@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jessika','Schulz','JessikaSchulz@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marcel','Krueger','MarcelKrueger@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christine','Lowe','ChristineLowe@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marie','Keller','MarieKeller@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Gabriele','Austerlitz','GabrieleAusterlitz@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Franziska','Schulz','FranziskaSchulz@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Kaestner','DavidKaestner@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jessica','Theiss','JessicaTheiss@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Leon','Osterhagen','LeonOsterhagen@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Klaus','Nagel','KlausNagel@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Torsten','Oster','TorstenOster@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Schröder','FrankSchroder@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralph','Baecker','RalphBaecker@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Luca','Boehm','LucaBoehm@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marina','Frueh','MarinaFrueh@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mike','Naumann','MikeNaumann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maik','Konig','MaikKonig@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anke','Kaestner','AnkeKaestner@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Doreen','Schwab','DoreenSchwab@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marko','Eisenberg','MarkoEisenberg@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Theissen','HeikeTheissen@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Brigitte','Eisenberg','BrigitteEisenberg@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jana','Waechter','JanaWaechter@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Beike','LenaBeike@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Melanie','Durr','MelanieDurr@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Erik','Kortig','ErikKortig@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Bürger','HeikeBurger@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Uwe','Eisenhauer','UweEisenhauer@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Mehler','KatrinMehler@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Manuela','Pfeffer','ManuelaPfeffer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Robert','Kaiser','RobertKaiser@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralph','Duerr','RalphDuerr@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lucas','Zimmermann','LucasZimmermann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Austerlitz','InesAusterlitz@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Seiler','KathrinSeiler@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Schweitzer','MaxSchweitzer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Wolfgang','Strauss','WolfgangStrauss@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Durr','FelixDurr@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Klaudia','Finkel','KlaudiaFinkel@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Andrea','Thalberg','AndreaThalberg@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Niklas','Abend','NiklasAbend@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Abendroth','DavidAbendroth@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Neumann','NicoleNeumann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kristin','Pfaff','KristinPfaff@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Steffen','Reinhard','SteffenReinhard@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Abendroth','NicoleAbendroth@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Antje','Nadel','AntjeNadel@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sven','Gottschalk','SvenGottschalk@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Markus','Ebersbacher','MarkusEbersbacher@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralph','Schmidt','RalphSchmidt@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jessica','Feierabend','JessicaFeierabend@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Laura','Keller','LauraKeller@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Silke','Klein','SilkeKlein@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Janina','Freud','JaninaFreud@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabine','Eggers','SabineEggers@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophia','Fuhrmann','SophiaFuhrmann@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karin','Eggers','KarinEggers@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Christian','Schmitz','ChristianSchmitz@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Michael','Dresdner','MichaelDresdner@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stefan','Kuester','StefanKuester@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Manuela','Brandt','ManuelaBrandt@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ursula','Fuerst','UrsulaFuerst@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Martin','Diederich','MartinDiederich@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christine','Kuhn','ChristineKuhn@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anke','Koch','AnkeKoch@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Loewe','JanLoewe@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kevin','Ackermann','KevinAckermann@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katja','Egger','KatjaEgger@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Wolfgang','Eiffel','WolfgangEiffel@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Holtzmann','SaraHoltzmann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Laura','Wirtz','LauraWirtz@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Dreher','JurgenDreher@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dirk','Wirtz','DirkWirtz@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Fuhrmann','NicoleFuhrmann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Christian','Egger','ChristianEgger@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Juliane','Schulze','JulianeSchulze@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Philipp','Baer','PhilippBaer@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Ehrlichmann','FlorianEhrlichmann@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thorsten','Friedmann','ThorstenFriedmann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Schmitz','KatrinSchmitz@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Schwarz','DieterSchwarz@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Christian','Kaestner','ChristianKaestner@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Gloeckner','SaraGloeckner@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Martina','Wulf','MartinaWulf@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Swen','Frueh','SwenFrueh@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Schreiner','KatrinSchreiner@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Gärtner','SarahGartner@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tobias','Schreiber','TobiasSchreiber@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Durr','DennisDurr@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stephan','Bosch','StephanBosch@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Birgit','Schäfer','BirgitSchafer@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Robert','Kuster','RobertKuster@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karolin','Bumgarner','KarolinBumgarner@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marina','Pfaff','MarinaPfaff@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Alexander','Ackermann','AlexanderAckermann@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Klaus','Koehler','KlausKoehler@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophia','Dreher','SophiaDreher@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Herzog','FrankHerzog@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Lemann','LeahLemann@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Amsel','LenaAmsel@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Gärtner','InesGartner@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Theiss','InesTheiss@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Maurer','FlorianMaurer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kevin','Muller','KevinMuller@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anna','Zimmermann','AnnaZimmermann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jennifer','Krause','JenniferKrause@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Alexander','Schreiner','AlexanderSchreiner@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maik','Zimmerman','MaikZimmerman@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Seiler','LeonieSeiler@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Zimmer','JonasZimmer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Johanna','Wannemaker','JohannaWannemaker@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Maria','Brauer','MariaBrauer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Biermann','FlorianBiermann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marie','Boehm','MarieBoehm@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Wagner','FelixWagner@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marcel','Baier','MarcelBaier@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Martin','Brandt','MartinBrandt@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Laura','Ostermann','LauraOstermann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Gabriele','Fischer','GabrieleFischer@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marina','Beckenbauer','MarinaBeckenbauer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Klein','MichelleKlein@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Susanne','Hartmann','SusanneHartmann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Baier','TimBaier@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Vanessa','Fuchs','VanessaFuchs@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stephan','Glockner','StephanGlockner@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ute','Lang','UteLang@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Wolfgang','Freud','WolfgangFreud@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Luca','Daecher','LucaDaecher@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophia','Eichel','SophiaEichel@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Martina','Winkel','MartinaWinkel@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dirk','König','DirkKonig@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stefan','Zimmermann','StefanZimmermann@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Janina','Oster','JaninaOster@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Claudia','Busch','ClaudiaBusch@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Fuhrmann','LeonieFuhrmann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Markus','Egger','MarkusEgger@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stefan','Schultz','StefanSchultz@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Eichelberger','DavidEichelberger@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Fruehauf','SaraFruehauf@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tobias','Biermann','TobiasBiermann@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Doreen','Schulze','DoreenSchulze@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Wannemaker','LeonieWannemaker@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nadine','Kuhn','NadineKuhn@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Eiffel','MaxEiffel@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Bauer','LeahBauer@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Melanie','Amsel','MelanieAmsel@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Peter','Bar','PeterBar@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jana','Bar','JanaBar@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jörg','Kohl','JorgKohl@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stefan','Reinhardt','StefanReinhardt@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Birgit','Maurer','BirgitMaurer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nadine','Brauer','NadineBrauer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Claudia','Brandt','ClaudiaBrandt@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dominik','Meyer','DominikMeyer@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kristian','Baumgartner','KristianBaumgartner@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Gerste','JonasGerste@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Markus','Müller','MarkusMuller@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Torsten','Eisenhower','TorstenEisenhower@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thorsten','Reinhardt','ThorstenReinhardt@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lea','Kuhn','LeaKuhn@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ulrich','Friedman','UlrichFriedman@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Mauer','MatthiasMauer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Michael','Frei','MichaelFrei@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Uwe','Walter','UweWalter@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralf','Kuhn','RalfKuhn@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Barbara','Kuester','BarbaraKuester@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','René','Eisenhauer','ReneEisenhauer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stefan','Schultheiss','StefanSchultheiss@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Herman','TimHerman@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Luca','Bieber','LucaBieber@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kristin','Kohler','KristinKohler@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anke','Probst','AnkeProbst@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karin','Eichmann','KarinEichmann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maximilian','Scherer','MaximilianScherer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Schmitt','FrankSchmitt@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Uwe','Frei','UweFrei@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sebastian','Herrmann','SebastianHerrmann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabrina','Schmidt','SabrinaSchmidt@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Philipp','Krüger','PhilippKruger@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maik','Bieber','MaikBieber@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Yvonne','Ebersbacher','YvonneEbersbacher@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Maria','Kruger','MariaKruger@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Foerster','LenaFoerster@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marco','Jaeger','MarcoJaeger@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Uta','Kaufmann','UtaKaufmann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Peters','EricPeters@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Patrick','Bader','PatrickBader@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anke','Fenstermacher','AnkeFenstermacher@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maximilian','Rothstein','MaximilianRothstein@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anne','Baumgaertner','AnneBaumgaertner@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Silke','Maur','SilkeMaur@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lisa','Möller','LisaMoller@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marina','Burger','MarinaBurger@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Fischer','DieterFischer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Claudia','Braun','ClaudiaBraun@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Susanne','Kappel','SusanneKappel@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Schroeder','DieterSchroeder@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Glockner','FrankGlockner@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Swen','Amsel','SwenAmsel@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Gruenewald','SaraGruenewald@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophia','Wannemaker','SophiaWannemaker@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Braun','HeikeBraun@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mike','Lemann','MikeLemann@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marko','Weissmuller','MarkoWeissmuller@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tom','Herrmann','TomHerrmann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Müller','KathrinMuller@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Kohl','FrankKohl@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Hahn','MatthiasHahn@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Herman','SaraHerman@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Anna','Muller','AnnaMuller@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Klaudia','Lemann','KlaudiaLemann@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lisa','Kaestner','LisaKaestner@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lea','Metzger','LeaMetzger@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Philipp','Sommer','PhilippSommer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Zimmermann','FelixZimmermann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Neustadt','EricNeustadt@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Hertz','JonasHertz@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sven','Frankfurter','SvenFrankfurter@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Freud','HeikeFreud@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sebastian','Fisher','SebastianFisher@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Fassbinder','MichelleFassbinder@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stephan','Bachmeier','StephanBachmeier@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Luca','Faber','LucaFaber@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jens','Wulf','JensWulf@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Fruehauf','JanFruehauf@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Tanja','Beike','TanjaBeike@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dirk','Schröder','DirkSchroder@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Hueber','LukasHueber@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jessica','Wulf','JessicaWulf@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabrina','Naumann','SabrinaNaumann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Gerste','NicoleGerste@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maik','Barth','MaikBarth@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Schmitt','NicoleSchmitt@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maximilian','Sommer','MaximilianSommer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mathias','Lehrer','MathiasLehrer@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tobias','Meier','TobiasMeier@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jörg','Schiffer','JorgSchiffer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Gaertner','LeonieGaertner@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marko','Gruenewald','MarkoGruenewald@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Claudia','Neustadt','ClaudiaNeustadt@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Gruenewald','JanGruenewald@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stephan','Kohl','StephanKohl@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Doreen','Dreher','DoreenDreher@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Grunwald','JurgenGrunwald@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Barbara','Kohl','BarbaraKohl@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Andrea','Holtzmann','AndreaHoltzmann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Angelika','Weber','AngelikaWeber@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Simone','Schweitzer','SimoneSchweitzer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lea','Eisenhower','LeaEisenhower@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jens','Foerster','JensFoerster@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Möller','KathrinMoller@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Benjamin','Papst','BenjaminPapst@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Vanessa','Seiler','VanessaSeiler@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thorsten','Eisenhower','ThorstenEisenhower@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Julia','Mueller','JuliaMueller@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jana','Freytag','JanaFreytag@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Leon','Werfel','LeonWerfel@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mike','Müller','MikeMuller@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kristin','Pabst','KristinPabst@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Gabriele','Schweizer','GabrieleSchweizer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Heike','Bayer','HeikeBayer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Peter','Eggers','PeterEggers@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Michael','Muller','MichaelMuller@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Ziegler','LenaZiegler@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sebastian','Ebersbach','SebastianEbersbach@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thomas','Amsel','ThomasAmsel@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Braun','EricBraun@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Johanna','Cole','JohannaCole@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christina','Reiniger','ChristinaReiniger@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katja','Kruger','KatjaKruger@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Peters','DavidPeters@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marie','Schaefer','MarieSchaefer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tom','Baum','TomBaum@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Tanja','Winkel','TanjaWinkel@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Susanne','Kohler','SusanneKohler@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karin','Becker','KarinBecker@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Julia','Faber','JuliaFaber@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Schmitz','MatthiasSchmitz@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tobias','Weisz','TobiasWeisz@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Fischer','MatthiasFischer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Doreen','Eichmann','DoreenEichmann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Abendroth','MatthiasAbendroth@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dominik','Schulz','DominikSchulz@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ulrike','Busch','UlrikeBusch@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','René','Austerlitz','ReneAusterlitz@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Wirtz','JanWirtz@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Patrick','Hertzog','PatrickHertzog@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Grunwald','FelixGrunwald@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kristian','Weber','KristianWeber@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Melanie','Abendroth','MelanieAbendroth@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Andrea','Austerlitz','AndreaAusterlitz@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stephanie','Ackerman','StephanieAckerman@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tom','Austerlitz','TomAusterlitz@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Daniela','Hertz','DanielaHertz@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Melanie','Waechter','MelanieWaechter@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lea','Koch','LeaKoch@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Amsel','TimAmsel@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ulrike','Freud','UlrikeFreud@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Maria','Köhler','MariaKohler@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophia','Seiler','SophiaSeiler@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Amsel','JurgenAmsel@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lena','Schmitt','LenaSchmitt@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Susanne','Busch','SusanneBusch@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Martin','Ebersbach','MartinEbersbach@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Johanna','Bürger','JohannaBurger@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Peters','JurgenPeters@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sara','Schwarz','SaraSchwarz@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Diana','Ritter','DianaRitter@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Brigitte','Muller','BrigitteMuller@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Martin','Saenger','MartinSaenger@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Julia','Scholz','JuliaScholz@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sabine','Dreher','SabineDreher@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kerstin','Winkel','KerstinWinkel@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marcel','Reiniger','MarcelReiniger@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Claudia','Zimmerman','ClaudiaZimmerman@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Yvonne','Moench','YvonneMoench@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Kalb','TimKalb@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Tanja','Schuster','TanjaSchuster@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Baer','EricBaer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralph','Nussbaum','RalphNussbaum@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thorsten','Koertig','ThorstenKoertig@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Silke','Dreher','SilkeDreher@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Schröder','DennisSchroder@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thorsten','Thalberg','ThorstenThalberg@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Peter','Eiffel','PeterEiffel@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Vanessa','Gruenewald','VanessaGruenewald@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Claudia','Kappel','ClaudiaKappel@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Alexander','Fruehauf','AlexanderFruehauf@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Phillipp','Oster','PhillippOster@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Baum','NicoleBaum@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tom','Durr','TomDurr@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katja','Weisz','KatjaWeisz@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Kohler','JurgenKohler@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Vanessa','Bieber','VanessaBieber@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Urner','PaulUrner@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophie','Furst','SophieFurst@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Daniel','Zimmermann','DanielZimmermann@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Antje','Weber','AntjeWeber@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ursula','Koenig','UrsulaKoenig@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ute','Schneider','UteSchneider@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marina','Peters','MarinaPeters@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mike','Berg','MikeBerg@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Andrea','Pfeiffer','AndreaPfeiffer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sandra','Koehler','SandraKoehler@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marco','Beyer','MarcoBeyer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Hoch','MichelleHoch@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralf','Amsel','RalfAmsel@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Philipp','Daecher','PhilippDaecher@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Markus','Hofmann','MarkusHofmann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Martin','Herz','MartinHerz@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Philipp','Friedmann','PhilippFriedmann@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Rothstein','DieterRothstein@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tom','Muench','TomMuench@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Monika','Bieber','MonikaBieber@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Kluge','FlorianKluge@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Koehler','JurgenKoehler@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jan','Engel','JanEngel@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Eric','Meyer','EricMeyer@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marie','Klein','MarieKlein@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Florian','Fleischer','FlorianFleischer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stefan','Kalb','StefanKalb@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Daecher','PaulDaecher@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Patrick','Hirsch','PatrickHirsch@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dieter','Faust','DieterFaust@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tom','Schmitt','TomSchmitt@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Sebastian','Bieber','SebastianBieber@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sophie','Werner','SophieWerner@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','David','Bohm','DavidBohm@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marina','Loewe','MarinaLoewe@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Philipp','Faber','PhilippFaber@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jana','Biermann','JanaBiermann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christine','Schäfer','ChristineSchafer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ursula','Schuhmacher','UrsulaSchuhmacher@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Martin','Fleischer','MartinFleischer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ute','Gerber','UteGerber@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karin','Wurfel','KarinWurfel@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Weiß','LukasWeiss@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kristin','Kohl','KristinKohl@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Koehler','TimKoehler@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Martina','Schmitt','MartinaSchmitt@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dirk','Urner','DirkUrner@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ute','Schmid','UteSchmid@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karolin','Beyer','KarolinBeyer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katrin','Herzog','KatrinHerzog@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karolin','Eichmann','KarolinEichmann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Ebersbach','LeahEbersbach@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Bieber','LeahBieber@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lucas','Schultheiss','LucasSchultheiss@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sarah','Eberhardt','SarahEberhardt@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mario','Schäfer','MarioSchafer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Friedman','DennisFriedman@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Johanna','Moench','JohannaMoench@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Wolfgang','Fleischer','WolfgangFleischer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Antje','Aachen','AntjeAachen@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christine','Gloeckner','ChristineGloeckner@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Rothschild','FelixRothschild@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jana','Hartmann','JanaHartmann@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kathrin','Sommer','KathrinSommer@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Gerste','MichelleGerste@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Christin','Vogt','ChristinVogt@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Mandy','Ritter','MandyRitter@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ines','Peters','InesPeters@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Brigitte','Schiffer','BrigitteSchiffer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Antje','Decker','AntjeDecker@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Andreas','Traugott','AndreasTraugott@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Maria','Schultheiss','MariaSchultheiss@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Braun','TimBraun@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Erik','Drescher','ErikDrescher@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Michelle','Hahn','MichelleHahn@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thorsten','Kaufmann','ThorstenKaufmann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stephan','Theiss','StephanTheiss@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marko','Werfel','MarkoWerfel@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Zimmerman','FrankZimmerman@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Stephan','Seiler','StephanSeiler@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Franziska','Ostermann','FranziskaOstermann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kristin','Fuhrmann','KristinFuhrmann@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Vanessa','Feierabend','VanessaFeierabend@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jessika','Hoover','JessikaHoover@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katharina','Schiffer','KatharinaSchiffer@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Schneider','MaxSchneider@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Simone','Fuchs','SimoneFuchs@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Klaudia','Mayer','KlaudiaMayer@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Bachmeier','NicoleBachmeier@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Kristian','Ackerman','KristianAckerman@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Johanna','Kohl','JohannaKohl@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jörg','Kluge','JorgKluge@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Mandy','Strauss','MandyStrauss@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Luca','Theiss','LucaTheiss@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sandra','Koenig','SandraKoenig@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maik','Huber','MaikHuber@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Benjamin','Metzger','BenjaminMetzger@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Ulrike','Schroeder','UlrikeSchroeder@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lea','Lehmann','LeaLehmann@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Klaus','Urner','KlausUrner@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Laura','Decker','LauraDecker@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Kohl','FrankKohl@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Maik','Mueller','MaikMueller@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katharina','Gaertner','KatharinaGaertner@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Lisa','Daecher','LisaDaecher@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Silke','Mayer','SilkeMayer@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Alexander','Eisenberg','AlexanderEisenberg@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nadine','Dresdner','NadineDresdner@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Neudorf','MatthiasNeudorf@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karolin','Konig','KarolinKonig@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Pabst','MaxPabst@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Junker','LukasJunker@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Karin','Maier','KarinMaier@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Trommler','JonasTrommler@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Katharina','Fenstermacher','KatharinaFenstermacher@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jürgen','Freitag','JurgenFreitag@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sandra','Moeller','SandraMoeller@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Frank','Schuster','FrankSchuster@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Laura','Herz','LauraHerz@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Bernd','Fischer','BerndFischer@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Huber','PaulHuber@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Alexander','Beich','AlexanderBeich@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jennifer','Koch','JenniferKoch@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Paul','Pfeffer','PaulPfeffer@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Max','Kunze','MaxKunze@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ralf','Metzger','RalfMetzger@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leah','Wagner','LeahWagner@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dirk','Lowe','DirkLowe@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Stephanie','Baer','StephanieBaer@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tim','Frei','TimFrei@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Petra','Rothstein','PetraRothstein@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Klaus','Werner','KlausWerner@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Claudia','Jager','ClaudiaJager@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Sandra','Fisher','SandraFisher@gustr.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Doreen','Schwartz','DoreenSchwartz@rhyta.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marie','Moeller','MarieMoeller@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Matthias','Bach','MatthiasBach@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Christian','Frankfurter','ChristianFrankfurter@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Tom','Grunewald','TomGrunewald@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Leonie','Faerber','LeonieFaerber@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Mike','Bayer','MikeBayer@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Melanie','Metzger','MelanieMetzger@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Silke','Bayer','SilkeBayer@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Phillipp','Schulz','PhillippSchulz@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Monika','Vogt','MonikaVogt@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Michael','Neumann','MichaelNeumann@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Brigitte','Fruehauf','BrigitteFruehauf@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Marie','Daecher','MarieDaecher@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marcel','Biermann','MarcelBiermann@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Kristin','Fuerst','KristinFuerst@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Marko','Schiffer','MarkoSchiffer@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Jennifer','Amsel','JenniferAmsel@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Felix','Reinhardt','FelixReinhardt@superrito.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Doreen','Kuster','DoreenKuster@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Lukas','Bohm','LukasBohm@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jens','Busch','JensBusch@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dirk','Fuhrmann','DirkFuhrmann@dayrep.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Petra','Lemann','PetraLemann@cuvox.de');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Ulrich','Gerber','UlrichGerber@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Claudia','Zweig','ClaudiaZweig@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Dennis','Theiss','DennisTheiss@armyspy.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('female','Nicole','Fisher','NicoleFisher@einrot.com');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Thorsten','Weiss','ThorstenWeiss@teleworm.us');
insert into fakenames (gender,givenname,surname,emailaddress) values('male','Jonas','Holtzmann','JonasHoltzmann@einrot.com');

-- Ofusca os dados (nome e email) da tabela de usuários
update acl.tb_usuario_login
set ds_email=emailaddress,
ds_nome=givenname||' '||surname
from fakenames
where id_usuario%(select count(id) from fakenames)=id;

-- Ofusca nomes na tabela de documentos (necessário para ofuscar nomes de magistrados)
UPDATE client.tb_pess_doc_identificacao SET
ds_nome_pessoa=givenname||' '||surname
FROM fakenames
WHERE id_pessoa%(SELECT COUNT(id) FROM fakenames)=id;

-- Corrigir nomes das localizações a partir do nome do advogado
update tb_localizacao
set ds_localizacao = ds_nome || ' (' || ds_login || ')'
from tb_usuario_login 
where ds_login = replace(replace(replace(replace(substring(ds_localizacao from '%#"[(]%[)]#"%' for '#'),'(',''),')',''),'.',''),'-','')
and ds_localizacao ilike '%(%.%.%-%)%';

COMMIT; -- Ofuscar nomes