## PJeUpdate - Atualizar Versão do PJe

> Arquivos contidos nesse Branch devem ser utilizados na versão de *produção*

### Objetivo
Facilitar a evolução da versão do PJe através da automatização do processo de
atualização de versão para os servidores:
* PostgreSQL
* Jboss
* Apache 

### Versões Afetadas
Os procedimentos do pjeupdate devem ser executados a partir da versao 1.5.0.

### Scripts Principais
* pjeupdate-apache.sh = Script principal para realizar manutenção no apache.
* pjeupdate-jboss.sh = Script principal para atualizar a aplicação PJe-JT
* pjeupdate-postgres.sh = Script principal para executar os scripts SQL da atualização do PJe-JT.
* pjeupdate-jboss.properties = Arquivo com os parâmetros utilizadas pelo script pjeupdate-jboss.sh
* pjeupdate-postgres.properties = Arquivo com os parâmetros utilizadas pelo script pjeupdate-postgres.sh

### Scripts Auxiliares
* versao = Diretório com os scripts auxiliares. 

**Observação**: somente os scripts **.sh** e **.properties** do diretório "pjeupdate" devem ser baixados. Os arquivos do diretório "versao" serão baixados e executados automaticamente pelos scripts principais mencionados acima.