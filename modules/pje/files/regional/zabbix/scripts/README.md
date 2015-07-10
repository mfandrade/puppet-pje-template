# Scripts para ajudar a monitorar o ZABBIX
Todos esses scripts terão que estar no server do zabbix no diretóiro: **/usr/lib/zabbix/externalscripts**

Todos esses scripts terão que estar com permissão de execução e o dono (owner) ser o usuário **zabbix**
Script:
> chmod +x pje*

> chown zabbix. pje*

--- 

## 1. pjeMonitoramento.py

Responsável por realizar a consulta no serviço de monitoração do PJe. Esse serviço se encontra no caminho: .../primeirograu/seam/resource/rest/monitoracao/receita

Obs: É necessário configurar o **PROXY**. Abra o arquivo e edite a linha 28 e 29.
Treco de código que necessita ser trocado:
> self._proxies = proxies = {
	  "http": "http://proxy.xxx.xxx.xx:porta",
	  "https": "http://proxy.xxx.xxx.xx:porta",
	}

Exemplo de execução: **python pjeMonitoramento.py qualidade.pje.csjt.jus.br primeirograu oab**

Onde:
**qualidade.pje.csjt.jus.br** representa o ambiente.
**oab** representa o serviço. Os serviços possíveis são:  receita, oab, banco

---

## 2. pjeDisponibilidadeBDNT.py

Responsável por realizar a consulta no serviço do BNDT.

Exemplo de execução: **python pjeDisponibilidadeBDNT.py**

---

## 3. pjeDisponibilidadeOAB.py

Responsável por realizar a consulta no serviço da OAB.

Obs: É necessário configurar o **PROXY**. Abra o arquivo e edite a linha 62 e 63.
Treco de código que necessita ser trocado:
> self._proxies = proxies = {
	  "http": "http://proxy.xxx.xxx.xx:porta",
	  "https": "http://proxy.xxx.xxx.xx:porta",
	}

Exemplo de execução: **python pjeDisponibilidadeOAB.py**

---

## 4. pjeDisponibilidadeReceita.py

Responsável por realizar a consulta no serviço da Receita Federal.

Obs: É necessário configurar o **PROXY**. Abra o arquivo e edite a linha 59 e 60.
Treco de código que necessita ser trocado:
> self._proxies = proxies = {
	  "http": "http://proxy.xxx.xxx.xx:porta",
	  "https": "http://proxy.xxx.xxx.xx:porta",
	}

Exemplo de execução: **python pjeDisponibilidadeReceita.py**

---

## 5. pjeDisponibilidadeRegional.py

Responsável por realizar a consulta no serviço do PJe das regionais.

Obs: É necessário configurar o **PROXY**. Abra o arquivo e edite a linha 23 e 24.
Treco de código que necessita ser trocado:
> self._proxies = proxies = {
	  "http": "http://proxy.xxx.xxx.xx:porta",
	  "https": "http://proxy.xxx.xxx.xx:porta",
	}

Exemplo de execução: **python pjeDisponibilidadeRegional.py pje.trt3.jus.br primeirograu**

Onde: 
**pje.trt3.jus.br** representa o serviço do PJe da regional
**primeirograu** representa a instância

---

## 6. zapache

Responsável por fazer a consulta ao serviço do apache

---

## 7. pjeDisponibilidadeAmbienteInterno.py

Responsável por realizar a consulta no serviço do PJe nos ambientes interno.

Exemplo de execução: **python pjeDisponibilidadeAmbienteInterno.py avaliacao.pje.csjt.jus.br primeirograu**

Onde: 
**avaliacao.pje.csjt.jus.br** representa o serviço do PJe
**primeirograu** representa a instância