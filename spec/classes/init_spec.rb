require 'spec_helper'

describe 'autofs' do
  platforms = {
    'RedHat' =>
      {
        autofs_package:           'autofs',
        autofs_sysconfig:         '/etc/sysconfig/autofs',
        autofs_sysconfig_fixture: 'files/autofs.linux',
        autofs_auto_master:       '/etc/auto.master',
      },
    'Suse' =>
      {
        autofs_package:           'autofs',
        autofs_sysconfig:         '/etc/sysconfig/autofs',
        autofs_sysconfig_fixture: 'files/autofs.linux',
        autofs_auto_master:       '/etc/auto.master',
      },
    'Debian' =>
      {
        autofs_package:           'autofs',
        autofs_sysconfig:         '/etc/default/autofs',
        autofs_sysconfig_fixture: 'files/autofs.linux',
        autofs_auto_master:       '/etc/auto.master',
      },
  }

  head = <<-END.gsub(%r{^\s+\|}, '')
    |# This file is being maintained by Puppet.
    |# DO NOT EDIT
    |
  END

  net = <<-END.gsub(%r{^\s+\|}, '')
    |/net -hosts
    |
  END

  nis_master = <<-END.gsub(%r{^\s+\|}, '')
    |+auto.master
  END

  platforms.sort.each do |osfamily, v|
    describe "with defaults for all parameters on supported OS #{osfamily}" do
      let(:facts) { { os: { family: osfamily } } }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('autofs') }

      it do
        is_expected.to contain_package('autofs').only_with(
          'ensure' => 'installed',
          'name'   => v[:autofs_package],
        )
      end

      it do
        is_expected.to contain_file('autofs_sysconfig').only_with(
          'ensure'  => 'file',
          'path'    => v[:autofs_sysconfig],
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'Package[autofs]',
          'content' => File.read(fixtures(v[:autofs_sysconfig_fixture])),
        )
      end

      it { is_expected.not_to contain_class('autofs::map') }

      it do
        is_expected.to contain_service('autofs').only_with(
          'ensure'    => 'running',
          'name'      => 'autofs',
          'enable'    => 'true',
          'require'   => 'Package[autofs]',
          'subscribe' => ['File[autofs_sysconfig]', 'Concat[auto.master]'],
        )
      end

      it do
        is_expected.to contain_concat('auto.master').with(
          'ensure'  => 'present',
          'path'    => v[:autofs_auto_master],
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'Package[autofs]',
        )
      end

      it do
        is_expected.to contain_concat__fragment('auto.master_head').only_with(
          'target'  => 'auto.master',
          'content' => head,
          'order'   => '01',
        )
      end

      it do
        is_expected.to contain_concat__fragment('auto.master_net').only_with(
          'target'  => 'auto.master',
          'content' => net,
          'order'   => '02',
        )
      end

      it do
        is_expected.to contain_concat__fragment('auto.master_nis_master').only_with(
          'target'  => 'auto.master',
          'content' => nis_master,
          'order'   => '99',
        )
      end
    end
  end

  context 'on supported OS RedHat' do
    context 'with browse_mode set to valid value <YES>' do
      let(:params) { { browse_mode: 'YES' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^BROWSE_MODE=\"YES\"$}) }
    end

    context 'with timeout set to valid value <242>' do
      let(:params) { { timeout: 242 } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^TIMEOUT=242$}) }
    end

    context 'with negative_timeout set to valid value <242>' do
      let(:params) { { negative_timeout: 242 } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^NEGATIVE_TIMEOUT=242$}) }
    end

    context 'with mount_wait set to valid value <242>' do
      let(:params) { { mount_wait: 242 } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^MOUNT_WAIT=242$}) }
    end

    context 'with umount_wait set to valid value <242>' do
      let(:params) { { umount_wait: 242 } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^UMOUNT_WAIT=242$}) }
    end

    context 'with mount_nfs_default_protocol set to valid value <3>' do
      let(:params) { { mount_nfs_default_protocol: 3 } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^MOUNT_NFS_DEFAULT_PROTOCOL=3$}) }
    end

    context 'with append_options set to valid value <no>' do
      let(:params) { { append_options: 'no' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^APPEND_OPTIONS=\"no\"$}) }
    end

    context 'with logging set to valid value <verbose>' do
      let(:params) { { logging: 'verbose' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^LOGGING=\"verbose\"$}) }
    end

    context "with maps set to valid value <{'home'=>{'mountpoint'=>'home','mounts'=>['spec nfsserver:/path/to/spec','test nfsserver:/path/to/test']}}>" do
      let(:params) { { maps: { 'home' => { 'mountpoint' => 'home', 'mounts' => ['spec nfsserver:/path/to/spec', 'test nfsserver:/path/to/test'] } } } }

      it { is_expected.to have_autofs__map_resource_count(1) }
      it do
        is_expected.to contain_autofs__map('home').only_with(
          'mountpoint' => 'home',
          'mounts'     => ['spec nfsserver:/path/to/spec', 'test nfsserver:/path/to/test'],
          'manage'     => true,
        )
      end

      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # from autofs::map, here to reach high resource coverage
      it { is_expected.to contain_file('autofs__map_mountmap_home') }
      it { is_expected.to contain_concat__fragment('auto.master_home') }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak') }
    end

    describe 'with maps_hiera_merge' do
      let(:facts) do
        {
          fqdn:     'data.from.hiera.fqdn',
          group:    'data_from_hiera_group',
        }
      end

      context 'set to valid value <false>' do
        let(:params) { { maps_hiera_merge: false } }

        it { is_expected.to have_autofs__map_resource_count(2) }
        it do
          is_expected.to contain_autofs__map('group').only_with(
            'mountpoint' => 'from_hiera_fqdn',
            'mounts'     => ['group nfsserver:/group/from/hiera/fqdn'],
            'manage'     => true,
          )
        end

        it do
          is_expected.to contain_autofs__map('home_from_hiera_fqdn').only_with(
            'mountpoint' => 'home',
            'mounts'     => ['home1 nfsserver:/home/from/hiera/fqdn/1', 'home2 nfsserver:/home/from/hiera/fqdn/2'],
            'manage'     => true,
          )
        end

        it { is_expected.to contain_concat('auto.master') }
        it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
        it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
        it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

        # from autofs::map, here to reach high resource coverage
        it { is_expected.to contain_file('autofs__map_mountmap_group') }
        it { is_expected.to contain_file('autofs__map_mountmap_home_from_hiera_fqdn') }
        it { is_expected.to contain_concat__fragment('auto.master_group') }
        it { is_expected.to contain_concat__fragment('auto.master_home_from_hiera_fqdn') }
        it { is_expected.to contain_concat__fragment('auto.master_linebreak') }
      end

      context 'set to valid value <true>' do
        let(:params) { { maps_hiera_merge: true } }

        it { is_expected.to have_autofs__map_resource_count(3) }
        it do
          is_expected.to contain_autofs__map('group').only_with(
            'mountpoint' => 'from_hiera_fqdn',
            'mounts'     => ['group nfsserver:/group/from/hiera/fqdn'],
            'manage'     => true,
          )
        end

        it do
          is_expected.to contain_autofs__map('home_from_hiera_fqdn').only_with(
            'mountpoint' => 'home',
            'mounts'     => ['home1 nfsserver:/home/from/hiera/fqdn/1', 'home2 nfsserver:/home/from/hiera/fqdn/2'],
            'manage'     => true,
          )
        end

        it do
          is_expected.to contain_autofs__map('home_from_hiera_group').only_with(
            'mountpoint' => 'home',
            'mounts'     => ['home nfsserver:/home/from/hiera/group'],
            'manage'     => true,
          )
        end

        it { is_expected.to contain_concat('auto.master') }
        it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
        it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
        it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

        # from autofs::map, here to reach high resource coverage
        it { is_expected.to contain_file('autofs__map_mountmap_group') }
        it { is_expected.to contain_file('autofs__map_mountmap_home_from_hiera_fqdn') }
        it { is_expected.to contain_file('autofs__map_mountmap_home_from_hiera_group') }
        it { is_expected.to contain_concat__fragment('auto.master_group') }
        it { is_expected.to contain_concat__fragment('auto.master_home_from_hiera_fqdn') }
        it { is_expected.to contain_concat__fragment('auto.master_home_from_hiera_group') }
        it { is_expected.to contain_concat__fragment('auto.master_linebreak') }
      end
    end

    context 'with autofs_package set to valid value <bikefs>' do
      let(:params) { { autofs_package: 'bikefs' } }

      it { is_expected.to contain_package('autofs').with_name('bikefs') }
    end

    context 'with autofs_sysconfig set to valid value </etc/testing/autofs>' do
      let(:params) { { autofs_sysconfig: '/etc/testing/autofs' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_path('/etc/testing/autofs') }
    end

    context 'with autofs_service set to valid value <testing>' do
      let(:params) { { autofs_service: 'testing' } }

      it { is_expected.to contain_service('autofs').with_name('testing') }
    end

    context 'with autofs_auto_master set to valid value </etc/bike.master>' do
      let(:params) { { autofs_auto_master: '/etc/bike.master' } }

      it { is_expected.to contain_concat('auto.master').with_path('/etc/bike.master') }
    end

    context 'with use_nis_maps set to valid value <false>' do
      let(:params) { { use_nis_maps: false } }

      it { is_expected.not_to contain_concat__fragment('auto.master_nis_master') }
    end

    context 'with use_dash_hosts_for_net set to valid value <false>' do
      let(:params) { { use_dash_hosts_for_net: false } }

      it { is_expected.to contain_concat__fragment('auto.master_net').with_content("/net /etc/auto.net --timeout=60\n\n") }
    end

    context 'with nis_master_name set to valid value <bike.meister>' do
      let(:params) { { nis_master_name: 'bike.meister' } }

      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content("+bike.meister\n") }
    end

    context 'with service_ensure set to valid value <stopped>' do
      let(:params) { { service_ensure: 'stopped' } }

      it { is_expected.to contain_service('autofs').with_ensure('stopped') }
    end

    context 'with service_enable set to valid value <false>' do
      let(:params) { { service_enable: false } }

      it { is_expected.to contain_service('autofs').with_enable('false') }
    end
  end

  context 'with maps on RedHat (for auto.master file) set to valid value' do
    context '<test => {}>' do
      let(:params) { { maps: { 'test' => {} } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'   => 'test',
          'mounts' => [],
          'manage' => true,
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # from autofs::map, here to reach high resource coverage
      it { is_expected.to contain_file('autofs__map_mountmap_test') }
    end

    context '<test => { mountpoint => mountpoint }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint' } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'       => 'test',
          'mountpoint' => 'mountpoint',
          'mounts'     => [],
          'manage'     => true,
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }
    end

    context '<test => { mappath => /etc/auto.testing }>' do
      let(:params) { { maps: { 'test' => { 'mappath' => '/etc/auto.testing' } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'    => 'test',
          'mappath' => '/etc/auto.testing',
          'mounts'  => [],
          'manage'  => true,
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis' } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'       => 'test',
          'mountpoint' => 'mountpoint',
          'maptype'    => 'nis',
          'mounts'     => [],
          'manage'     => true,
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis, mapname => auto.testing }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis', 'mapname' => 'auto.testing' } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'       => 'test',
          'mountpoint' => 'mountpoint',
          'maptype'    => 'nis',
          'mapname'    => 'auto.testing',
          'mounts'     => [],
          'manage'     => true,
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # from autofs::map, here to reach high resource coverage
      it { is_expected.to contain_file('autofs__map_auto.testing') }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis, manage => false }> maptype overrides manage' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis', 'manage' => false } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'       => 'test',
          'mountpoint' => 'mountpoint',
          'maptype'    => 'nis',
          'mounts'     => [],
          'manage'     => false,
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }
    end

    context '<test => { mountpoint => mountpoint, manage => false }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'manage' => false } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'       => 'test',
          'mountpoint' => 'mountpoint',
          'mounts'     => [],
          'manage'     => false,
        )
      end
    end

    # same test as above with options set
    context '<test => { options => ro }>' do
      let(:params) { { maps: { 'test' => { 'options' => 'ro' } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'    => 'test',
          'options' => 'ro',
          'mounts'  => [],
          'manage'  => true,
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # from autofs::map, here to reach high resource coverage
      it { is_expected.to contain_concat__fragment('auto.master_test') }
    end

    context '<test => { mountpoint => mountpoint, options => ro }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'options' => 'ro' } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'       => 'test',
          'mountpoint' => 'mountpoint',
          'options'    => 'ro',
          'mounts'     => [],
          'manage'     => true,
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis, options => ro }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis', 'options' => 'ro' } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'       => 'test',
          'mountpoint' => 'mountpoint',
          'maptype'    => 'nis',
          'options'    => 'ro',
          'mounts'     => [],
          'manage'     => true,
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }
    end

    context '<test => { mountpoint => mountpoint, manage => false, options => ro }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'manage' => false, 'options' => 'ro' } } } }

      it do
        is_expected.to contain_autofs__map('test').only_with(
          'name'       => 'test',
          'mountpoint' => 'mountpoint',
          'options'    => 'ro',
          'mounts'     => [],
          'manage'     => false,
        )
      end
    end

    context 'which manage seven mounts' do
      let(:params) do
        {
          maps: {
            'test1' => {},
            'test2' => { 'mountpoint' => 'mountpoint2' },
            'test3' => { 'mountpoint' => 'mountpoint3', 'options' => 'ro' },
            'test4' => { 'mountpoint' => 'mountpoint4', 'maptype' => 'nis' },
            'test5' => { 'mountpoint' => 'mountpoint5', 'manage' => false },
            'test6' => { 'mountpoint' => 'mountpoint6', 'mappath' => '/etc/auto.testing' },
            'test7' => { 'mountpoint' => 'mountpoint7', 'maptype' => 'nis', 'mapname' => 'auto.test' },
          },
        }
      end

      it do
        is_expected.to contain_autofs__map('test1').only_with(
          'manage'     => true,
          'mounts'     => [],
          'name'       => 'test1',
        )
      end

      it do
        is_expected.to contain_autofs__map('test2').only_with(
          'manage'     => true,
          'mountpoint' => 'mountpoint2',
          'mounts'     => [],
          'name'       => 'test2',
        )
      end

      it do
        is_expected.to contain_autofs__map('test3').only_with(
          'manage'     => true,
          'mountpoint' => 'mountpoint3',
          'mounts'     => [],
          'name'       => 'test3',
          'options'    => 'ro',
        )
      end

      it do
        is_expected.to contain_autofs__map('test4').only_with(
          'name'       => 'test4',
          'manage'     => true,
          'mountpoint' => 'mountpoint4',
          'maptype'    => 'nis',
          'mounts'     => [],
        )
      end

      it do
        is_expected.to contain_autofs__map('test5').only_with(
          'name'       => 'test5',
          'manage'     => false,
          'mountpoint' => 'mountpoint5',
          'mounts'     => [],
        )
      end

      it do
        is_expected.to contain_autofs__map('test6').only_with(
          'name'       => 'test6',
          'manage'     => true,
          'mountpoint' => 'mountpoint6',
          'mappath'    => '/etc/auto.testing',
          'mounts'     => [],
        )
      end

      it do
        is_expected.to contain_autofs__map('test7').only_with(
          'name'       => 'test7',
          'manage'     => true,
          'mountpoint' => 'mountpoint7',
          'maptype'    => 'nis',
          'mapname'    => 'auto.test',
          'mounts'     => [],
        )
      end

      it { is_expected.to have_autofs__map_resource_count(7) }
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # from autofs::map, here to reach high resource coverage
      it { is_expected.to contain_file('autofs__map_mountmap_test1') }
      it { is_expected.to contain_file('autofs__map_mountmap_test2') }
      it { is_expected.to contain_file('autofs__map_mountmap_test3') }
      it { is_expected.to contain_file('autofs__map_mountmap_test4') }
      it { is_expected.to contain_file('autofs__map_mountmap_test5') }
      it { is_expected.to contain_file('autofs__map_mountmap_test6') }
      it { is_expected.to contain_file('autofs__map_auto.test') }
      it { is_expected.to contain_concat__fragment('auto.master_test1') }
      it { is_expected.to contain_concat__fragment('auto.master_test2') }
      it { is_expected.to contain_concat__fragment('auto.master_test3') }
      it { is_expected.to contain_concat__fragment('auto.master_test4') }
      it { is_expected.to contain_concat__fragment('auto.master_test5') }
      it { is_expected.to contain_concat__fragment('auto.master_test6') }
      it { is_expected.to contain_concat__fragment('auto.master_test7') }
    end
  end

  describe 'running on unsupported OS' do
    let(:facts) { { os: { family: 'WierdOS' } } }

    it 'fails' do
      expect {
        is_expected.to contain_class(:subject)
      }.to raise_error(Puppet::Error, %r{Operating system family WierdOS is not supported})
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        group: 'data_from_hiera_group',
      }
    end

    validations = {
      'Boolean' => {
        name:    ['maps_hiera_merge', 'use_nis_maps', 'use_dash_hosts_for_net', 'service_enable'],
        valid:   [true, false],
        invalid: ['false', 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42],
        message: 'expects a Boolean',
      },
      'Enum[YES, NO]' => {
        name:    ['browse_mode'],
        valid:   ['YES', 'NO'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'expects a match for Enum',
      },
      'Enum[none, verbose, debug]' => {
        name:    ['logging'],
        valid:   ['none', 'verbose', 'debug'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'expects a match for Enum',
      },
      'Enum[yes, no]' => {
        name:    ['append_options'],
        valid:   ['yes', 'no'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'expects a match for Enum',
      },
      'Hash' => {
        name:    ['maps'],
        valid:   [], # Valid hashes are too complex to test them easily here. They should have their own tests anyway.
        invalid: ['string', ['array'], 3, 2.42, false],
        message: 'expects a Hash value',
      },
      'Integer' => {
        name:    ['timeout', 'negative_timeout', 'mount_wait', 'umount_wait', 'mount_nfs_default_protocol'],
        valid:   [3],
        invalid: ['3', 'string', ['array'], { 'ha' => 'sh' }, 2.42, false],
        message: 'expects an Integer',
      },
      'Stdlib::Absolutepath' => {
        name:    ['autofs_sysconfig', 'autofs_auto_master'],
        valid:   ['/absolute/filepath', '/absolute/directory/'],
        invalid: ['../invalid', 3, 2.42, ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a Stdlib::Absolutepath',
      },
      'Stdlib::Ensure::Service' => {
        name:    ['service_ensure'],
        valid:   ['stopped', 'running'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'Enum\[\'running\', \'stopped\'\]',
      },
      'String[1]' => {
        name:    ['autofs_package', 'autofs_service', 'nis_master_name'],
        valid:   ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: '(expects a String value|value of type Undef or String)',
      },
    }

    validations.sort.each do |type, var|
      mandatory_params = {} if mandatory_params.nil?
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid] = {} if var[:valid].nil?
        var[:invalid] = {} if var[:invalid].nil?

        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:facts) { [mandatory_facts, var[:facts]].reduce(:merge) } unless var[:facts].nil?
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": valid }].reduce(:merge) }

            it { is_expected.to compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": invalid }].reduce(:merge) }

            it 'fails' do
              expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
