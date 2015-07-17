define pje::profile ( #namevar = jvmroute:
  $binding_ipaddr = '0.0.0.0',
  $binding_ports  = 'ports-default',
  $jmxremote_port = undef,
  $quartz         = false

) {

  $jvmroute = $name

  if $jvmroute =~ /^pje([1|2])([A-M])x?$/ {

    $grau         = "$1"
    $profile_name = "pje-${grau}grau-default"
    $profile_dir  = "$::pje::params::jboss_home/server/$profile_name"

  } else {

    fail("pje::profile <namevar> invalid for jvmRoute")

  }

  include pje::params

  file { "$profile_name":
    path    => "$::pje::params::jboss_home/server/$profile_name",
    ensure  => present,
    source  => 'puppet:///modules/pje/pje-xgrau-default',
    recurse => true,
  }

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

  file { "$profile_name.sh":
    ensure  => present,
    path    => "$::pje::params::jboss_home/bin/$profile_name.sh",
    content => template('pje/pje-xgrau-default.sh'),
    owner   => 'root',
    group   => 'jboss',
    mode    => '0750',
  }
  file{ "/etc/init.d/pje${grau}grau":
    ensure  => link,
    target  => "$::pje::params::jboss_home/bin/$profile_name.sh",
    require => File["$profile_name.sh"],
  }

}
