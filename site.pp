node /^pje8-jb-(int|ext)-([a-z]).trt8.net$/ {

  $pje_version = '1.6.0'
  $environment = 'bugfix'

  class { 'pje': version => $pje_version, }

  pje::profile { "${1}${2}1":
    version         => $pje_version,
    binding_to      => '10.8.14.253',
    jmxremote_port  => '9001',
    env             => $environment',
    ds_databasename => "pje_1grau_${environment}",
  }

  pje::profile { "${1}${2}2":
    version         => $pje_version,
    binding_to      => '10.8.14.254',
    jmxremote_port  => '9002',
    env             => $environment,
    ds_databasename => "pje_2grau_${environment}",
  }

}
