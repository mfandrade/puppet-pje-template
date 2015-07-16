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
class pje($version = undef, $jboss_home = "/srv/jboss") {
  
  pje::profile { 'pje1z':
    profile_name    => "pje-1grau-default",
    binding_ports   => "ports-default",
    binding_ipaddr  => '10.8.17.222',
    jmxremote_port  => 9001,
    quartz          => false,
    db_server       => '10.8.14.206',
    db_name         => 'pje_1grau_producao',
    username_pje    => 'pje',
    password_pje    => 'PjEcSjT',
    minpoolsize_pje => 5,
    maxpoolsize_pje => 40,
    username_api    => 'pje_usuario_servico_api',
    password_api    => 'PjEcSjT',
    minpoolsize_api => 1,
    maxpoolsize_api => 20,
    username_gim    => 'pje_usuario_servico_gim',
    password_gim    => 'PjEcSjT',
    minpoolsize_gim => 1,
    maxpoolsize_gim => 20,
  }

  group { 'jboss':
    ensure => present,
    gid    => 501,
  }

  user { 'jboss':
    ensure  => present,
    gid     => 'jboss',
    shell   => '/bin/bash',
    home    => $jboss_home,
    require => Group['jboss'],
  }

}
