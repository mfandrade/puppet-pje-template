#notify { 'BOM DIA, FLOR DO DIA!': }

node /^pje8-jb-(int|ext)-[a-z].trt8.net$/ {
  #include pje

  notify { "DEPLOYANDO em uma máquina $1": }

  #pje::profile { 'pje1hx':
    #binding_ipaddr => '0.0.0.0',
  #  binding_ports  => 'ports-01',
  #  jmxremote_port => '9001',
    #quartz         => false
  #}

  #pje::profile { 'pje2hx':
  #  binding_ports  => 'ports-02',
  #  jmxremote_port => '9002',
  #}

  #ERROR
  #pje::profile { 'pje3a':
  #  binding_ports  => 'ports-03',
  #  jmxremote_port => '9002',
  #}
}


# pje
# - version
# - environment (producao|homologacao|treinamento)
# 

