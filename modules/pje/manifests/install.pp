# == Classe: pje::install
#
# Classe para gerenciar os requisitos básicos para se executar o PJE.  Neste
# momento, a saber, o servidor de aplicação JBoss (vide módulo específico) e os
# arquivos necessários: keystore e driver do postgresql.
#
# === Parâmetros
#
# Esta classe não tem parâmetros e pode ser usada apenas com `include
# pje::install`.  Os valores de que ela precisa estão definidas na classe
# pje::params.
#
# === Variáveis
#
# [*jboss_home*]
#   Variável definida com o valor do parâmetro correspondente para reduzir
#   tamanho da linha e evitar alerta do `puppet-lint`.

# === Exemplo
#
#```
#   include pje::install
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
class pje::install {

  class { 'jboss':
    version    => '5.1.1',
    jboss_home => $::pje::params::jboss_home,
  }

  file { 'aplicacaojt.keystore':
    ensure  => present,
    path    => '/usr/java/default/jre/lib/security/aplicacaojt.keystore',
    source  => 'puppet:///modules/pje/aplicacaojt.keystore',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['jboss'], # por causa do java
  }

  $jboss_home = $::pje::params::jboss_home
  file { 'drive-postgresql':
    ensure  => present,
    path    => "${jboss_home}/common/lib/postgresql-9.3-1103.jdbc4.jar",
    source  => 'puppet:///modules/pje/postgresql-9.3-1103.jdbc4.jar',
    owner   => 'root',
    group   => 'root',
    require => Class['jboss'], # por causa do jboss_home, obviamente
  }

}