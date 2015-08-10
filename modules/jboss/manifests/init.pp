# Class: jboss
#
# Módulo para simples instalação do servidor de aplicação JBoss.
#
# Esta classe no momento não gerencia muita coisa neste servidor
# além da definição do diretório JBOSS_HOME.
# 
#
# Parâmetros:
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
# Com o tempo, o parâmetro `version` pode definir qual versão do JBoss
# a ser instalada --talvez com download da rede, dificultada no momento
# devido à versão Enterprise Application Platform só estar disponível em
# área restrita do site da RedHat.
#
#
# Variáveis:
#
# Apenas a título informativo e para melhor entendimento do funcionamento
# deste módulo, tem-se que o mesmo faz uso internamente das seguintes
# variáveis:
#
# [*$url*]
#   URL para download do binário RPM para instalação do Oracle Java 6u45.
#
# [*$accept_header*]
#   Cabeçalho com cookie necessário para download do Java na $url.
#
# [*$wget_options*]
#   Montagem das opções de download para uso no wget.
#
# [*$extracted_dir*]
#   Pasta resultante da descompactação do JBoss.  Depende da versão.
#
# [*$destination_dir*]
#   Diretório onde o JBoss será descompactado.
#
# [*$install_dir*]
#   Diretório onde se encontra o servidor de aplicação em si.
#
#
# Exemplo de uso:
#
#  class { 'jboss':
#    version    => '5.1.1',
#    jboss_home => '/srv/jboss',
#  }
#
# ----------------------------------------------------------------------------
# Copyright 2015 Marcelo F Andrade
#
# Marcelo F Andrade can be contacted at http://marceloandrade.info
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------
#
class jboss ($version, $jboss_home) {

  if $::osfamily != 'RedHat' {
    fail('Only supported by rpm-based Linux distributions')

  } else {

    $baseurl = 'http://download.oracle.com/otn-pub/java/jdk/'
    if $::architecture =~ /^i.86$/ {
      $url = "${baseurl}/6u45-b06/jdk-6u45-linux-i586-rpm.bin"

    } elsif $::architecture == 'x86_64' {
      $url = "${baseurl}/6u45-b06/jdk-6u45-linux-x64-rpm.bin"

    } else {
      fail('Only supported by i586 and x86_64 architectures')
    }
  
    $accept_header = 'Cookie: oraclelicense=accept-securebackup-cookie'
    $wget_options  = "-c --no-check-certificate --header '${accept_header}'"
    exec { 'download-install-java6':
      command => "wget ${wget_options} ${url} -O jdk6.bin; /bin/bash jdk6.bin",
      cwd     => '/tmp',
      timeout => 0,
      unless  => 'rpm -q jdk-1.6.0_45',
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
    file { $destination_dir:
      ensure => directory,
    }
    file { 'jb.zip':
      ensure => present,
      path   => '/tmp/jb511.zip',
      source => 'puppet:///modules/jboss/jboss-eap-5.1.1.zip',
      # FIXME: ^o arquivo deve existir e, por favor, ponha uma variável no name
    }
    exec { 'extract-jboss511':
      command => "unzip -uo /tmp/jb511.zip -d ${destination_dir}",
      onlyif  => "test \\! -x ${install_dir}/bin/run.sh -o \\! -d ${install_dir}/server/default",
      require => [Package['unzip'], File[$destination_dir], File['jb.zip']],
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
      home    => $jboss_home,
      require => Group['jboss'],
    }
    file { $install_dir:
      owner   => 'root',
      group   => 'root',
      require => Exec['extract-jboss511'],
    }

    file { $jboss_home:
      ensure  => link,
      owner   => 'jboss',
      group   => 'jboss',
      target  => "${install_dir}/jboss-as",
      require => [Exec['extract-jboss511'], User['jboss']],
    }
    exec { 'fix-perms':
      command => 'chown -R jboss.jboss .',
      onlyif  => 'find . \! -user jboss &>/dev/null',
      cwd     => $jboss_home,
      path    => '/bin:/usr/bin',
      require => [File[$jboss_home], User['jboss']],
    }
    file { 'docs':
      ensure  => absent,
      force   => true,
      path    => "${jboss_home}/docs",
      require => File[$jboss_home],
    }

  }
}
