node /^pje8-jb-(int|ext)-([a-z]).trt8.net$/ {

  include pje::params

  $maq = "${1}${2}"

  /*
  file { '/etc/default/jboss-pje':
    ensure => present,
    source => "puppet:///modules/pje/jboss-pje.${maq}",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  */

  pje::profile { "${maq}1":
    version         => $::pje::params::pje_version,
    binding_to      => '10.8.14.253',
    jmxremote_port  => '10150',
    env             => $environment,
    ds_databasename => "pje_1grau_${environment}",
  }

  pje::profile { "${maq}2":
    version         => $::pje::params::pje_version,
    binding_to      => '10.8.14.254',
    jmxremote_port  => '10151',
    env             => $environment,
    ds_databasename => "pje_2grau_${environment}",
  }

}
