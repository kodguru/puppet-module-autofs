# Changelog

## [Unreleased](https://github.com/Ericsson/puppet-module-autofs/tree/HEAD)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v2.0.0...HEAD)

**Merged pull requests:**

- Update to PDK 2.6.1 [\#43](https://github.com/Ericsson/puppet-module-autofs/pull/43) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Update to PDK 2.6.0 [\#42](https://github.com/Ericsson/puppet-module-autofs/pull/42) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Update list of supported operating systems [\#41](https://github.com/Ericsson/puppet-module-autofs/pull/41) ([anders-larsson](https://github.com/anders-larsson))

## [v2.0.0](https://github.com/Ericsson/puppet-module-autofs/tree/v2.0.0) (2022-10-21)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v1.6.0...v2.0.0)

**Closed issues:**

- refactor to use concat to build auto.master [\#35](https://github.com/Ericsson/puppet-module-autofs/issues/35)

**Merged pull requests:**

- Allow un-managed content in autofs maps [\#40](https://github.com/Ericsson/puppet-module-autofs/pull/40) ([anders-larsson](https://github.com/anders-larsson))
- Update to PDK v2.5.0 and needed adjustments [\#39](https://github.com/Ericsson/puppet-module-autofs/pull/39) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v1.6.0](https://github.com/Ericsson/puppet-module-autofs/tree/v1.6.0) (2021-12-20)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v1.5.0...v1.6.0)

**Merged pull requests:**

- Refactor to use concat to build auto.master [\#38](https://github.com/Ericsson/puppet-module-autofs/pull/38) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v1.5.0](https://github.com/Ericsson/puppet-module-autofs/tree/v1.5.0) (2021-12-20)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v1.4.2...v1.5.0)

**Closed issues:**

- Transfer ownership to kodguru [\#27](https://github.com/Ericsson/puppet-module-autofs/issues/27)
- Imbalance in usage of autofs::map key parameter in templates/master.erb [\#25](https://github.com/Ericsson/puppet-module-autofs/issues/25)

**Merged pull requests:**

- Convert module to PDK 2.3.0 [\#37](https://github.com/Ericsson/puppet-module-autofs/pull/37) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Add support for mapname and mappath [\#34](https://github.com/Ericsson/puppet-module-autofs/pull/34) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Refactor auto.master template [\#33](https://github.com/Ericsson/puppet-module-autofs/pull/33) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Refactor Part 1 [\#32](https://github.com/Ericsson/puppet-module-autofs/pull/32) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Refactor tests [\#31](https://github.com/Ericsson/puppet-module-autofs/pull/31) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Update README with new travis URL [\#29](https://github.com/Ericsson/puppet-module-autofs/pull/29) ([anders-larsson](https://github.com/anders-larsson))

## [v1.4.2](https://github.com/Ericsson/puppet-module-autofs/tree/v1.4.2) (2018-10-31)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v1.4.1...v1.4.2)

## [v1.4.1](https://github.com/Ericsson/puppet-module-autofs/tree/v1.4.1) (2016-11-01)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v1.4.0...v1.4.1)

**Closed issues:**

- Release v1.4.0 [\#21](https://github.com/Ericsson/puppet-module-autofs/issues/21)

**Merged pull requests:**

- Fix var name in template for master\_solaris.erb [\#22](https://github.com/Ericsson/puppet-module-autofs/pull/22) ([ghost](https://github.com/ghost))

## [v1.4.0](https://github.com/Ericsson/puppet-module-autofs/tree/v1.4.0) (2016-09-12)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v1.3.0...v1.4.0)

**Merged pull requests:**

- Fix wording in README [\#20](https://github.com/Ericsson/puppet-module-autofs/pull/20) ([ghoneycutt](https://github.com/ghoneycutt))
- Condense list of supported platforms [\#19](https://github.com/Ericsson/puppet-module-autofs/pull/19) ([ghoneycutt](https://github.com/ghoneycutt))
- Add support for Ruby v2.3.1 and strict variable checking [\#18](https://github.com/Ericsson/puppet-module-autofs/pull/18) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.3.0](https://github.com/Ericsson/puppet-module-autofs/tree/v1.3.0) (2016-07-18)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v1.2.0...v1.3.0)

**Closed issues:**

- please don't use params.pp [\#7](https://github.com/Ericsson/puppet-module-autofs/issues/7)

**Merged pull requests:**

- Various [\#17](https://github.com/Ericsson/puppet-module-autofs/pull/17) ([ghoneycutt](https://github.com/ghoneycutt))
- Fix gemfile [\#16](https://github.com/Ericsson/puppet-module-autofs/pull/16) ([albgus](https://github.com/albgus))
- Enable manage\_false capability on Solaris [\#15](https://github.com/Ericsson/puppet-module-autofs/pull/15) ([ereamel](https://github.com/ereamel))
- Add tests for PR\#13 [\#14](https://github.com/Ericsson/puppet-module-autofs/pull/14) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Add /etc/auto.net for /net option [\#13](https://github.com/Ericsson/puppet-module-autofs/pull/13) ([dantremblay](https://github.com/dantremblay))
- Random bits [\#12](https://github.com/Ericsson/puppet-module-autofs/pull/12) ([ghoneycutt](https://github.com/ghoneycutt))
- Refactor spec tests [\#11](https://github.com/Ericsson/puppet-module-autofs/pull/11) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Update README [\#10](https://github.com/Ericsson/puppet-module-autofs/pull/10) ([anders-larsson](https://github.com/anders-larsson))

## [v1.2.0](https://github.com/Ericsson/puppet-module-autofs/tree/v1.2.0) (2015-10-26)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v1.1.0...v1.2.0)

**Merged pull requests:**

- Prepare for puppet4 [\#9](https://github.com/Ericsson/puppet-module-autofs/pull/9) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Remove params.pp [\#8](https://github.com/Ericsson/puppet-module-autofs/pull/8) ([Phil-Friderici](https://github.com/Phil-Friderici))
- New parameters for service attributes [\#6](https://github.com/Ericsson/puppet-module-autofs/pull/6) ([jwennerberg](https://github.com/jwennerberg))

## [v1.1.0](https://github.com/Ericsson/puppet-module-autofs/tree/v1.1.0) (2015-09-30)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/v1.0.0...v1.1.0)

**Merged pull requests:**

- Move +auto\_master to end of file [\#5](https://github.com/Ericsson/puppet-module-autofs/pull/5) ([dantremblay](https://github.com/dantremblay))
- Merge changes from other sources [\#4](https://github.com/Ericsson/puppet-module-autofs/pull/4) ([anders-larsson](https://github.com/anders-larsson))
- add Solaris support [\#3](https://github.com/Ericsson/puppet-module-autofs/pull/3) ([dsundq](https://github.com/dsundq))
- Use name of map if mountpoint is not available [\#2](https://github.com/Ericsson/puppet-module-autofs/pull/2) ([ghost](https://github.com/ghost))
- Add ability to add options to auto.master maps [\#1](https://github.com/Ericsson/puppet-module-autofs/pull/1) ([ghost](https://github.com/ghost))

## [v1.0.0](https://github.com/Ericsson/puppet-module-autofs/tree/v1.0.0) (2014-11-10)

[Full Changelog](https://github.com/Ericsson/puppet-module-autofs/compare/2795b3363eeac0cf0033a9ec707ef04543991a86...v1.0.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
