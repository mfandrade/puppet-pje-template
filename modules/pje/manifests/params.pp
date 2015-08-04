# Copyright 2015 Marcelo F Andrade
#
# Marcelo F Andrade can be contacted at http://marceloandrade.info
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ----------------------------------------------------------------------------
# = Classe: pje::params
#
# Classe com valores-chave a serem utilizados pelo módulo.
#
# == Parâmetros
#
# Esta classe não tem parâmetros.
#
# == Variáveis
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
# [*jmx_credentials*]
#   jmx_credentials
#
# == Exemplo de uso
#
#  Nada de interessante :-P
#
#```
#   include pje::params
#```
# ----------------------------------------------------------------------------
class pje::params {  # TODO: migrar as variáveis para o hiera

  $jboss_home         = '/srv/jboss'
  $runas_user         = 'jboss' # vide módulo jboss
  $exec_quartz        = false
  $pje_version        = '1.6.0'
  $ds_servername      = '10.8.14.206'
  $ds_portnumber      = 5432
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
  $jmx_credentials    = 'admin=pje@cluster'

}
