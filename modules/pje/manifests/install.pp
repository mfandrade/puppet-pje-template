# == Classe: pje::install
#
# Classe para gerenciar os requisitos básicos para se executar o PJE.  Neste
# momento, a saber, o servidor de aplicação JBoss (vide módulo específico) e os
# arquivos necessários: keystore, driver do postgresql e init script.
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
#
# [*initscript_name*]
#   Idem para a variável jboss_home.
#
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
class pje::install($version) {

  include pje::params

  $jboss_home = $::pje::params::jboss_home
  class { 'jboss':
    version    => '5.1.1',
    jboss_home => $jboss_home,
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

  file { 'drive-postgresql':
    ensure  => present,
    path    => "${jboss_home}/common/lib/postgresql-9.3-1103.jdbc4.jar",
    source  => 'puppet:///modules/pje/postgresql-9.3-1103.jdbc4.jar',
    require => Class['jboss'], # por causa do jboss_home, obviamente
  }

  file { "/etc/default/jboss-pje":
    ensure  => present,
    source  => 'puppet:///modules/pje/jboss-pje',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $war_name = "pje-jt-${version}.war"
  $url      = "http://portal.pje.redejt/nexus/content/repositories/releases/br/jus/csjt/pje/pje-jt/${version}/${war_name}"
  file { "/tmp/${war_name}":
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    source  => ["puppet:///modules/pje/${war_name}", 'file:///dev/null'],
  }
  exec { 'download-war':
    command => "wget -c '${url}'",
    timeout => '1200',
    unless  => "test -f ${war_name} && unzip -tqq ${war_name}",
    cwd     => '/tmp',
    path    => '/usr/bin',
    require => [Package['unzip'], File["/tmp/${war_name}"]],
  }

}
