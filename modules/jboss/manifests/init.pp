# == Class: jboss
#
# Full description of class jboss here.
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
#  class { 'jboss':
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
class jboss (
  $jboss_home = '/srv/jboss',
) {

  if $::osfamily != 'RedHat' {
    fail('Only supported by rpm-based Linux distributions')
  } else {

    $accept = 'Cookie: oraclelicense=accept-securebackup-cookie'
    $url    = 'http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-i586-rpm.bin'
  
    exec { 'download-install-java6':
      command => "/usr/bin/wget -c --no-check-certificate --no-cookies --header $accept $url -O- | /bin/bash",
      unless  => "/bin/rpm -q jdk-1.6.0_45",
    }

    $jboss_zip     = '/vagrant/modules/jboss/files/jboss-eap-5.1.1.zip',
    $extracted_dir = 'jboss-eap-5.1'
    $destation_dir = '/opt/rh'
    $install_dir   = "$destination_dir/$extracted_dir"

    package { 'unzip':
      ensure        => present,
      allow_virtual => false,
    }

    file { "$destination_dir":
      ensure => directory,
    }

    exec { 'extract-jboss511':
      command => "/usr/bin/unzip $jboss_zip -d $destination_dir",
      onlyif  => "/usr/bin/test -f $jboss_zip",
      require => [Exec['download-install-java6'], Package['unzip'], File["$destination_dir"]],
    }

    file { "$jboss_home":
      ensure  => link,
      target  => "$install_dir/jboss-as",
      require => Exec['extract-jboss511'],
    }
  }

}
