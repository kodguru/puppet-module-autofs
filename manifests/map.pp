# == Define: autofs::map
#
# Manage autofs maps
#
define autofs::map (
  $mountpoint = undef,
  $maptype    = undef,
  $mounts     = [],
  $manage     = true,
  $file       = undef,
  $options    = undef,
) {

  $mnt = $name
  $mountmap = "/etc/auto.${mnt}"

  if $maptype == undef {
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
}
