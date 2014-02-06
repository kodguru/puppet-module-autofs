class autofs (
  $browse_mode = 'NO',
  $timeout = '600',
  $negative_timeout = '60',
  $mount_wait = '-1',
  $umount_wait = '12',
  $mount_nfs_default_protocol = '4',
  $append_options = 'yes',
  $logging = 'none',
  $maps = undef,
) {

  include autofs::params

  package { 'autofs':
    ensure => installed,
    name   => $autofs::params::package,
  }

  file { 'autofs_sysconfig':
    ensure  => file,
    path    => $autofs::params::sysconfig,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('autofs/autofs.erb'),
    require => Package['autofs'],
  }

  file { 'auto.master':
    ensure  => file,
    path    => $autofs::params::auto_master,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('autofs/master.erb'),
    require => Package['autofs'],
  }

  if $maps != undef {
    create_resources('autofs::map', $maps)
  }

  service { 'autofs':
    ensure    => running,
    name      => $autofs::params::service,
    enable    => true,
    subscribe => [ File['autofs_sysconfig'], File['auto.master'], ],
  }

}
