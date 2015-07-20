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

  file { 'aplicacaojt.keystore':
    path    => '/usr/java/default/jre/lib/security/aplicacaojt.keystore',
    ensure  => present,
    source  => 'puppet:///modules/pje/aplicacaojt.keystore',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['jboss'],
  }
  file { 'drive-postgresql':
    ensure  => present,
    path    => "$::pje::params::jboss_home/common/lib/postgresql-9.3-1103.jdbc4.jar",
    source  => 'puppet:///modules/pje/postgresql-9.3-1103.jdbc4.jar',
    owner   => 'root',
    group   => 'root',
    require => Class['jboss'],
  }

}
