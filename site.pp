node /^pje8-jb-(int|ext)-([a-z]).trt8.net$/ {

  $id = "${1}${2}"

  pje::profile { "${id}1":
    binding_to      => '10.8.14.253',
    jmxremote_port  => '10150',
    env             => $environment,
    ds_databasename => "pje_1grau_${environment}",
  }

  pje::profile { "${id}2":
    binding_to      => '10.8.14.254',
    jmxremote_port  => '10151',
    env             => $environment,
    ds_databasename => "pje_2grau_${environment}",
  }

}
