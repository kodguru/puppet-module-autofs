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
# @param maps_hiera_merge
#   If the module should merge `$maps` from different levels in hiera.
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
  Enum['YES', 'NO'] $browse_mode                     = 'NO',
  Integer[0] $timeout                                = 600,
  Integer[0] $negative_timeout                       = 60,
  Integer $mount_wait                                = -1,
  Integer[0] $umount_wait                            = 12,
  Integer[0] $mount_nfs_default_protocol             = 4,
  Enum['yes', 'no'] $append_options                  = 'yes',
  Enum['none', 'verbose', 'debug'] $logging          = 'none',
  Hash $maps                                         = {},
  Boolean $maps_hiera_merge                          = false,
  Optional[String[1]] $autofs_package                = undef,
  Optional[Stdlib::Absolutepath] $autofs_sysconfig   = undef,
  String[1] $autofs_service                          = 'autofs',
  Optional[Stdlib::Absolutepath] $autofs_auto_master = undef,
  Boolean $use_nis_maps                              = true,
  Boolean $use_dash_hosts_for_net                    = true,
  String[1] $nis_master_name                         = 'auto.master',
  Stdlib::Ensure::Service $service_ensure            = 'running',
  Boolean $service_enable                            = true,
) {
  # system specific default values
  case $facts['os']['family'] {
    'RedHat': {
      $autofs_package_default     = 'autofs'
      $autofs_sysconfig_default   = '/etc/sysconfig/autofs'
      $autofs_auto_master_default = '/etc/auto.master'
      $autofs_sysconfig_template  = 'autofs/autofs_linux.erb'
    }
    'Suse': {
      $autofs_package_default     = 'autofs'
      $autofs_sysconfig_default   = '/etc/sysconfig/autofs'
      $autofs_auto_master_default = '/etc/auto.master'
      $autofs_sysconfig_template  = 'autofs/autofs_linux.erb'
    }
    'Debian': {
      $autofs_package_default     = 'autofs'
      $autofs_sysconfig_default   = '/etc/default/autofs'
      $autofs_auto_master_default = '/etc/auto.master'
      $autofs_sysconfig_template  = 'autofs/autofs_linux.erb'
    }
    'Solaris': {
      $autofs_package_default     = 'SUNWatfsr'
      $autofs_sysconfig_default   = '/etc/default/autofs'
      $autofs_auto_master_default = '/etc/auto_master'
      $autofs_sysconfig_template  = 'autofs/autofs_solaris.erb'
    }
    default: {
      fail("Operating system family ${facts['os']['family']} is not supported")
    }
  }

  # variable preparations
  $autofs_package_real     = pick($autofs_package, $autofs_package_default)
  $autofs_sysconfig_real   = pick($autofs_sysconfig, $autofs_sysconfig_default)
  $autofs_auto_master_real = pick($autofs_auto_master, $autofs_auto_master_default)

  case type3x($timeout) {
    'integer': { $timeout_int = $timeout }
    'string':  { $timeout_int = $timeout + 0 }
    default:   { fail('autofs::timeout is not an integer.') }
  }

  case type3x($negative_timeout) {
    'integer': { $negative_timeout_int = $negative_timeout }
    'string':  { $negative_timeout_int = $negative_timeout + 0 }
    default:   { fail('autofs::negative_timeout is not an integer.') }
  }

  case type3x($mount_wait) {
    'integer': { $mount_wait_int = $mount_wait }
    'string':  { $mount_wait_int = $mount_wait + 0 }
    default:   { fail('autofs::mount_wait is not an integer.') }
  }

  case type3x($umount_wait) {
    'integer': { $umount_wait_int = $umount_wait }
    'string':  { $umount_wait_int = $umount_wait + 0 }
    default:   { fail('autofs::umount_wait is not an integer.') }
  }

  case type3x($mount_nfs_default_protocol) {
    'integer': { $mount_nfs_default_protocol_int = $mount_nfs_default_protocol }
    'string':  { $mount_nfs_default_protocol_int = $mount_nfs_default_protocol + 0 }
    default:   { fail('autofs::mount_nfs_default_protocol is not an integer.') }
  }

  case type3x($use_nis_maps) {
    'string':  { $use_nis_maps_bool = str2bool($use_nis_maps) }
    'boolean': { $use_nis_maps_bool = $use_nis_maps }
    default:   { fail('autofs::use_nis_maps is not a boolean.') }
  }

  case type3x($maps_hiera_merge) {
    'string':  { $maps_hiera_merge_bool = str2bool($maps_hiera_merge) }
    'boolean': { $maps_hiera_merge_bool = $maps_hiera_merge }
    default:   { fail('autofs::maps_hiera_merge is not a boolean.') }
  }

  case type3x($use_dash_hosts_for_net) {
    'string':  { $use_dash_hosts_for_net_bool = str2bool($use_dash_hosts_for_net) }
    'boolean': { $use_dash_hosts_for_net_bool = $use_dash_hosts_for_net }
    default:   { fail('autofs::use_dash_hosts_for_net is not a boolean.') }
  }

  case type3x($service_enable) {
    'string':  { $service_enable_bool = str2bool($service_enable) }
    'boolean': { $service_enable_bool = $service_enable }
    default:   { fail('autofs::service_enable is not a boolean.') }
  }

  case $maps_hiera_merge_bool {
    true:    { $maps_real = hiera_hash('autofs::maps', {}) }
    default: { $maps_real = $maps }
  }

  # variable validations
  if is_string($browse_mode)         == false { fail('autofs::browse_mode is not a string.') }
  if is_string($append_options)      == false { fail('autofs::append_options is not a string.') }
  if is_string($autofs_package_real) == false { fail('autofs::autofs_package is not a string.') }
  if is_string($autofs_service)      == false { fail('autofs::autofs_service is not a string.') }
  if is_string($nis_master_name)     == false { fail('autofs::nis_master_name is not a string.') }
  if is_hash($maps)                  == false { fail('autofs::maps is not a hash.') }

  validate_re($service_ensure, '^(running|stopped)$', "service_ensure must be running or stopped, got ${service_ensure}")
  validate_re($logging, '^(none|verbose|debug)$', "service_ensure must be none, verbose or debug, got ${service_ensure}")

  validate_absolute_path(
    $autofs_sysconfig_real,
    $autofs_auto_master_real,
  )

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
    content => template($autofs_sysconfig_template),
    require => Package['autofs'],
  }

  create_resources('autofs::map', $maps_real)

  service { 'autofs':
    ensure    => $service_ensure,
    name      => $autofs_service,
    enable    => $service_enable_bool,
    require   => Package['autofs'],
    subscribe => [
      File['autofs_sysconfig'],
      Concat['auto.master'],
    ],
  }

  concat { 'auto.master':
    ensure  => present,
    path    => $autofs_auto_master_real,
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

  if $use_nis_maps_bool {
    concat::fragment { 'auto.master_nis_master':
      target  => 'auto.master',
      content => "+${nis_master_name}\n",
      order   => '99',
    }
  }
}
