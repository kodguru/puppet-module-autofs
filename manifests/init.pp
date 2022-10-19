# @summary Manage autofs
#
# @param browse_mode
#   Set this to `YES` if you want your mounts to be browseable.
#
# @param timeout
#   Default mount timeout.
#
# @param negative_timeout
#   Default negative timeout for failed mount attempts.
#
# @param mount_wait
#   Time to wait for a response from mount.
#
# @param umount_wait
#   Time to wait for a response from umount.
#
# @param mount_nfs_default_protocol
#   Default protocol version used by mount.nfs.
#
# @param append_options
#   Specify whether options should be appended to global options or replacing them.
#
# @param logging
#   Set default log level `none`, `verbose` or `debug`.
#
# @param maps
#   Specify the maps managed. This value is sent to define `autofs::map`.
#
# @param autofs_package
#   Package name for autofs. Unset, this parameter will choose the appropriate default for the system.
#
# @param autofs_sysconfig
#   Absolute path for autofs sysconfig location. Unset, this parameter will choose the appropriate default for the system.
#
# @param autofs_service
#   Service name for autofs to manage.
#
# @param autofs_auto_master
#   Absolute path for autofs.master location. Unset, this parameter will choose the appropriate default for the system.
#
# @param use_nis_maps
#   If the module should load mount maps from NIS.
#
# @param use_dash_hosts_for_net
#   Set this to true makes autofs use `-hosts` for the /net mountpoint. Set to false to use `/etc/auto.net`.
#
# @param nis_master_name
#   The name of the NIS map containing the auto.master data.
#
# @param service_ensure
#   Value for the service ensure attribute. Valid values are `running` and `stopped`.
#
# @param service_enable
#   Value for the service enable attribute.
#
class autofs (
  Enum['YES', 'NO'] $browse_mode            = 'NO',
  Integer[0] $timeout                       = 600,
  Integer[0] $negative_timeout              = 60,
  Integer $mount_wait                       = -1,
  Integer[0] $umount_wait                   = 12,
  Integer[0] $mount_nfs_default_protocol    = 4,
  Enum['yes', 'no'] $append_options         = 'yes',
  Enum['none', 'verbose', 'debug'] $logging = 'none',
  Hash $maps                                = {},
  String[1] $autofs_package                 = 'autofs',
  Stdlib::Absolutepath $autofs_sysconfig    = '/etc/sysconfig/autofs',
  String[1] $autofs_service                 = 'autofs',
  Stdlib::Absolutepath $autofs_auto_master  = '/etc/auto.master',
  Boolean $use_nis_maps                     = true,
  Boolean $use_dash_hosts_for_net           = true,
  String[1] $nis_master_name                = 'auto.master',
  Stdlib::Ensure::Service $service_ensure   = 'running',
  Boolean $service_enable                   = true,
) {
  # functionality
  case $facts['os']['family'] {
    'RedHat', 'Suse', 'Debian': {}
    default: { fail("Operating system family ${facts['os']['family']} is not supported") }
  }

  package { 'autofs':
    ensure => installed,
    name   => $autofs_package,
  }

  file { 'autofs_sysconfig':
    ensure  => file,
    path    => $autofs_sysconfig,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('autofs/autofs_linux.erb'),
    require => Package['autofs'],
  }

  create_resources('autofs::map', $maps)

  service { 'autofs':
    ensure    => $service_ensure,
    name      => $autofs_service,
    enable    => $service_enable,
    require   => Package['autofs'],
    subscribe => [
      File['autofs_sysconfig'],
      Concat['auto.master'],
    ],
  }

  concat { 'auto.master':
    ensure  => present,
    path    => $autofs_auto_master,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['autofs'],
  }

  concat::fragment { 'auto.master_head':
    target  => 'auto.master',
    content => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n\n",
    order   => '01',
  }

  case $use_dash_hosts_for_net {
    true:    { $net = '/net -hosts' }
    default: { $net = '/net /etc/auto.net --timeout=60' }
  }

  concat::fragment { 'auto.master_net':
    target  => 'auto.master',
    content => "${net}\n\n",
    order   => '02',
  }

  if $use_nis_maps {
    concat::fragment { 'auto.master_nis_master':
      target  => 'auto.master',
      content => "+${nis_master_name}\n",
      order   => '99',
    }
  }
}
