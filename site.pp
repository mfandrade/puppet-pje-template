node /^pje8-jb-(int|ext)-([a-z]).trt8.net$/ {

  $environment = 'bugfix'

  pje::profile { "${1}${2}1":
    version         => hiera('pje_version'),
    binding_to      => '10.8.14.253',
    jmxremote_port  => '9001',
    env             => $environment,
    ds_databasename => "pje_1grau_${environment}",
  }

  pje::profile { "${1}${2}2":
    version         => hiera('pje_version'),
    binding_to      => '10.8.14.254',
    jmxremote_port  => '9002',
    env             => $environment,
    ds_databasename => "pje_2grau_${environment}",
  }

}
