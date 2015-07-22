# == Classe: pje::params
#
# Classe com valores-chave a serem utilizados pelo módulo.
#
# === Parâmetros
#
# Esta classe não tem parâmetros.
#
# === Variáveis
#
# As variáveis definidas nesta classe funcionam como parâmetros para a
# aplicação.  Cuidou-se de incluir aqui apenas os parâmetros que fazem sentido
# para todo o sistema.
#
# [*jboss_home*]
#   jboss_home
#
# [*runas_user*]
#   runas_user
#
# [*exec_quartz*]
#   exec_quartz
#
# [*ds_servername*]
#   ds_servername
#
# [*ds_portnumber*]
#   ds_portnumber
#
# [*ds_username_pje*]
#   ds_username_pje  
#   
# [*ds_password_pje*]
#   ds_password_pje
#
# [*ds_minpoolsize_pje*]
#   ds_minpoolsize_pje
#
# [*ds_maxpoolsize_pje*]
#   ds_maxpoolsize_pje
#
# [*ds_username_api*]
#   ds_username_api  
#   
# [*ds_password_api*]
#   ds_password_api
#
# [*ds_minpoolsize_api*]
#   ds_minpoolsize_api
#
# [*ds_maxpoolsize_api*]
#   ds_maxpoolsize_api
#
# [*ds_username_gim*]
#   ds_username_gim  
#   
# [*ds_password_gim*]
#   ds_password_gim
#
# [*ds_minpoolsize_gim*]
#   ds_minpoolsize_gim
#
# [*ds_maxpoolsize_gim*]
#   ds_maxpoolsize_gim
#
# [*mail_host*]
#   mail_host
#
# [*mail_port*]
#   mail_port
#
# [*mail_username*]
#   mail_username
#
# [*mail_password*]
#   mail_password
#
# [*jvm_heapsize*]
#   jvm_heapsize
#
# [*jvm_maxheapsize*]
#   jvm_maxheapsize
#
# [*jvm_permsize*]
#   jvm_permsize
#
# [*jvm_maxpermsize*]
#   jvm_maxpermsize
#
# === Exemplo
#
#  Nada de interessante :-P
#
#```
#   include pje::params
#```
#
# === Autor
#
# Marcelo F Andrade <contato@marceloandrade.info>
#
# === Copyleft
#
# Copyleft 2015 Marcelo F Andrade (vide arquivo LICENSE)
#
class pje::params {

  $jboss_home      = '/srv/jboss'
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
