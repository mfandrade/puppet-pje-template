#notify { 'BOM DIA, FLOR DO DIA!': }

node /^pje8-jb-((int|ext)[a-z]).trt8.net$/ {

  include pje

  pje::profile { "${1}1":
    binding_ports  => 'ports-01',
    jmxremote_port => '9001',
  }

  #pje::profile { "${1}2":
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

