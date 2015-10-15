puppet-module-autofs
====================

Puppet module to manage autofs. Documentation TBD.

[![Build Status](https://api.travis-ci.org/gusson/puppet-module-autofs.png)](https://travis-ci.org/gusson/puppet-module-autofs)

maps_hiera_merge
----------------
Set this value to true if you want *maps* to be merged from different levels in
hiera

- *Default*: false

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
