node /^pje8-jb-((int|ext)[a-z]).trt8.net$/ {

  pje::profile { 'inta1':
    binding_to      => '0.0.0.0',
    jmxremote_port  => 9001,
    exec_quartz     => false,
    ds_databasename => 'pje_1grau_bugfix',
  }

}
