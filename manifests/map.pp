define autofs::map (
  $mountpoint = undef,
  $mounts = [],
) {

  if $mountpoint == undef {
    if $name == undef {
      $mnt = $name
    } else {
      fail("A mountpoint has to be supplied.")
    }
  } else {
    $mnt = $mountpoint
  }

  $mountmap = "/etc/auto.${mnt}"

  file { "mountmap_${mnt}":
    ensure  => file,
    path    => $mountmap,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('autofs/mountmap.erb')
  }

}
