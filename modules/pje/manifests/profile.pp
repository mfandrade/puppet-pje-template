class pje::profile($jboss_home = "/srv/jboss", $base_profile = "default", $profile_name = "pje-1grau-default") {
  
  file { "$profile_name":
    path    => "$jboss_home/server/$profile_name",
    ensure  => present,
    source  => "$jboss_home/server/$base_profile",
    recurse => true,
  }

  $remove_from_deploy_folder = [
    "$jboss_home/server/$profile_name/deploy/ROOT.war",
    "$jboss_home/server/$profile_name/deploy/admin-console.war",
    "$jboss_home/server/$profile_name/deploy/http-invoker.sar",
    "$jboss_home/server/$profile_name/deploy/jms-ra.rar",
    "$jboss_home/server/$profile_name/deploy/mail-ra.rar",
    "$jboss_home/server/$profile_name/deploy/management",
    "$jboss_home/server/$profile_name/deploy/messaging",
    "$jboss_home/server/$profile_name/deploy/quartz-ra.rar",
    "$jboss_home/server/$profile_name/deploy/uuid-key-generator.sar",
    "$jboss_home/server/$profile_name/deploy/xnio-provider.jar",
    "$jboss_home/server/$profile_name/deploy/ejb2-container-jboss-beans.xml",
    "$jboss_home/server/$profile_name/deploy/ejb2-timer-service.xml",
    "$jboss_home/server/$profile_name/deploy/ejb3-connectors-jboss-beans.xml",
    "$jboss_home/server/$profile_name/deploy/ejb3-container-jboss-beans.xml",
    "$jboss_home/server/$profile_name/deploy/ejb3-interceptors-aop.xml",
    "$jboss_home/server/$profile_name/deploy/ejb3-timerservice-jboss-beans.xml",
    "$jboss_home/server/$profile_name/deploy/jsr88-service.xml",
    "$jboss_home/server/$profile_name/deploy/mail-service.xml",
    "$jboss_home/server/$profile_name/deploy/monitoring-service.xml",
    "$jboss_home/server/$profile_name/deploy/properties-service.xml",
    "$jboss_home/server/$profile_name/deploy/schedule-manager-service.xml",
    "$jboss_home/server/$profile_name/deploy/scheduler-service.xml",
    "$jboss_home/server/$profile_name/deploy/sqlexception-service.xml"
  ]

  file { $remove_from_deploy_folder:
    ensure  => absent,
    force   => true,
    require => File["$profile_name"],
  }

  $ds_servername    = '10.8.14.206'
  $ds_databasename  = 'pje_1grau_producao'
  $ds_base_username = 'pje_usuario_servico'
  $ds_password      = 'PjEcSjT'

  file { 'API-ds.xml':
    ensure  => present,
    path    => "$jboss_home/server/$profile_name/deploy/API-ds.xml",
    content => template('pje/API-ds.xml.erb'),
  }
  file { 'GIM-ds.xml':
    ensure  => present,
    path    => "$jboss_home/server/$profile_name/deploy/GIM-ds.xml",
    content => template('pje/GIM-ds.xml.erb'),
  }


}
