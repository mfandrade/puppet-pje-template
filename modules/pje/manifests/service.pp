class pje::service {

  service { 'pje1grau':
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    hasrestart => true,
    require    => Class['pje::profile'],
  }

}
