# Puppet module to manage autofs
class autofs (
  $browse_mode                = 'NO',
  $timeout                    = '600',
  $negative_timeout           = '60',
  $mount_wait                 = '-1',
  $umount_wait                = '12',
  $mount_nfs_default_protocol = '4',
  $append_options             = 'yes',
  $logging                    = 'none',
  $maps                       = undef,
  $maps_hiera_merge           = false,
  $autofs_package             = 'DEFAULT',
  $autofs_sysconfig           = 'DEFAULT',
  $autofs_service             = 'DEFAULT',
  $autofs_auto_master         = 'DEFAULT',
  $use_nis_maps               = true,
  $nis_master_name            = 'auto.master',
) {

  include ::autofs::params

  if $autofs_package == 'DEFAULT' {
    $autofs_package_real = $autofs::params::package
  } else {
    $autofs_package_real = $autofs_package
  }
  if $autofs_service == 'DEFAULT' {
    $autofs_service_real = $autofs::params::service
  } else {
    $autofs_service_real = $autofs_service
  }
  if $autofs_sysconfig == 'DEFAULT' {
    $autofs_sysconfig_real = $autofs::params::sysconfig
  } else {
    $autofs_sysconfig_real = $autofs_sysconfig
  }
  if $autofs_auto_master == 'DEFAULT' {
    $autofs_auto_master_real = $autofs::params::auto_master
  } else {
    $autofs_auto_master_real = $autofs_auto_master
  }

  if is_string($use_nis_maps) {
    $use_nis_maps_real = str2bool($use_nis_maps)
  } else {
    $use_nis_maps_real = $use_nis_maps
  }
  validate_bool($use_nis_maps_real)

  validate_string($nis_master_name)

  if is_string($maps_hiera_merge) {
    $maps_hiera_merge_real = str2bool($maps_hiera_merge)
  } else {
    $maps_hiera_merge_real = $maps_hiera_merge
  }
  validate_bool($maps_hiera_merge_real)

  if $maps_hiera_merge_real == true {
    $maps_real = hiera_hash('autofs::maps')
  } else {
    $maps_real = $maps
  }

  package { 'autofs':
    ensure => installed,
    name   => $autofs_package_real,
  }

  file { 'autofs_sysconfig':
    ensure  => file,
    path    => $autofs_sysconfig_real,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('autofs/autofs.erb'),
    require => Package['autofs'],
  }

  file { 'auto.master':
    ensure  => file,
    path    => $autofs_auto_master_real,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('autofs/master.erb'),
    require => Package['autofs'],
  }

  if $maps_real != undef {
    create_resources('autofs::map', $maps_real)
  }

  service { 'autofs':
    ensure    => running,
    name      => $autofs_service_real,
    enable    => true,
    require   => Package['autofs'],
    subscribe => [ File['autofs_sysconfig'], File['auto.master'], ],
  }

}
