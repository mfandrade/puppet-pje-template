# == Classe: pje::service
#
# Classe para manter o servidor de aplicação executando como serviço,
# por meio de novo script de inicialização usado para gerenciar os arquivos
# de inicialização padronizados no bin de cada instância do PJE.
#
# Para evitar dependência cíclica, os dados desta classe e da definição de
# instâncias do PJE vão depender dos parâmetros na classe pje::params.
#
# === Parâmetros
#
# Esta classe não tem parâmetros e pode ser usada apenas com `include
# pje::service`.
#
# === Variáveis
#
# [*undefined*]
#   TODO...
# 
# === Exemplo
#
#```
#   include pje::service
#```
#
# === Autor
#
# Marcelo F Andrade <contato@marceloandrade.info>
#
# === Copyleft
#
# Copyleft 2015 Marcelo F Andrade (vide arquivo LICENSE)
#
class pje::service {

  #service { 'pje':
  #  ensure     => running,
  #  enable     => true,
  #  hasstatus  => true,
  #  hasrestart => true,
  #  require    => Class['pje::install'],
  #}

  notify { 'XXXXXXXXXXXXXXXX PJE:SERVICE': }

}
