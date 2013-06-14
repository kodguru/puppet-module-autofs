class autofs::params {

  case $::osfamily {
    'redhat': {
      $package = 'autofs'
      $service = 'autofs'
      $sysconfig = '/etc/sysconfig/autofs'
      $auto_master = '/etc/auto.master'
    }
    'suse': {
      $package = 'autofs'
      $service = 'autofs'
      $sysconfig = '/etc/sysconfig/autofs'
      $auto_master = '/etc/auto.master'
    }
    'debian': {
      $package = 'autofs'
      $service = 'autofs'
      $sysconfig = '/etc/default/autofs'
      $auto_master = '/etc/auto.master'
    }
  }

}
