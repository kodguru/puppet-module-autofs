# == Define: autofs::map
#
# Manage autofs maps
#
define autofs::map (
  $mounts     = [],
  $file       = undef,
  $mapname    = undef,
  $mappath    = undef,
  # $autofs::maps which gets passed here, is also used for auto.master template.
  # The following parameters are not used in the mountmap.erb template.
  # But they need to exist to avoid "invalid parameter options" errors.
  $mountpoint = undef,
  $maptype    = undef,
  $manage     = true,
  $options    = undef,
) {

  $mnt = $name

  # variable preparations and validations

  $mapname_real = pick($mapname, "mountmap_${name}")
  $mappath_real = pick($mappath, "/etc/auto.${name}")

  case type3x($mounts) {
    'array':  { $mounts_array = $mounts }
    'string': { $mounts_array = [ $mounts ] }
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
  case $::osfamily {
    'Solaris': { $maptype_real = undef }
    default:   { $maptype_real = " ${maptype}"   }
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
