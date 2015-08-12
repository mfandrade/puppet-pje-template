# Class: pje
#
# Módulo para gerenciar instalações e atualizações do PJE.
#
# Esta classe é responsável por garantir os pré-requisitos necessários para
# execução do PJE no servidor de aplicação JBoss, além de disponibilizar o
# arquivo .war para ser implantado posteriormente pelos profiles (vide
# profile.pp)
#
#
# Parâmetros:
#
# [*$version*]
#   Versão do PJE a ser implantada.  Esta classe pode provisionar o arquivo
#   disponível como source na pasta `files` (o que economiza tempo e recursos
#   de rede) ou baixá-lo da rede interna, se o arquivo não estiver presente.
#
#
# Exemplo de uso:
#
#   Normalmente esta classe não deve ser utilizada diretamente.
#
#
# ------------------------------------------------------------------------------
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
class pje {

  class { 'pje::install':
    version => hiera('pje_version'),
  }

}
