## Descrição dos templates.

**1.** Apache (Template Apache.xml)

Utiliza o script python status_apache.py que deve ser colocado na pasta /usr/lib/zabbix/externalscripts/ do servidor zabbix. Esse script (executado no próprio servidor zabbix) faz um parsing da página de server-status do apache e envia informações aos itens do tipo Zabbix Trapper (itens passivos).

O diferencial dessa solução em relação a outras (apenas Zabbix) que pesquisei na Internet:
   - Em ouras soluções cada um dos itens é consultado de forma ativa (um de cada vez), consumindo mais recursos. Essa solução faz o parsing de todas as infromações de uma vez, sendo mais performática.
   - Nas soluções de monitoramento passivas, normalmente o script é colocado no crontab de cada um dos servidores a serem monitorados, o que dificulta a administração da solução de monitoramento. Nessa solução, o script é executado no servidor zabbix (não é necessário alterar crontab dos clientes monitorados) e ativado através de um item ativo do zabbix (o controle de intervalo de monitoramento pode ser feito pelo próprio Zabbix)

Resumindo, essa solução tem as vantagens de performance das soluções de monitoramento passivas, e é praticamente "plug n play", ou seja, para adicionar novos hosts, basta incuí-los no template.

Esse template inclui um gatilho para avisar caso o número de conexões simultâneas esteja próximo do máximo e alguns gráficos onde podemos ver o número de conexões utilizadas detalhadas por estado. Por exemplo quantas conexões estão em keep alive (abertas, porém não utilizadas), reading request, sending reply, etc...
Em anexo um gráfico de exemplo: "Apache Status.jpg"

OBS: O script status_apache.py não é de minha autoria, eu fiz apenas pequenas alterações nele para adaptá-lo à nossa infra. As informações do autor estão no cabeçalho do script.

**2.** JBoss e itens específicos do PJE (Template JMX Generic.xml, Template JBoss 5 PJE.xml, Template PJE Aggregate.xml e Screens PJE.xml)

Fizemos uma varredura nos atributos dos MBeans disponibilizados pelo JBoss via JMX e acrescentamos muitos itens que são relevantes e que não vinham no template original do Zabbix nem nos templates disponíveis na Internet.

**2.1** Itens
Um resumo dos itens acrescentados:
* Template JMX Generic
    - Informações do ultimo GC (LastGcInfo)
* Template JBoss 5 PJE
    - Informações sobre sessões (sessões ativas, tempos médio e máximo das sessões)
    - Threads AJP (quantas estão ocupadas, em keep alive, etc)
    - Cluster 2grau (Jgroups)
    - Messaging (JMS)
    - Transaction Manager
    - Access e hit count do cache (Web Cache)
    - GlobalRequestProcessor (processing time, error count, etc)
    - Informações de cada Servlet do PJE
    - Conexões com o Banco (JCA Datasources)
* Template PJE Aggregate

**2.2** Gatilhos
Adaptamos a versão original do template do Zabbix desabilitando alguns gatilhos que davam muitos falsos positivos e criando outros. Seguem os mais relevantes:

* Template JMX Generic

  - {$CMS_OLD_GEN_TRIGGER}% CMS Old Gen Used After GC on {HOST.NAME} - Avisa quando a CMS Old Gen após o GC está acima de 60% por padrão. O gatilho antigo monitorava a memória utilizada, porém o comportamento normal do GC é deixar a memória chegar a níveis de utilização muito altos antes de limpá-la. Esse novo gatilho monitora a memória sempre *após* o GC, dessa forma temos um indicador mais adequado para medir a utilização da memória descontando o lixo. Esse indicador é um dos pontos chave para auxiliar na decisão de aumentar o número de instâncias.

  - {$MP_CMS_PERM_GEN_TRIGGER_MULTIPLIER}% mp CMS Perm Gen used on {HOST.NAME} - Avisa quando a Perm Gen (memória que contem as classes do PJE) está acima de 90% por padrão.

* Template JBoss 5 PJE
  - JBoss JGroups NumMembers < {$TRIGGER_JGROUPS_MEMBERS} - Avisa quando 1 ou mais membros estiverem fora do cluster

  - JBoss Datasource PJE_DESCANSO_QUARTZ_DS {$TRIGGER_DS}% Full - Avisa quando algum dos datasources estiver cheio

  - JBoss Datasource QueueSize > {$TRIGGER_DS_QUEUESIZE} -  Avisa quando a fila de um DS for maior que 5 por padrão

**2.3** Gráficos e Screens
Adicionadas no gráfico da Old Gen as informações do ultimo GC
Criadas Screens com o gráfico da Old Gen de todos os JBoss para melhor visualização da carga total no PJE e do balanceamento entre os JBoss.

OBS: As screens estão no arquivo Screens PJE.xml pois não fazem parte dos templates.

**2.4** Template PJE Aggregate
Com o intuito de simplificar a análise do ambiente, criamos esse template com itens do tipo aggregate do Zabbix que permitem somar os itens de vários servidores JBoss.
Isso permite que tenhamos informação, por exemplo, do número total de sessões, memória usada, threads, load dos servidores, etc
Segue em anexo o arquivo "Sessoes ativas 1grau.jpg" com o gráfico da soma das sessões ativas em todos os JBoss de 1grau como exemplo.
Para facilitar o uso dessa funcionalidade, é recomendavel criar 1 Host Group para cada grupo que pretendemos agregar as informações:
PJE JBoss
PJE JBoss 1grau
PJE JBoss 1grau Externos
PJE JBoss 1grau Internos
PJE JBoss 2grau
PJE JBoss 2grau Externos
PJE JBoss 2grau Internos

Para cada Host Group, criamos um Host manualmente, adicionamos o "Template PJE Aggregate" e definimos a macro {$SERVER_GROUP} com o nome do Host Group correspondente. Por exemplo, criamos o host "PJE 1grau", e definimos a macro {$SERVER_GROUP} = "PJE JBoss 1grau". Nesse exemplo, nos gráficos do host "PJE 1grau" aparecerão as informações somadas de todos os JBoss de 1grau.

Também em anexo no arquivo "PJE Aggregate.xml", está o export com esses hosts criados já ligados ao template e com as macros definidas. Basta apenas criar os host groups correspondentes e adicionar os servidores JBoss a eles.

**2.5** TODO (O que falta alterar nos templates)

- Analisar os itens e incluir gatilhos, gráficos e screens relevantes
- Criar itens agregados (somando os valores de todos os JBoss) relevantes
- Separar em templates diferentes os monitoramentos específicos do PJE dos genéricos do JBoss
- Pesquisar uma forma do zabbix fazer LLD (low level discovery) p/ os itens do JMX (utilizar versão customizada do java gateway?)
- Incluir outros Servlets do PJE (foram incluídos apenas 2 - o ideal seria usar LLD, desta forma os Servlets seriam descobertos automaticamente e o item poderia ficar no template genérico do JBoss, servindo para qualquer aplicação)
- LLD para os datasources (JCA)
- Revisar itens, colocando as unidades (segundos, ms, Bytes, etc)

OBS: Para que os itens JMX que capturam informações do ultimo GC (LastGcInfo) do Template JMX Generic funcionassem, foi necessário fazer uma pequena alteração no código fonte do Java Gateway do Zabbix para suportar o tipo de dado TabularDataSupport.
Segue em anexo o arquivo zabbix-java-gateway-2.0.8.jar que deve ser copiado para a pasta /usr/sbin/zabbix_java/bin/ (substituindo o original).
Caso estejam usando outra versão que não seja a 2.0.8, abaixo está o diff com a modificação necessária para acrescentar o suporte ao TabularDataSupport:

diff zabbix-2.0.8/src/zabbix_java/src/com/zabbix/gateway/JMXItemChecker.java-orig zabbix-2.0.8/src/zabbix_java/src/com/zabbix/gateway/JMXItemChecker.java
237a238,267
>                 else if (dataObject instanceof TabularDataSupport)
>                 {
>                         logger.trace("'{}' contains tabular data", dataObject);
> 
>                         TabularDataSupport tabular = (TabularDataSupport)dataObject;
> 
>                         //logger.warn("tabular data type:'{}'", tabular.getTabularType());
> 
>                         String dataObjectName;
>                         String newFieldNames = "";
> 
>                         int sep = HelperFunctionChest.separatorIndex(fieldNames);
> 
>                         if (-1 != sep)
>                         {
>                                 dataObjectName = fieldNames.substring(0, sep);
>                                 newFieldNames = fieldNames.substring(sep + 1);
>                         }
>                         else
>                                 dataObjectName = fieldNames;
> 
>                         // unescape possible dots or backslashes that were escaped by user
>                         dataObjectName = HelperFunctionChest.unescapeUserInput(dataObjectName);
> 
>                         //logger.warn("dataObjectName: '{}'", dataObjectName);
>                         //logger.warn("tabular.get: '{}'", tabular.get(new Object[] {dataObjectName}).get("value"));
> 
>                         return getPrimitiveAttributeValue(tabular.get(new Object[] {dataObjectName}).get("value"), newFieldNames);
>                 }
> 