define pje::profile (
  $version,
  $env,
  $binding_to,
  $jmxremote_port,
  $ds_databasename,
  $ds_minpoolsize_pje = 5,
  $ds_maxpoolsize_pje = 40,
  $ds_minpoolsize_api = 1,
  $ds_maxpoolsize_api = 10,
  $ds_minpoolsize_gim = 1,
  $ds_maxpoolsize_gim = 10,
  $jvm_heapsize       = '16m',
  $jvm_maxheapsize    = '1536m',
  $jvm_permsize       = '64m',
  $jvm_maxpermsize    = '512m',
  $exec_quartz        = false,
) {

  include pje

# ------------------------------------------------------------------------
  $jvmroute = $name

  if $jvmroute =~ /^pje([12])([a-z])x?$/ { # EXEMPLO: pje1a, pje2bx
    $grau    = "$1"

  } elsif $jvmroute =~ /^(int|ext)[a-z]([12])$/ { # EXEMPLO: inta1, extb2
    $grau = "$2"

  } else {
    fail("PJE profile '$name' is an invalid jvmRoute pattern")
  }
  $profile_name = "pje-${grau}grau-default"
  $profile_dir  = "$::pje::params::jboss_home/server/$profile_name"

  if $ds_databasename == undef {
    $ds_databasename = "pje_${grau}grau_producao"
  }


# ------------------------------------------------------------------------
  if ($binding_to == 'ports-default') or ($binding_to =~ /^ports-0[1-3]$/) {
    $binding_ipaddr = '0.0.0.0'
    $binding_ports  = $binding_to

  } elsif ($binding_to =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}$/) {
    $binding_ipaddr = $binding_to
    $binding_ports  = 'ports-default'

  } else {
    fail('You need to specify an IP address or a default port set to bind to')
  }

# ------------------------------------------------------------------------
  include pje::params


  if $::pje::params::runas_user != undef {
    $jboss_user  = $::pje::params::runas_user
    $owner_group = $::pje::params::runas_user
  } else {
    $jboss_user  = 'RUNASIS' # para o script de inicialização
    $owner_group = 'root'
  }
  file { "$profile_name":
    path    => "$::pje::params::jboss_home/server/$profile_name",
    ensure  => present,
    source  => "file:///$::pje::params::jboss_home/server/default",
    recurse => true,
    require => Class['pje::install'],
  }
  file { "$profile_name.sh":
    ensure  => present,
    path    => "${::pje::params::jboss_home}/bin/$profile_name.sh",
    content => template('pje/pje-xgrau-default.sh'),
    owner   => $owner_group,
    group   => $owner_group,
    mode    => '0755',
  }
  #exec { "fix-perms-${profile_name}":
  #  command => "chown -R ${owner_group}.${owner_group} ${profile_name}",
  #  cwd     => "${::pje::params::jboss_home}/server",
  #  path    => '/bin',
  #}


  $remove_from_deploy_folder = [
    "$profile_dir/deploy/ROOT.war",
    "$profile_dir/deploy/admin-console.war",
    "$profile_dir/deploy/http-invoker.sar",
    "$profile_dir/deploy/jms-ra.rar",
    "$profile_dir/deploy/mail-ra.rar",
    "$profile_dir/deploy/management",
    "$profile_dir/deploy/messaging",
    "$profile_dir/deploy/quartz-ra.rar",
    "$profile_dir/deploy/uuid-key-generator.sar",
    "$profile_dir/deploy/xnio-provider.jar",
    "$profile_dir/deploy/ejb2-container-jboss-beans.xml",
    "$profile_dir/deploy/ejb2-timer-service.xml",
    "$profile_dir/deploy/ejb3-connectors-jboss-beans.xml",
    "$profile_dir/deploy/ejb3-container-jboss-beans.xml",
    "$profile_dir/deploy/ejb3-interceptors-aop.xml",
    "$profile_dir/deploy/ejb3-timerservice-jboss-beans.xml",
    "$profile_dir/deploy/jsr88-service.xml",
    "$profile_dir/deploy/mail-service.xml",
    "$profile_dir/deploy/monitoring-service.xml",
    "$profile_dir/deploy/properties-service.xml",
    "$profile_dir/deploy/schedule-manager-service.xml",
    "$profile_dir/deploy/scheduler-service.xml",
    "$profile_dir/deploy/sqlexception-service.xml",
    "$profile_dir/deployers/bsh.deployer",
    "$profile_dir/deployers/xnio.deployer",
    "$profile_dir/deployers/messaging-definitions-jboss-beans.xml"
  ]

  file { $remove_from_deploy_folder:
    ensure  => absent,
    force   => true,
    require => File["$profile_name"],
  }


  file { "$profile_dir/deploy/API-ds.xml":
    ensure  => present,
    content => template('pje/API-ds.xml.erb'),
  }
  file { "$profile_dir/deploy/GIM-ds.xml":
    ensure  => present,
    content => template('pje/GIM-ds.xml.erb'),
  }
  file { "$profile_dir/deploy/PJE-ds.xml":
    ensure  => present,
    content => template('pje/PJE-ds.xml.erb'),
  }

  file { "$profile_dir/run.conf":
    ensure  => present,
    content => template('pje/run.conf.erb'),
  }



  if $grau == '1' {
    $ordgrau = 'primeirograu'

  } elsif $grau == '2' {
    $ordgrau = 'segundograu'

  }
  if $env == 'producao' {
    $ctxpath = "${ordgrau}"

  } elsif $env =~ /^(homologacao|treinamento|bugfix)$/ {
    $ctxpath = "${ordgrau}_${env}"

  } else {
    fail("PJE environment '${env}' does not exist")
  }

  $war_file = "pje-jt-${::pje::params::pje_version}.war"
  $war_dir  = "${profile_dir}/deploy/${ctxpath}.war"
  exec { "deploy-pje-${grau}":
    command => "rm -rf ${war_dir}; unzip /tmp/${war_file} -d ${war_dir}",
    onlyif  => "test -f /tmp/${war_file}",
    path    => '/bin:/usr/bin',
    require => Class['pje::install'],
    notify  => Class['pje::service'],
  }

}
