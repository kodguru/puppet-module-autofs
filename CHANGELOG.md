## 1.4.2

- Support Puppet 6

## 1.4.1

- Fix use_dash_hosts_for_net in Solaris (PR#22)

## 1.4.0

- Official Puppet v4 support
- Meta changes

## 1.3.0

- Added use_dash_hosts_for_net (PR#13)
- Fix compilation error when autofs::maps is undef. (PR#17)
- Fixed manage_false not working on Solaris (PR#15)
- Various fixes for code style and testing (PR#17, PR#16, PR#14, PR#12, PR#11)

## 1.2.0

- Added the parameters service_ensure and service_enable (PR#6)
- Code restructure to remove params.pp (PR#8)
- Preparations for Puppet v4 (PR#9)

## 1.1.0

- Possible to distribute and use a file as mount map (PR#2)
- It is now possible to specify options for a mount map. (PR#1)
- Added solaris support (PR#3, PR#5)
- Added hiera_merge support for the maps parameter. (PR#4)
- Updated for the Puppet future parser. (PR#4)

### Bugfixes
- The order of specified maps in auto.master should now be consistent. (PR#3)


## 1.0.0

- Initial release
