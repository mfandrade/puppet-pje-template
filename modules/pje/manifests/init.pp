class pje($version) {

  class { 'pje::install':
    version => $version,
  }

}
