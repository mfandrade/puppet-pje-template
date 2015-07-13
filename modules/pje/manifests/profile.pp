class pje::profile($jboss_home = "/srv/jboss", $base_profile = "default", $profile_name = "pje-1grau-default") {
  
  file {"$jboss_home/server/$profile_name":
    ensure  => present,
    source  => "$jboss_home/server/$base_profile",
    recurse => true,
  }

}
