# == Class: jboss
#
# Classe para simples instalação do servidor de aplicação JBoss.
# Esta classe no momento não gerencia muita coisa neste servidor
# além da definição do diretório JBOSS_HOME.
#
# Coisas como scripts de inicialização e parametrização em geral
# possivelmente será feita quando necessárias pelo uso das aplicações
# implantadas neste servidor.
# 
# === Parâmetros
#
# Os únicos parâmetros no momento são:
#
# [*version*]
#   Parâmetro não utilizado no momento.  Existe para ser definido com
#   caráter informativo.  Apenas a versão 5.1.1 EAP do JBoss é atualmente
#   suportada.
#
# [*jboss_home*]
#   Local onde o servidor de aplicação ficará acessível.  Por padrão,
#   o diretório de instalação tenta obedecer ao FHS, de forma que este
#   parâmetro representará um link simbólico para o local efetivo
#   dentro do diretório de instalação.
#
# Com o tempo, o parâmetro [version] pode definir qual versão do JBoss
# a ser instalada --talvez com download da rede, dificultada no momento
# devido à versão Enterprise Application Platform só estar disponível em
# área restrita do site da RedHat.
#
# === Variáveis
#
# Apenas a título informativo e para melhor entendimento do funcionamento
# deste módulo, tem-se que o mesmo faz uso internamente das seguintes
# variáveis:
#
# [*$::osfamily*]
#   Na verdade, um fato.  Nesta versão atual, este módulo suporta apenas 
#   hosts baseados em RPM, que é o formato de distribuição do Java escolhido.
#
# [*$accept*] e [*$url*]
#   Este módulo jboss vai depender do Java JDK para funcionar.  Foi definida
#   utilização da distribuição Java da Oracle em formato RPM.  Estas variáveis
#   são utilizadas para download do Java JDK via script.  No futuro, outras
#   versões e arquiteturas serão suportadas além da JDK 6u45 e i586,
#   respectivamente.
#
# [*$jboss_zip*]
#   O nome do arquivo zip do JBoss EAP já baixado e disponbilizado.
#   (TODO: Há que se verificar questões legais de se distribuir este arquivo).
#
# [*extracted_dir*]
#   Nome da pasta gerada quando se descompacta o [$jboss_zip].
#
# [*$destination_dir*]
#   Diretório onde o arquivo será descompactado.  Leia informações sobre o
#   parâmetro [*$jboss_home*].
#
# [*$install_dir*]
#   Caminho completo do servidor de aplicação extraído do arquivo zip, usando
#   [*$destination_dir*] e [*$extracted_dir*].
#
# === Exemplos
#
#  class { 'jboss':
#    version    => '5.1.1',
#    jboss_home => '/srv/jboss',
#  }
#
# === Autor
#
# Marcelo F Andrade <contato@marceloandrade.info>
#
# === Copyleft
#
# Copyleft 2015 Marcelo F Andrade.  Consulte o arquivo [LICENSE].
#
class jboss ($version, $jboss_home) {

  if $::osfamily != 'RedHat' {
    fail("Only supported by rpm-based Linux distributions (current: ${::osfamily})")

  } else {

    if $::architecture =~ /^i.86$/ {
      $url = 'http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-i586-rpm.bin'

    } elsif $::architecture == 'x86_64' {
      $url = 'http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-x64-rpm.bin'

    } else {
      fail("Only supported by i586 and x86_64 architectures (current: ${::architecture})")
    }
  
    $accept_header = 'Cookie: oraclelicense=accept-securebackup-cookie'
    $wget_options  = "-c --no-check-certificate --no-cookies --header '${accept_header}'"
    exec { 'download-install-java6':
      command => "wget ${wget_options} ${url} -O jdk6.bin && /bin/bash jdk6.bin",
      cwd     => '/tmp',
      timeout => 0,
      unless  => "rpm -q jdk-1.6.0_45",
      path    => '/usr/bin:/bin',
      before  => Exec['extract-jboss511']
    }

    $extracted_dir   = 'jboss-eap-5.1'
    $destination_dir = '/opt/rh'
    $install_dir     = "${destination_dir}/${extracted_dir}"
    package { 'unzip':
      ensure        => present,
      allow_virtual => false,
    }
    file { "${destination_dir}":
      ensure => directory,
    }
    file { "/tmp/jboss511.zip":
      ensure => present,
      source => 'puppet:///modules/jboss/jboss-eap-5.1.1.zip',
      # FIXME: ^o arquivo deve existir e, por favor, ponha uma variável aqui no name
    }
    exec { 'extract-jboss511':
      command => "unzip -uo /tmp/jboss511.zip -d ${destination_dir}",
      onlyif  => "test \\! -x ${install_dir}/jboss-as/bin/run.sh -a -f /tmp/jboss511.zip",
      require => [Package['unzip'], File["${destination_dir}"]],
      #require => [File["/tmp/jboss511.zip"], Package['unzip'], File["${destination_dir}"]],
      path    => '/usr/bin',
    }

    group { 'jboss':
      ensure => present,
      gid    => 501,
    }
    user { 'jboss':
      ensure  => present,
      gid     => 501,
      uid     => 501,
      home    => "${jboss_home}",
      require => Group['jboss'],
    }
    file { "${install_dir}":
      recurse => true,
      require => [Exec['extract-jboss511'], User['jboss']],
      #notify  => Exec['fix-perms'],
    }

    file { "${jboss_home}":
      ensure  => link,
      target  => "${install_dir}/jboss-as",
      require => Exec['extract-jboss511'],
    }
    #exec { 'fix-perms':
    #  command => "chown -R jboss.jboss ${install_dir}",
    #  onlyif  => "find ${install_dir} \\! -user jboss &>/dev/null",
    #  path    => '/bin:/usr/bin',
    #  require => User['jboss'],
    #}
  }

}
