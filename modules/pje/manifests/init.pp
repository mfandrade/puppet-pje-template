# == Class: pje
#
# Full description of class pje here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'pje':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class pje($version = undef) {

  include pje::params

  class {'jboss':
    version    => '5.1.1',
    jboss_home => $::pje::params::jboss_home,
  }

# $jboss_home      = '/srv/jboss'
# $db_server       = undef
# $db_name         = undef
# $username_pje    = 'pje'
# $password_pje    = 'pje'
# $minpoolsize_pje = 5
# $maxpoolsize_pje = 40
# $username_api    = 'api'
# $password_api    = 'api'
# $minpoolsize_api = 1
# $maxpoolsize_api = 10
# $username_gim    = 'gim'
# $password_gim    = 'gim'
# $minpoolsize_gim = 1
# $maxpoolsize_gim = 10
# $quartz          = false
# $mail_host       = 'correio2.trt8.jus.br'
# $mail_port       = 25
# $mail_username   = 'trt8push@trt8.jus.br'
# $mail_password   = 'tribunal'


# jboss class
# - tar - install_dir fixo
# - jboss_home = /srv/jboss
#  class { 'jboss':
#    version    => '5.1.1',
#    jboss_home => $::pje::params::jboss_home,
#  }

# profile define
# - grau (1|2)
# - binding_ipaddr <0.0.0.0>
# - binding_ports <ports-default>
# - jmx_port <9001>

# pje
# - version
# - environment (producao|homologacao|treinamento)
# 



#  pje::profile { 'pje1z':
#    profile_name    => "pje-1grau-default",
#    binding_ports   => "ports-default",
#    binding_ipaddr  => '10.8.17.222',
#    jmxremote_port  => 9001,
#    quartz          => false,
#    db_server       => '10.8.14.206',
#    db_name         => 'pje_1grau_producao',
#    username_pje    => 'pje',
#    password_pje    => 'PjEcSjT',
#    minpoolsize_pje => 5,
#    maxpoolsize_pje => 40,
#    username_api    => 'pje_usuario_servico_api',
#    password_api    => 'PjEcSjT',
#    minpoolsize_api => 1,
#    maxpoolsize_api => 20,
#    username_gim    => 'pje_usuario_servico_gim',
#    password_gim    => 'PjEcSjT',
#    minpoolsize_gim => 1,
#    maxpoolsize_gim => 20,
#  }


}
