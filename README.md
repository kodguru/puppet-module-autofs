puppet-module-autofs
====================

Puppet module to manage autofs. Documentation TBD.

[![Build Status](https://api.travis-ci.org/gusson/puppet-module-autofs.png)](https://travis-ci.org/gusson/puppet-module-autofs)


# Compatibility
---------------
This module is built for use with Puppet v3 (with and without the future
parser) and Puppet v4 on the following platforms and supports Ruby versions
1.8.7, 1.9.3, 2.0.0, 2.1.0 and 2.3.1.

* EL 5
* EL 6
* EL 7
* SLED / SLES 10
* SLED / SLES 11
* SLED / SLES 12
* Ubuntu 12.04 LTS
* Ubuntu 14.04 LTS

# Parameters
------------

browse_mode
-----------
Set this to 'YES' if you want your mounts to be browseable

- *Default*: 'NO'

timeout
-------
Set the default mount timeout

- *Default*: '600'

negative_timeout
----------------
Set the default negative timeout for failed mount attempts

- *Default*: '60'

mount_wait
----------
Set the time to wait for a response from mount

- *Default*: '-1'

umount_wait
-----------
Set the time to wait for a response from umount

- *Default*: '12'

mount_nfs_default_protocol
--------------------------
Specify the default protocol used by mount.nfs

- *Default*: '4'

append_options
--------------
Specify whether options should be appended to global options or replacing them

- *Default*: 'yes'

logging
-------
Set default log level "none", "verbose" or "debug"

- *Default*: 'none'

maps
----
Specify the maps managed. This value is sent to define autofs::map

- *Default*: undef

maps_hiera_merge
----------------
Set this value to true if you want *maps* to be merged from different levels in
hiera

- *Default*: false

autofs_package
--------------
Specify autofs package name

- *Default*: 'DEFAULT'

autofs_sysconfig
----------------
Specify autofs sysconfig location

- *Default*: 'DEFAULT'

autofs_service
--------------
Specify autofs service name

- *Default*: 'DEFAULT'

autofs_auto_master
------------------
Specify autofs.master location

- *Default*: 'DEFAULT'

use_nis_maps
------------
Set this to true make the module load mount maps from NIS

- *Default*: true

nis_master_name
---------------
The name of the NIS map containing the auto.master data

- *Default*: auto.master

service_ensure
--------------
Value for the service ensure attribute

- *Default*: 'running'

service_enable
--------------
Value for the service enable attribute

- *Default*: true

use_dash_hosts_for_net
----------------------
Set this to true makes autofs use "-hosts" for the /net mountpoint.  Set to false to use "/etc/auto.net"

- *Default*: true

# autofs::map parameters

mountpoint
----------
Specify the mountpoint

- *Default*: undef

maptype
-------
Specify maptype for mountpoint

- *Default*: undef

mounts
------
Specify the mounts to be mounted at mountpoint as an array

- *Default*: []

manage
------
Specify whether mounts should be managed or not. Results in '-null' in auto.master

- *Default*: true

file
----
Specify the mounts to be mounted at mountpoint from a file

- *Default*: undef

options
-------
Specify extra mount points for this mountpoint

- *Default*: undef

# Examples

Manage /home with mounts from a file on Puppet fileserver:

    autofs::maps:
      home:
        mountpoint: 'home'
        file: 'puppet:///files/autofs/auto.home'

Result in auto.master:

    /home /etc/auto.home

Manage /home with mounts defined hiera:

    autofs::maps:
      home:
        mountpoint: 'home'
        mounts:
          - 'user1      nfsserver:/path/to/home/user1'
          - 'user2      nfsserver:/path/to/home/user2'

Result in auto.home (auto.master remains as above):

    user1      nfsserver:/path/to/home/user1
    user2      nfsserver:/path/to/home/user2


Prevent /home from being managed by at all (NIS included):

    autofs::maps:
      home:
          mountpoint: 'home'
          manage: false

Result in auto.master:

    /home -null
