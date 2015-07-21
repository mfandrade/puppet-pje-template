class pje::params {
  $jboss_home         = '/srv/jboss'
  $runas_user         = 'jboss' # TODO vide módulo jboss
  $exec_quartz        = false
  #$binding_to         = undef
  #$jmxremote_port     = undef
  $ds_servername      = '10.8.14.211'
  $ds_portnumber      = 5432
  #$ds_databasename    = undef
  $ds_username_pje    = 'pje'
  $ds_password_pje    = 'PjEcSjT'
  $ds_minpoolsize_pje = 5
  $ds_maxpoolsize_pje = 40
  $ds_username_api    = 'pje_usuario_servico_api'
  $ds_password_api    = 'PjEcSjT'
  $ds_minpoolsize_api = 1
  $ds_maxpoolsize_api = 10
  $ds_username_gim    = 'pje_usuario_servico_gim'
  $ds_password_gim    = 'PjEcSjT'
  $ds_minpoolsize_gim = 1
  $ds_maxpoolsize_gim = 10
  $mail_host          = 'correio2.trt8.jus.br'
  $mail_port          = 25
  $mail_username      = 'trt8push@trt8.jus.br'
  $mail_password      = 'tribunal'
  $jvm_heapsize       = '16m'
  $jvm_maxheapsize    = '2g'
  $jvm_permsize       = '128m'
  $jvm_maxpermsize    = '512m'

}
