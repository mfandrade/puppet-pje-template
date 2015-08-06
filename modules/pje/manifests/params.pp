# Class: pje::params
#
# Classe com valores-chave a serem utilizados pelo módulo.
#
#
# Parâmetros:
#
# Esta classe não tem parâmetros.
#
#
# Variáveis:
#
# As variáveis definidas nesta classe funcionam como parâmetros para a
# aplicação.  Cuidou-se de incluir aqui apenas os parâmetros que fazem sentido
# para todo o sistema.
#
# [*$jboss_home*]
#   Local onde deve residir o servidor de aplicação.  É o diretório para o qual
#   o caminho $JBOSS_HOME/bin/run.sh é válido.
#
# [*$runas_user*]
#   Usuário com o qual o servidor de aplicação será executado.
#
# [*$exec_quartz*]
#   Se o executor de tarefas interno deve rodar neste servidor de aplicação.
#
# [*$ds_servername*]
#   IP ou hostname do servidor de banco de dados PostgreSQL.
#
# [*$ds_portnumber*]
#   Porta do serviço do banco de dados PostgreSQL.
#
# [*$ds_username_pje*]
#   Usuário do datasource "pje".
#   
# [*$ds_password_pje*]
#   Senha do usuário do datasource "pje".
#
# [*$ds_minpoolsize_pje*]
#   Valor mínimo do pool de conexões do datasource "pje".
#
# [*$ds_maxpoolsize_pje*]
#   Valor máximo do pool de conexões do datasource "pje".
#
# [*$ds_username_api*]
#   Usuário do datasource "api". (decisões arquiteturais da equipe)
#   
# [*$ds_password_api*]
#   Senha do usuário do datasource "api". (decisões arquiteturais da equipe)
#
# [*$ds_minpoolsize_api*]
#   Valor mínimo do pool de conexões do datasource "api". (decisões arquiteturais da equipe)
#
# [*$ds_maxpoolsize_api*]
#   Valor máximo do pool de conexões do datasource "api". (decisões arquiteturais da equipe)
#
# [*$ds_username_gim*]
#   Senha do usuário do datasource "gim". (decisões arquiteturais da equipe)
#   
# [*$ds_password_gim*]
#   Senha do usuário do datasource "gim". (decisões arquiteturais da equipe)
#
# [*$ds_minpoolsize_gim*]
#   Valor mínimo do pool de conexões do datasource "gim". (decisões arquiteturais da equipe)
#
# [*$ds_maxpoolsize_gim*]
#   Valor máximo do pool de conexões do datasource "gim". (decisões arquiteturais da equipe)
#
# [*$mail_host*]
#   IP ou hostname do servidor SMTP.
#
# [*$mail_port*]
#   Porta do serviço SMTP.
#
# [*$mail_username*]
#   Usuário para autenticação no SMTP.
#
# [*$mail_password*]
#   Senha do usuário para autenticação no SMTP.
#
# [*$jvm_heapsize*]
#   Tamanho do heap da JVM. (Parâmetro -Xms)
#
# [*$jvm_maxheapsize*]
#   Tamanho máximo do heap da JVM. (Parâmetro -Xmx)
#
# [*$jvm_permsize*]
#   Tamanho do PermGem. (Parâmetro -XX:PermSize)
#
# [*$jvm_maxpermsize*]
#   Tamanho máximo do PermGem. (Parâmetro -XX:MaxPermSize)
#
# [*$jmx_credentials*]
#   Usuário e senha para autenticação JMX.
#
#
# Exemplo de uso:
#
# include pje::params
#
# ----------------------------------------------------------------------------
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
class pje::params {  # TODO: migrar as variáveis para o hiera

  $jboss_home         = '/srv/jboss'
  $runas_user         = 'jboss' # vide módulo jboss
  $exec_quartz        = false
  $ds_servername      = '10.8.14.211'
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
