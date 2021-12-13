require 'spec_helper'

describe 'autofs' do
  head = <<-END.gsub(%r{^\s+\|}, '')
    |# This file is being maintained by Puppet.
    |# DO NOT EDIT
    |
  END

  tail = <<-END.gsub(%r{^\s+\|}, '')
    |
    |+auto.master
  END

  describe 'mountmap' do
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

      # needed for 100% testing coverage
      it { is_expected.to contain_file('autofs_sysconfig') }
      it { is_expected.to contain_package('autofs') }
      it { is_expected.to contain_service('autofs') }

      content_map = <<-END.gsub(%r{^\s+\|}, '')
        |server:/home/a
        |server:/home/b
        |server:/home/c
      END
      it { is_expected.to contain_file('autofs__map_mountmap_home').with_content(head + content_map) }
      it { is_expected.to contain_autofs__map('home') }

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/home /etc/auto.home
        |
        |+auto.master
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }
    end

    context 'defines /home as NIS map' do
      let(:params) do
        {
          maps: {
            'auto.home' => {
              'mountpoint' => 'home',
              'maptype'    => 'yp',
            },
          },
        }
      end

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/home yp auto.home
        |
        |+auto.master
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }
      it { is_expected.to contain_autofs__map('auto.home') }
      it { is_expected.to contain_file('autofs__map_mountmap_auto.home') }
    end

    context 'have a +auto.master as default' do
      let(:params) do
        {
          maps: {
            'auto.home' => {
              'mountpoint' => 'home',
              'maptype'    => 'yp',
            },
          },
        }
      end

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/home yp auto.home
        |
        |+auto.master
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }
    end

    context 'have a custom NIS master' do
      let(:params) do
        {
          nis_master_name: 'auto.custommaster',
          maps: {
            'auto.home' => {
              'mountpoint' => 'home',
              'maptype'    => 'yp',
            },
          },
        }
      end

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/home yp auto.home
        |
        |+auto.custommaster
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }
    end

    context 'have +auto.master disabled' do
      let(:params) do
        {
          use_nis_maps: 'false',
          maps: {
            'auto.home' => {
              'mountpoint' => 'home',
              'maptype'    => 'yp',
            },
          },
        }
      end

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/home yp auto.home
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }
    end

    context 'defines two mountpoints' do
      let(:params) do
        {
          maps: {
            'home' => {
              'mountpoint' => 'home',
              'mounts'     => ['server:/home/a', 'server:/home/b', 'server:/home/c'],
            },
            'data' => {
              'mountpoint' => 'data',
              'mounts'     => ['server:/data/a', 'server:/data/b', 'server:/data/c'],
              'options'    => '--vers=3',
            },
          },
        }
      end

      it 'contains both auto.home and auto.data' do
        is_expected.to contain_file('autofs__map_mountmap_home').with_path('/etc/auto.home')
        is_expected.to contain_file('autofs__map_mountmap_data').with_path('/etc/auto.data')
      end

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/data /etc/auto.data --vers=3
        |/home /etc/auto.home
        |
        |+auto.master
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }

      content_map_home = <<-END.gsub(%r{^\s+\|}, '')
        |server:/home/a
        |server:/home/b
        |server:/home/c
      END
      it { is_expected.to contain_file('autofs__map_mountmap_home').with_content(head + content_map_home) }
      it { is_expected.to contain_file('autofs__map_mountmap_home').with_path('/etc/auto.home') }
      it { is_expected.to contain_autofs__map('home') }

      content_map_data = <<-END.gsub(%r{^\s+\|}, '')
        |server:/data/a
        |server:/data/b
        |server:/data/c
      END
      it { is_expected.to contain_file('autofs__map_mountmap_data').with_content(head + content_map_data) }
      it { is_expected.to contain_file('autofs__map_mountmap_data').with_path('/etc/auto.data') }
      it { is_expected.to contain_autofs__map('data') }
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

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/ftp/projects /etc/auto.ftp
        |
        |+auto.master
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }

      content_map = <<-END.gsub(%r{^\s+\|}, '')
        |server:/ftp/a
        |server:/ftp/b
        |server:/ftp/c
      END
      it { is_expected.to contain_file('autofs__map_mountmap_ftp').with_content(head + content_map) }
      it { is_expected.to contain_file('autofs__map_mountmap_ftp').with_path('/etc/auto.ftp') }
      it { is_expected.to contain_autofs__map('ftp') }
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

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/ftp /etc/auto.ftp
        |
        |+auto.master
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }
      it { is_expected.to contain_file('autofs__map_mountmap_ftp').with_path('/etc/auto.ftp') }
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

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/home -null
        |
        |+auto.master
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }
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

      content_master = <<-END.gsub(%r{^\s+\|}, '')
        |/net -hosts
        |
        |/home /etc/auto.home
      END
      it { is_expected.to contain_file('auto.master').with_content(head + content_master) }
    end
  end

  describe 'use cases' do
    # https://github.com/kodguru/puppet-module-autofs/issues/25
    context 'issue #25 described expected behavior' do
      let(:facts) { { group: 'issue-25_from_hiera_group' } }

      it "auto.master contains correct '/proj yp auto.proj' as result" do
        is_expected.to contain_file('auto.master').with_content("#{head}/net -hosts\n\n/proj yp auto.proj\n#{tail}")
      end
      it { is_expected.to contain_autofs__map('auto.proj') }
    end

    context 'issue #25 described unexected behavior' do
      let(:facts) { { fqdn: 'issue-25.from.hiera.fqdn' } }

      it "auto.master contains wrong '/proj /etc/auto.auto.proj' as result" do
        is_expected.to contain_file('auto.master').with_content("#{head}/net -hosts\n\n/proj /etc/auto.auto.proj\n#{tail}")
      end
      it "map file uses wrong '/etc/auto.auto.proj' as path" do
        is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_path('/etc/auto.auto.proj')
      end
      it "map file uses correct '/path/to/file/with/mounts' as source" do
        is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_source('/path/to/file/with/mounts')
      end
    end

    context 'issue #25 fix using mappath to override previous declared mounts when using $maps_hiera_merge' do
      let(:facts) { { fqdn: 'issue-25-fix.from.hiera.fqdn', group: 'issue-25_from_hiera_group' } }
      let(:params) { { maps_hiera_merge: true } }

      it "auto.master contains correct '/proj /etc/auto.proj' as result" do
        is_expected.to contain_file('auto.master').with_content("#{head}/net -hosts\n\n/proj /etc/auto.proj\n#{tail}")
      end
      it "map file uses correct '/etc/auto.proj' as path" do
        is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_path('/etc/auto.proj')
      end
      it "map file uses correct '/path/to/file/with/mounts' as source" do
        is_expected.to contain_file('autofs__map_mountmap_auto.proj').with_source('/path/to/file/with/mounts')
      end
    end
  end
end
