# == Define: autofs::map
#
# Manage autofs maps
#
define autofs::map (
  $mounts     = [],
  $file       = undef,
  # $autofs::maps which gets passed here, is also used for auto.master template.
  # The following parameters are not used in the mountmap.erb template.
  # But they need to exist to avoid "invalid parameter options" errors.
  $mountpoint = undef,
  $maptype    = undef,
  $manage     = true,
  $options    = undef,
) {

  $mnt = $name
  $mountmap = "/etc/auto.${mnt}"

  if $file == undef {
    file { "mountmap_${mnt}":
      ensure  => file,
      path    => $mountmap,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('autofs/mountmap.erb'),
    }
  } else {
    file { "mountmap_${mnt}":
      ensure => file,
      path   => $mountmap,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => $file,
    }
  }
}
