# Puppet Module for PJE

Template Puppet para criação de servidores de aplicação padronizados para o Processo Judicial Eletrônico.

## No que consiste?
Este projeto basicamente implementa o módulo `pje::profile` que executa o deploy do sistema Processo Judicial Eletrônico em um clique.

## Requisitos
- Virtualbox
- Vagrant
- Puppet

## tl;dr
Clone este projeto
```$ git clone https://github.com/mfandrade/puppet-module-pje
```

Suba a infraestrutura localmente para teste com
```
$ cd puppet-module-pje
$ vagrant up
```

## Explicando
O sistema irá provisionar uma infraestrutura básica de ao menos dois hosts e executará o deploy da aplicação nas instâncias de primeiro e segundo graus, de forma completamente automatizada.

Para testes locais, o deploy da infraestrutura é executado na própria máquina do usuário, subindo máquinas virtuais via Vagrant e Virtualbox.  Isso pode ser configurado no `Vagrantfile`.  Vale lembrar que isto não é necessário em ambiente de produção.  Nesse caso, a infraestrutura dos servidores já deve estar disponível e o deploy da aplicação será feito diretamente por meio do Puppet Agent devidamente configurado com `puppet apply`.

A parte de configuração da aplicação em si se encontra no arquivo `site.pp`:
```puppet
node /^pje8-jb-(int|ext)-?([a-z]).trt8.net$/ {

  $id = "${1}${2}"

  pje::profile { "${id}1":
    binding_to      => '10.8.14.253',
    jmxremote_port  => '10150',
    ds_databasename => "pje_1grau_${environment}",
  }

  pje::profile { "${id}2":
    binding_to      => '10.8.14.254',
    jmxremote_port  => '10151',
    ds_databasename => "pje_2grau_${environment}",
  }

}
```

A sintaxe deve ser bem intuitiva para os técnicos responsáveis:
- dois perfis para deploy da aplicação (correspondentes ao primeiro e segundo graus)
- cada perfil tem opções de configuração:
  - `binding_to`: IP do perfil
  - `jmxremote_port`: porta JMX a ser utilizada pelo perfil
  - ds_databasename: nome da base de dados para a qual o perfil aponta

Todas estas opções de configuração são opcionais, uma vez que o módulo possui valores default razoáveis para um deploy simplificado.
 
**OBS:** Este projeto foi desenvolvido para versões do PJE anteriores à 1.2.X, que utiliza arquitetura monolítica.

