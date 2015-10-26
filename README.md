puppet-module-autofs
====================

Puppet module to manage autofs. Documentation TBD.

[![Build Status](https://api.travis-ci.org/gusson/puppet-module-autofs.png)](https://travis-ci.org/gusson/puppet-module-autofs)


# Compatibility
---------------
This module is built for use with Puppet v3 (with and without the future
parser) and Puppet v4 on the following platforms and supports Ruby versions
1.8.7, 1.9.3, 2.0.0 and 2.1.0.

* CentOS 5
* CentOS 6
* CentOS 7
* RedHat 5
* RedHat 6
* RedHat 7
* SLED 10
* SLED 11
* SLED 11
* SLES 10
* SLES 11
* SLES 12
* Ubuntu 12.04 LTS


# Parameters
------------

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
