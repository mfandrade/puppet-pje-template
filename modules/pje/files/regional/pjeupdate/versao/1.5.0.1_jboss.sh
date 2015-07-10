#!/bin/bash
# Nome: 1.5.0_jboss.sh
# Descricão: Excutar as inclusoes de novos arquivos -ds.xml. Script
#    executado automaticamente pelo instalador.
#    ./1.5.0_jboss.sh $DIR_DEPLOY1 $DIR_DEPLOY2
# Responsavel: SITEC - TST

### Variaveis ###
PATH1="$1"
PATH2="$2"
DATA_HORA=$(date +%Y%m%d-%H%M%S)

function modifica_ds()
{
	PJEds="$1/PJE-ds.xml"
	APIds="$1/API-ds.xml"
	GIMds="$1/GIM-ds.xml"
	
	# Realiza backups caso ja exista arquivos
	[ -e $APIds ] && mv $APIds "$APIds.backup.$DATA_HORA"
	[ -e $GIMds ] && mv $GIMds "$GIMds.backup.$DATA_HORA"

	echo "Capturando informacoes do PJE-ds..."
	ServerName=$(grep "<xa-datasource-property name=\"ServerName\">" $PJEds | head -n1)
	PortNumber=$(grep "<xa-datasource-property name=\"PortNumber\">" $PJEds | head -n1)
	DatabaseName=$(grep "<xa-datasource-property name=\"DatabaseName\">" $PJEds | head -n1)
	username=$(grep "<user-name>" $PJEds | head -n1)
	password=$(grep "<password>" $PJEds | head -n1)
	
	## ---------- API-ds.xml ---------- ## 
	
	echo "Adicionando arquivo $APIds..."

	cat << EOF >> $APIds 
<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE datasources
    PUBLIC "-//JBoss//DTD JBOSS JCA Config 1.5//EN"
    "http://www.jboss.org/j2ee/dtd/jboss-ds_1_5.dtd">

<datasources>

   <xa-datasource>
    <jndi-name>PJE_API_DS</jndi-name>

    <xa-datasource-class>org.postgresql.xa.PGXADataSource</xa-datasource-class>
$ServerName
$PortNumber
$DatabaseName
$username
$password

    <min-pool-size>5</min-pool-size>
    <max-pool-size>20</max-pool-size>

    <!-- disable transaction interleaving -->
    <track-connection-by-tx />

    <!-- corresponding type-mapping in conf/standardjbosscmp-jdbc.xml -->
    <metadata>
      <type-mapping>PostgreSQL 8.0</type-mapping>
    </metadata>
  </xa-datasource>

   <xa-datasource>
    <jndi-name>PJE_API_BASE_REPLICADA_DS</jndi-name>

    <xa-datasource-class>org.postgresql.xa.PGXADataSource</xa-datasource-class>
$ServerName
$PortNumber
$DatabaseName
$username
$password

    <min-pool-size>5</min-pool-size>
    <max-pool-size>20</max-pool-size>
    
      <!-- disable transaction interleaving -->
    <track-connection-by-tx />

    <!-- corresponding type-mapping in conf/standardjbosscmp-jdbc.xml -->
    <metadata>
      <type-mapping>PostgreSQL 8.0</type-mapping>
    </metadata>
  </xa-datasource>

</datasources>
EOF

	## ---------- GIM-ds.xml ---------- ## 

	echo "Adicionando arquivo $GIMds..."

	cat << EOF >> $GIMds
<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE datasources
    PUBLIC "-//JBoss//DTD JBOSS JCA Config 1.5//EN"
    "http://www.jboss.org/j2ee/dtd/jboss-ds_1_5.dtd">

<datasources>

  <xa-datasource>
    <jndi-name>PJE_MODULO_GIM_DS</jndi-name>
    <xa-datasource-class>org.postgresql.xa.PGXADataSource</xa-datasource-class>
$ServerName
$PortNumber
$DatabaseName
$username
$password
    <!-- disable transaction interleaving -->
    <track-connection-by-tx />
    <!-- corresponding type-mapping in conf/standardjbosscmp-jdbc.xml -->
    <metadata>
      <type-mapping>PostgreSQL 8.0</type-mapping>
    </metadata>
  </xa-datasource>

</datasources>
EOF
	
}

### Main ###

echo -e "\n## Iniciando as atualizações da versão $VERSAO"
for path in $*
do
  modifica_ds $path
done
