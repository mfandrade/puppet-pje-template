# Templates para o monitoramento pelo ZABBIX
Esses templates terão que ser importados para o zabbix

Templates responsáveis por monitorar os serviçoes que sustentão o PJe; (Apache, JBoss, PostgreSQL)

## Como Importar
Para importar o template acesse: "Configuration" -> "Templates" - > "Import". Selecione o arquivo para a importação e clique no botão "Import".

## 1.Template Apache Stats.xml

Template responsável por monitorar os serviços do **Apache**

Nesse template adione os Hosts que correspondem ao APACHE.

Obs.: É necessário adicionar o arquivo zapache no zabbix. Olhe no arquivo README.md no diretório zabbix/script aqui no GITLAB.

## 2.Template JBoss 5 PJE.xml

Template responsável por monitorar os serviçoes do **JBoss**

Nesse template adione os Hosts que correspondem ao JBoss.

## 3.Template PostgreSQL.xml

Template responsável por monitorar os serviçoes do **PostgreSQL**

## 4.Template Regionais.xml

Template responsável por monitorar as regionais, se elas estão funcionando.

## 5.Template WebService.xml

Template responsável por monitorar os serviços: OAB, RFB, BANCOs.