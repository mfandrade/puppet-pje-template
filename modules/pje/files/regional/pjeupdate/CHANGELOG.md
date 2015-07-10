### Changelog
----
### Versão 1.7.0:
* Manutenção nas bases bin e log, as quais serão executadas automaticamente pelo script pjeupdate-postgres.sh. Será necessário preencher os novos atributos BASE_1GRAU_BIN, BASE_1GRAU_LOG, BASE_2GRAU_BIN, BASE_2GRAU_LOG, BASE_3GRAU_BIN, BASE_3GRAU_LOG do arquivo pjeupdate-postgres.properties para a correta execução nas bases bin e log.

### Versão 1.6.0:
* Inclusão do script auxiliar que irá informar o comando a ser executado para inclusão do certificado da RFB no TST (serviço de contingência que será utilizado em caso de falha no serviço da RFB no CNJ).

### Versão 1.5.2:
* Não houve alteração de infraestrutura.

### Versões 1.5.1.x:
* Alteração de usuários e de senha no banco de dados e no datasource API-ds.xml e GIM-ds.xml através do pjeupdate-jboss e pjeupdate-postgres.

### Versão 1.5.1:
* Alteração do branch para baixar os scripts
* Versão de homologação (RC) = usar branch homologação 
    * Ex: https://git.pje.csjt.jus.br/infra/regional/tree/homologacao/pjeupdate
* Versão de produção = usar branch master
    * Ex: https://git.pje.csjt.jus.br/infra/regional/tree/master/pjeupdate
* Adição da variável URL_SCRIPT_AUX no arquivo pjeupdate-jboss.properties.
* Mudança nos valores aceitos pela variável INICIO_AUTO para os números dos graus no arquivo pjeupdate-jboss.properties.
* Substituição do parâmetro TRIBUNAL por GRAU nos arquivos no arquivo pjeupdate-jboss.properties e no arquivo pjeupdate-postgres.properties. Desta forma, é possível realizar atualização apenas nas instâncias escolhidas.
* Inclusão do procedimento pjeupdate-apache.sh.

### Versão 1.5.0:
* Dois novos arquivos de datasource em cada instância: GIM-ds.xml e API-ds.xml
* Os parâmetros de configuração do servidor SMTP para envio de e-mails, os quais eram configurados de forma manual no arquivo WEBINF/components.xml da aplicação, foram substituídos pelo parâmetro “parametros_smtp” da tabela core.tb_parametro.
* A alteração do valor padrão do parâmetro “parametros_smtp” será realizada de forma interativa através da execução do script pjeupdate-postgres.sh.