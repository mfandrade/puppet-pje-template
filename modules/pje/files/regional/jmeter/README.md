## Configuração para a execução dos cenários de teste do JMeter

## Instruções para execução dos cenários login_adv.jmx, login_dir.jmx, login_mag.jmx e login_ofi.jmx

**Versão do JMeter e execução local.**

- Acessar o git(git@git.pje.csjt.jus.br:infra/regional.git) e baixar a pasta regional/jmeter
- Baixar a versão 2.9 (http://archive.apache.org/dist/jmeter/binaries/apache-jmeter-2.9.zip)
- Descompactar e executar o arquivo <jmeter_home_directory>/bin/jmeter.bat (windows) ou <jmeter_home_directory>/bin/jmeter (linux)
- Acessar o menu: Arquivo --> Abrir e escolher o cenário (arquivo .jmx do diretório "regional/jmeter/cenarios" )
- Em "Plano de Teste" configurar o host, porta e contexto de acordo com o ambiente a ser testado.
- Em "Plano de Teste --> Grupo de Usuários --> Configuração dos dados CSV" no campo "Nome do arquivo" apontar para o arquivo .CSV(regional/jmeter/csv) que corresponde a massa de dados para o cenário escolhido.
- Acessar o menu: Executar --> Iniciar
**Observação** As massas de dados (*.csv) foram montadas com base no login e senha de usuários cadastrado em nosso ambiente de teste. Para o teste nos regionais é necessário alterar esta massa de teste, ou cadastrar os usuários dos arquivos *.csv no banco em que será realizado o teste.

**Execução remota**

- Acessar o git(git@git.pje.csjt.jus.br:infra/regional.git) e baixar a pasta regional/jmeter
- Baixar a versão 2.9 (http://archive.apache.org/dist/jmeter/binaries/apache-jmeter-2.9.zip)
- Descompactar e executar o arquivo <jmeter_home_directory>/bin/jmeter.bat (windows) ou <jmeter_home_directory>/bin/jmeter
- Acessar o menu: Arquivo --> Abrir e escolher o cenário (arquivo .jmx do diretório "regional/jmeter/cenarios" )
- Em "Plano de Teste" configurar o host, porta e contexto de acordo com o ambiente a ser testado.
- Em "Plano de Teste --> Grupo de Usuários --> Configuração dos dados CSV" no campo "Nome do arquivo" apontar para o arquivo .CSV da máquina que esta executando o cenário.
ex: /srv/jmeterData/advogado_GC.csv
- Editar o arquivo <jmeter_home_directory>/bin/jmeter.properties em remote_hosts inserir o Host Remoto que fará a execução do cenário por exemplo "remote_hosts=10.0.17.52"
- Acessar o Host Remoto (ex: 10.0.17.52) e inicializar o serviço do jmeter (ex: "/srv/jmeter/bin/jmeter-server")
- Acessar o menu: Executar --> Iniciar Remoto --> <Host Remoto> (ex: "10.0.17.52")

## Instruções para construção e execução do cenário protocolcar.jmx

**Construção do Cenário Protocolar Processo**
- Acessar o menu: "Arquivo --> Abrir" e escolher o cenário "protocolcar.jmx"
- Selecione e apague todas as requisições http conforme figura "exclusao_http.jpg" abaixo.

![ScreenShot](https://git.pje.csjt.jus.br/infra/regional/raw/master/jmeter/exclusao_http.jpg "exclusao_http.jpg")

- Inicie o proxy do jmeter, conforme figura "iniciar_proxy.jpg" abaixo.

![ScreenShot](https://git.pje.csjt.jus.br/infra/regional/raw/master/jmeter/iniciar_proxy.jpg "iniciar_proxy.jpg")

- Abra as configurações do browser que acessará o pje, e edite as configurações de proxy apontando para localhost e a porta definida no proxy do jmeter, exemplo 9090.
- Acesse o pje e realize as operações para protocolar um novo processo. A cada passo, na execução do cadastramento do novo processo, são gravadas novas requisições http no jmeter.
- Após finalizar o cadastro do processo, interrompa a execução do proxy do jmeter, conforme figura "interromper_proxy.jpg" abaixo.

![ScreenShot](https://git.pje.csjt.jus.br/infra/regional/raw/master/jmeter/interromper_proxy.jpg "interromper_proxy.jpg")

- Desabilite as requisições http "uploadPopup.seam" conforme figura "desabilitar_popup.jpg" abaixo e salve o caso de teste.

![ScreenShot](https://git.pje.csjt.jus.br/infra/regional/raw/master/jmeter/desabilitar_popup.jpg "desabilitar_popup.jpg")

- Baixar e executar o script seam-jmeter.sh passando como parametro o arquivo jmx. Ex: "sh seam-jmeter.sh protocolcar.jmx". Tal script realiza manutenções no arquivo jmx, pertinentes a execução do cenário de teste.

**Execução**
- Siga os mesmos passos da execução local ou remota dos demais cenários.
