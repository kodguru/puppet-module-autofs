require 'spec_helper'

describe 'autofs' do
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

  describe 'use cases and examples' do
    context 'defines /home' do
      let(:params) do
        {
          maps: {
            'home' => {
              'mountpoint' => 'home',
              'mounts'     => ['server:/home/a', 'server:/home/b', 'server:/home/c'],
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('home').only_with(
          'manage'     => true,
          'mountpoint' => 'home',
          'mounts'     => ['server:/home/a', 'server:/home/b', 'server:/home/c'],
          'name'       => 'home',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(5) } # include fragments from autofs::map
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # define autofs::map
      map = <<-END.gsub(%r{^\s+\|}, '')
        |server:/home/a
        |server:/home/b
        |server:/home/c
      END

      it { is_expected.to contain_file('autofs__map_mountmap_home').with_content(head + map) }
      it { is_expected.to contain_concat__fragment('auto.master_home').with_content("/home /etc/auto.home\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }

      # needed for 100% testing coverage
      it { is_expected.to contain_file('autofs_sysconfig') }
      it { is_expected.to contain_package('autofs') }
      it { is_expected.to contain_service('autofs') }
    end

    context 'defines /home as NIS map and have a +auto.master as default' do
      let(:params) do
        {
          maps: {
            'auto.home' => {
              'maptype'    => 'yp',
              'mountpoint' => 'home',
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('auto.home').only_with(
          'manage'     => true,
          'maptype'    => 'yp',
          'mountpoint' => 'home',
          'mounts'     => [],
          'name'       => 'auto.home',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(5) } # include fragments from autofs::map

      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # define autofs::map
      it { is_expected.to contain_file('autofs__map_mountmap_auto.home').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_auto.home').with_content("/home yp auto.home\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end

    context 'have a custom NIS master' do
      let(:params) do
        {
          nis_master_name: 'auto.custommaster',
          maps: {
            'auto.home' => {
              'maptype'    => 'yp',
              'mountpoint' => 'home',
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('auto.home').only_with(
          'manage'     => true,
          'maptype'    => 'yp',
          'mountpoint' => 'home',
          'mounts'     => [],
          'name'       => 'auto.home',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(5) } # include fragments from autofs::map

      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content("+auto.custommaster\n") }

      # define autofs::map
      it { is_expected.to contain_file('autofs__map_mountmap_auto.home').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_auto.home').with_content("/home yp auto.home\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end

    context 'have +auto.master disabled' do
      let(:params) do
        {
          use_nis_maps: 'false',
          maps: {
            'auto.home' => {
              'maptype'    => 'yp',
              'mountpoint' => 'home',
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('auto.home').only_with(
          'manage'     => true,
          'maptype'    => 'yp',
          'mountpoint' => 'home',
          'mounts'     => [],
          'name'       => 'auto.home',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(4) } # include fragments from autofs::map

      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.not_to contain_concat__fragment('auto.master_nis_master') }

      # define autofs::map
      it { is_expected.to contain_concat__fragment('auto.master_auto.home').with_content("/home yp auto.home\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end

    context 'defines two mountpoints auto.home and auto.data' do
      let(:params) do
        {
          maps: {
            'data' => {
              'mountpoint' => 'data',
              'mounts'     => ['server:/data/a', 'server:/data/b', 'server:/data/c'],
              'options'    => '--vers=3',
            },
            'home' => {
              'mountpoint' => 'home',
              'mounts'     => ['server:/home/a', 'server:/home/b', 'server:/home/c'],
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('data').only_with(
          'manage'     => true,
          'mountpoint' => 'data',
          'mounts'     => ['server:/data/a', 'server:/data/b', 'server:/data/c'],
          'name'       => 'data',
          'options'    => '--vers=3',
        )
      end

      it do
        is_expected.to contain_autofs__map('home').only_with(
          'manage'     => true,
          'mountpoint' => 'home',
          'mounts'     => ['server:/home/a', 'server:/home/b', 'server:/home/c'],
          'name'       => 'home',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(2) }
      it { is_expected.to have_concat__fragment_resource_count(6) } # include fragments from autofs::map
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # define autofs::map
      map_data = <<-END.gsub(%r{^\s+\|}, '')
        |server:/data/a
        |server:/data/b
        |server:/data/c
      END

      map_home = <<-END.gsub(%r{^\s+\|}, '')
        |server:/home/a
        |server:/home/b
        |server:/home/c
      END

      it { is_expected.to contain_file('autofs__map_mountmap_data').with_content(head + map_data) }
      it { is_expected.to contain_file('autofs__map_mountmap_home').with_content(head + map_home) }
      it { is_expected.to contain_file('autofs__map_mountmap_data').with_path('/etc/auto.data') }
      it { is_expected.to contain_file('autofs__map_mountmap_home').with_path('/etc/auto.home') }
      it { is_expected.to contain_concat__fragment('auto.master_data').with_content("/data /etc/auto.data --vers=3\n") }
      it { is_expected.to contain_concat__fragment('auto.master_home').with_content("/home /etc/auto.home\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end

    context 'define mountpoint with subpaths' do
      let(:params) do
        {
          maps: {
            'ftp' => {
              'mountpoint' => 'ftp/projects',
              'mounts'     => ['server:/ftp/a', 'server:/ftp/b', 'server:/ftp/c'],
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('ftp').only_with(
          'manage'     => true,
          'mountpoint' => 'ftp/projects',
          'mounts'     => ['server:/ftp/a', 'server:/ftp/b', 'server:/ftp/c'],
          'name'       => 'ftp',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(5) } # include fragments from autofs::map
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # define autofs::map
      map = <<-END.gsub(%r{^\s+\|}, '')
        |server:/ftp/a
        |server:/ftp/b
        |server:/ftp/c
      END

      it { is_expected.to contain_file('autofs__map_mountmap_ftp').with_content(head + map) }
      it { is_expected.to contain_file('autofs__map_mountmap_ftp').with_path('/etc/auto.ftp') }
      it { is_expected.to contain_concat__fragment('auto.master_ftp').with_content("/ftp/projects /etc/auto.ftp\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end

    context 'without defining mountpoint' do
      let(:params) do
        {
          maps: {
            'ftp' => {
              'mounts' => ['server:/ftp/a', 'server:/ftp/b', 'server:/ftp/c'],
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('ftp').only_with(
          'manage'     => true,
          'mounts'     => ['server:/ftp/a', 'server:/ftp/b', 'server:/ftp/c'],
          'name'       => 'ftp',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(5) } # include fragments from autofs::map
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # define autofs::map
      map = <<-END.gsub(%r{^\s+\|}, '')
        |server:/ftp/a
        |server:/ftp/b
        |server:/ftp/c
      END

      it { is_expected.to contain_file('autofs__map_mountmap_ftp').with_content(head + map) }
      it { is_expected.to contain_file('autofs__map_mountmap_ftp').with_path('/etc/auto.ftp') }
      it { is_expected.to contain_concat__fragment('auto.master_ftp').with_content("/ftp /etc/auto.ftp\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end

    context 'define home as unmanaged' do
      let(:params) do
        {
          maps: {
            'home' => {
              'mountpoint' => 'home',
              'manage'     => false,
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('home').only_with(
          'manage'     => false,
          'mountpoint' => 'home',
          'mounts'     => [],
          'name'       => 'home',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(5) } # include fragments from autofs::map
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # define autofs::map
      it { is_expected.to contain_file('autofs__map_mountmap_home').with_content(head) }
      it { is_expected.to contain_file('autofs__map_mountmap_home').with_path('/etc/auto.home') }
      it { is_expected.to contain_concat__fragment('auto.master_home').with_content("/home -null\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end

    context 'should not load NIS maps' do
      let(:params) do
        {
          maps: {
            'home' => {
              'mountpoint' => 'home',
            },
          },
          use_nis_maps: false,
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('home').only_with(
          'manage'     => true,
          'mountpoint' => 'home',
          'mounts'     => [],
          'name'       => 'home',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(4) } # include fragments from autofs::map
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.not_to contain_concat__fragment('auto.master_nis_master') }

      # define autofs::map
      it { is_expected.to contain_file('autofs__map_mountmap_home').with_content(head) }
      it { is_expected.to contain_file('autofs__map_mountmap_home').with_path('/etc/auto.home') }
      it { is_expected.to contain_concat__fragment('auto.master_home').with_content("/home /etc/auto.home\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end
  end

  describe 'issues' do
    # https://github.com/kodguru/puppet-module-autofs/issues/25
    context 'issue #25 described expected behavior, ' do
      let(:params) do
        {
          maps: {
            'auto.proj' => {
              'mountpoint' => 'proj',
              'maptype'    => 'yp',
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('auto.proj').only_with(
          'manage'     => true,
          'maptype'    => 'yp',
          'mountpoint' => 'proj',
          'mounts'     => [],
          'name'       => 'auto.proj',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(5) } # include fragments from autofs::map
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # define autofs::map
      it { is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_content(head) }
      it { is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_path('/etc/auto.auto.proj') }
      it "auto.master contains correct '/proj yp auto.proj' as result" do
        is_expected.to contain_concat__fragment('auto.master_auto.proj').with_content("/proj yp auto.proj\n")
      end
      it { is_expected.to contain_concat__fragment('auto.master_auto.proj').with_content("/proj yp auto.proj\n") }
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end

    context 'issue #25 described unexected behavior' do
      let(:params) do
        {
          maps: {
            'auto.proj' => {
              'file'       => '/path/to/file/with/mounts',
              'mountpoint' => 'proj',
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('auto.proj').only_with(
          'file'       => '/path/to/file/with/mounts',
          'manage'     => true,
          'mountpoint' => 'proj',
          'mounts'     => [],
          'name'       => 'auto.proj',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(5) } # include fragments from autofs::map
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # define autofs::map
      it { is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_content(nil) }
      it "map file uses wrong '/etc/auto.auto.proj' as path" do
        is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_path('/etc/auto.auto.proj')
      end
      it "map file uses correct '/path/to/file/with/mounts' as source" do
        is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_source('/path/to/file/with/mounts')
      end
      it "auto.master contains wrong '/proj /etc/auto.auto.proj' as result" do
        is_expected.to contain_concat__fragment('auto.master_auto.proj').with_content("/proj /etc/auto.auto.proj\n")
      end
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end

    context 'issue #25 fix using mappath to override previous declared mounts when using $maps_hiera_merge' do
      let(:params) do
        {
          maps: {
            'auto.proj' => {
              'file'       => '/path/to/file/with/mounts',
              'mappath'    => '/etc/auto.proj',
              'mountpoint' => 'proj',
            },
          },
        }
      end

      # class autofs
      it do
        is_expected.to contain_autofs__map('auto.proj').only_with(
          'file'       => '/path/to/file/with/mounts',
          'manage'     => true,
          'mappath'    => '/etc/auto.proj',
          'mountpoint' => 'proj',
          'mounts'     => [],
          'name'       => 'auto.proj',
        )
      end

      it { is_expected.to have_autofs__map_resource_count(1) }
      it { is_expected.to have_concat__fragment_resource_count(5) } # include fragments from autofs::map
      it { is_expected.to contain_concat('auto.master') }
      it { is_expected.to contain_concat__fragment('auto.master_head').with_content(head) }
      it { is_expected.to contain_concat__fragment('auto.master_net').with_content(net) }
      it { is_expected.to contain_concat__fragment('auto.master_nis_master').with_content(nis_master) }

      # define autofs::map
      it { is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_content(nil) }
      it "map file uses correct '/etc/auto.proj' as path" do
        is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_path('/etc/auto.proj')
      end
      it "map file uses correct '/path/to/file/with/mounts' as source" do
        is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_source('/path/to/file/with/mounts')
      end
      it "auto.master contains correct '/proj /etc/auto.proj' as result" do
        is_expected.to contain_concat__fragment('auto.master_auto.proj').with_content("/proj /etc/auto.proj\n")
      end
      it { is_expected.to contain_concat__fragment('auto.master_linebreak').with_content("\n") }
    end
  end
end
