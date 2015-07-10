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
class pje {

  file { '/usr/java/default/jre/lib/security/aplicacaojt.keystore':
    ensure => present,
    source => 'puppet:///modules/pje/aplicacaojt.keystore',
  }

  file { '/srv/jboss/bin/pje-1grau-default.sh':
    ensure  => present,
    content => template('pje-xgrau-default.sh'),
  }

  $delete_from_default = [
    '/srv/jboss/server/pje-1grau-default/deploy/ROOT.war',
    '/srv/jboss/server/pje-1grau-default/deploy/admin-console.war',
    '/srv/jboss/server/pje-1grau-default/deploy/http-invoker.war',
    '/srv/jboss/server/pje-1grau-default/deploy/jms-ra.war',
    '/srv/jboss/server/pje-1grau-default/deploy/mail-ra.war',
    '/srv/jboss/server/pje-1grau-default/deploy/management',
    '/srv/jboss/server/pje-1grau-default/deploy/messaging',
    '/srv/jboss/server/pje-1grau-default/deploy/quartz-ra.rar',
    '/srv/jboss/server/pje-1grau-default/deploy/uuid-key-generator.sar',
    '/srv/jboss/server/pje-1grau-default/deploy/xnio-provider.jar',
    '/srv/jboss/server/pje-1grau-default/deploy/ejb2-container-jboss-beans.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/ejb2-timer-service.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/ejb3-connectors-jboss-beans.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/ejb3-container-jboss-beans.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/ejb3-interceptors-aop.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/ejb3-timerservice-jboss-beans.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/jsr88-service.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/mail-service.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/monitoring-service.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/properties-service.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/schedule-manager-service.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/scheduler-service.xml',
    '/srv/jboss/server/pje-1grau-default/deploy/sqlexception-service.xml'
  ]
  file { '/srv/jboss/server/pje-1grau-default':
    ensure  => present,
    source  => '/srv/jboss/server/default',
    recurse => true,
  }
  ->
  file { $delete_from_default:
    ensure  => absent,
    recurse => true,
    purge   => true,
  }
  ->
  file { '/srv/jboss/server/pje-2grau-default':
    ensure  => present,
    source  => '/srv/jboss/server/pje-1grau-default',
    recurse => true,
  }

  file { '/srv/jboss/server/pje-1grau-default/run.conf':
    ensure => present,
    source => template('run.conf.erb'),
  }
  file { '/srv/jboss/server/pje-1grau-default/deploy/PJE-ds.xml':
    ensure => present,
    source => template('PJE-ds.xml.erb'),
  }
  file { '/srv/jboss/server/pje-1grau-default/deploy/GIM-ds.xml':
    ensure => present,
    source => template('GIM-ds.xml.erb'),
  }
  file { '/srv/jboss/server/pje-1grau-default/deploy/API-ds.xml':
    ensure => present,
    source => template('API-ds.xml.erb'),
  }
  file { '/srv/jboss/server/pje-1grau-default/conf/jboss-log4j.xml':
    ensure => present,
    source => 'puppet:///modules/pje/jboss-log4j.xml',
  }
  file { '/srv/jboss/server/pje-1grau-default/deploy/transaction-jboss-beans.xml':
    ensure => present,
    source => 'puppet:///modules/pje/transaction-jboss-beans.xml',
  }
  file { '/srv/jboss/server/pje-1grau-default/deploy/jbossweb.sar/server.xml':
    ensure => present,
    source => 'puppet:///modules/pje/server.xml',
  }
  file { '/srv/jboss/server/pje-1grau-default/deploy/jca-jboss-beans.xml':
    ensure => present,
    source => 'puppet:///modules/pje/jca-jboss-beans.xml',
  }
  file { '/srv/jboss/server/pje-1grau-default/deployers/jbossws.deployer/META-INF/jboss-beans.xml':
    ensure => present,
    source => 'puppet:///modules/pje/jboss-beans.xml',
  }
  file { '/srv/jboss/server/pje-1grau-default/deploy/primeirograu.war/WEB-INF/web.xml':
    ensure => present,
    source => 'puppet:///modules/pje/web.xml',
  }
  file { '/srv/jboss/server/pje-1grau-default/deploy/primeirograu.war/WEB-INF/components.xml':
    ensure => present,
    source => 'puppet:///modules/pje/components.xml',
  }
}
