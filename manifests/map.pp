# @summary Manage autofs maps
#
# @example Examples
#  Manage `/home` with mounts from a file on Puppet fileserver:
#  autofs::maps:
#    home:
#      mountpoint: 'home'
#      file: 'puppet:///files/autofs/auto.home'
#
#  Results in `auto.master` with the following content.
#    /home /etc/auto.home
#
#  Manage `/home` with mounts defined hiera:
#    autofs::maps:
#      home:
#        mountpoint: 'home'
#        mounts:
#          - 'user1      nfsserver:/path/to/home/user1'
#          - 'user2      nfsserver:/path/to/home/user2'
#
#  Results in `auto.home` with the following content and `auto.master` remaining as above.
#    user1      nfsserver:/path/to/home/user1
#    user2      nfsserver:/path/to/home/user2
#
#  Prevent `/home` from being managed by autofs (NIS included):
#    autofs::maps:
#      home:
#        mountpoint: 'home'
#        manage: false
#
#  Result in auto.master:
#    /home -null
#
# @param mountpoint
#   Specify the mountpoint in `auto.master`.
#
# @param maptype
#   Specify maptype for mountpoint in `auto.master`
#
# @param mapname
#   The name for the map in `auto.master`. The default of `undef` will use the name of the key used to specify the mount.
#
# @param mappath
#   Absolute path of the map file to be created and used in `auto.master`. The default of `undef` will use the name of the
#   key used to specify the mount with `/etc/auto.` as prefix.
#
# @param mounts
#   Specify the mounts to be mounted at mountpoint as an array.
#
# @param manage
#   Boolean to manage mounts in `auto.master`. Setting it to false will result in `-null` in `auto.master`.
#
# @param file
#   Specify the mounts to be mounted at mountpoint from a file.
#
# @param options
#   Specify extra mount points for this mountpoint in `auto.master`.
#
define autofs::map (
  Array $mounts                           = [],
  Optional[Stdlib::Filesource] $file      = undef,
  Optional[String[1]] $mapname            = undef,
  Optional[Stdlib::Absolutepath] $mappath = undef,
  # $autofs::maps which gets passed here, is also used for auto.master template.
  # The following parameters are not used in the mountmap.erb template.
  # But they need to exist to avoid "invalid parameter options" errors.
  Optional[String[1]] $mountpoint         = undef,
  Optional[String[1]] $maptype            = undef,
  Variant[String[1], Boolean] $manage     = true,
  Optional[String[1]] $options            = undef,
) {
  $mnt = $name

  # variable preparations and validations
  $mapname_real = pick($mapname, "mountmap_${name}")
  $mappath_real = pick($mappath, "/etc/auto.${name}")

  case type3x($mounts) {
    'array':  { $mounts_array = $mounts }
    'string': { $mounts_array = [$mounts] }
    default:  { fail('autofs::map::mounts is not an array.') }
  }

  if is_string($file)         == false { fail('autofs::map::file is not a string.') }
  if is_string($mapname_real) == false { fail('autofs::map::mapname is not a string.') }
  if is_absolute_path($mappath_real) == false { fail('autofs::map::mappath is not an absolute path.') }

  # functionality
  $content = $file ? {
    undef   => template('autofs/mountmap.erb'),
    default => undef,
  }

  file { "autofs__map_${mapname_real}":
    ensure  => file,
    path    => $mappath_real,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $file,
    content => $content,
  }

  # maptype is not used on Solaris
  case $facts['os']['family'] {
    'Solaris': { $maptype_real = undef }
    default:   { $maptype_real = " ${maptype}" }
  }

  case $options {
    undef:   { $options_real = '' }
    default: { $options_real = " ${options}" }
  }

  # This behaviour is taken from the template in v1.5.0 of this module.
  # When $maptype is given, $mapname is used without 'auto.' as prefix.
  if $maptype {
    case $mapname {
      undef:   { $mapname_real2 = $name }
      default: { $mapname_real2 = $mapname }
    }
  } else {
    case $mapname {
      undef:   { $mapname_real2 = "auto.${name}" }
      default: { $mapname_real2 = $mapname }
    }
  }

  case $mappath {
    undef:   { $mappath_real2 = "/etc/auto.${name}" }
    default: { $mappath_real2 = $mappath }
  }

  # build string for map, considering if maptype and format are set
  if $mountpoint {
    if $maptype {
      $mount = "/${mountpoint}${maptype_real} ${mapname_real2}${options_real}"
    }
    elsif $manage == false {
      $mount = "/${mountpoint} -null${options_real}"
    }
    else {
      $mount = "/${mountpoint} ${mappath_real2}${options_real}"
    }
  }
  else {
    $mount = "/${name} /etc/${mapname_real2}${options_real}"
  }

  concat::fragment { "auto.master_${name}":
    target  => 'auto.master',
    content => "${mount}\n",
    order   => '10',
  }

  if defined(Concat::Fragment['auto.master_linebreak']) == false {
    concat::fragment { 'auto.master_linebreak':
      target  => 'auto.master',
      content => "\n",
      order   => '98',
    }
  }
}
