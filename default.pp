node /^pje8-jb-((int|ext)[a-z]).trt8.net$/ {

  include pje

  pje::profile { "${1}1":
    binding_to         => 'ports-default',
    jmxremote_port     => 9001,
    exec_quartz        => false,
    ds_databasename    => 'pje_1grau_bugfix',
    #ds_minpoolsize_pje => 20,
    #ds_maxpoolsize_pje => 100,
    #jvm_heapsize       => '16m',
    #jvm_maxheapsize    => '2g',
    #jvm_permsize       => '32m',
    #jvm_maxpermsize    => '512m',
  }

  ->
  service { 'pje1grau': # TODO: mover para o profile
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    hasrestart => true,
}


# pje
# - version
# - environment (producao|homologacao|treinamento)
# 

}
