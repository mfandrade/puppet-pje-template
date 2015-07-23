node /^pje8-jb-((int|ext)[a-z]).trt8.net$/ {

  pje::profile { 'inta1':
    version         => '1.5.2.3',
    env             => 'bugfix',
    binding_to      => '0.0.0.0',
    jmxremote_port  => 9001,
    ds_databasename => 'pje_1grau_bugfix',
  }

}
