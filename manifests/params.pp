# Default parameters for different osfamilies
class autofs::params {

  case $::osfamily {
    'RedHat': {
      $package = 'autofs'
      $service = 'autofs'
      $sysconfig = '/etc/sysconfig/autofs'
      $auto_master = '/etc/auto.master'
    }
    'Suse': {
      $package = 'autofs'
      $service = 'autofs'
      $sysconfig = '/etc/sysconfig/autofs'
      $auto_master = '/etc/auto.master'
    }
    'Debian': {
      $package = 'autofs'
      $service = 'autofs'
      $sysconfig = '/etc/default/autofs'
      $auto_master = '/etc/auto.master'
    }
    default: {
      fail("Operating system family ${::osfamily} is not supported")
    }
  }

}
