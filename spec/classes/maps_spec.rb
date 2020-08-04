require 'spec_helper'

describe 'autofs' do
  describe 'mountmap' do
    context 'defines /home' do
      let :facts do
        {
          osfamily: 'RedHat',
          group:    'foo',
        }
      end
      let :params do
        {
          maps: {
            'home' => {
              'mountpoint' => 'home',
              'mounts'     => ['server:/home/a', 'server:/home/b', 'server:/home/c'],
            },
          },
        }
      end

      it 'contains auto.home' do
        is_expected.to contain_file('mountmap_home').with_path('/etc/auto.home')
      end
      it 'has correct permissions' do
        is_expected.to contain_file('mountmap_home').with(
          'owner' => 'root',
          'group' => 'root',
          'mode'  => '0644',
        )
      end

      it 'auto.home should be referenced in auto.master' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\/home \/etc\/auto.home$})
      end

      it 'auto.home should contain the map' do
        is_expected.to contain_file('mountmap_home').with_content(%r{^server:\/home\/a$})
        is_expected.to contain_file('mountmap_home').with_content(%r{^server:\/home\/b$})
        is_expected.to contain_file('mountmap_home').with_content(%r{^server:\/home\/c$})
      end
    end
    context 'defines /home as NIS map' do
      let :facts do
        {
          osfamily: 'RedHat',
          group:    'foo',
        }
      end
      let :params do
        {
          maps: {
            'auto.home' => {
              'mountpoint' => 'home',
              'maptype'    => 'yp',
            },
          },
        }
      end

      it 'contains auto.master definition' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\/home yp auto.home$})
      end
    end
    context 'have a +auto.master as default' do
      let :facts do
        {
          osfamily: 'RedHat',
          group:    'foo',
        }
      end
      let :params do
        {
          maps: {
            'auto.home' => {
              'mountpoint' => 'home',
              'maptype'    => 'yp',
            },
          },
        }
      end

      it 'contains NIS auto.master' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\+auto.master$})
      end
    end
    context 'have a custom NIS master' do
      let :facts do
        {
          osfamily: 'RedHat',
          group:    'foo',
        }
      end
      let :params do
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

      it 'contains NIS auto.master' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\+auto.custommaster$})
      end
    end
    context 'have +auto.master disabled' do
      let :facts do
        {
          osfamily: 'RedHat',
          group:    'foo',
        }
      end
      let :params do
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

      it 'contains auto.master definition' do
        is_expected.not_to contain_file('auto.master').with_content(%r{^\s*\+auto.master$})
      end
    end
    context 'defines two mountpoints' do
      let :facts do
        {
          osfamily: 'RedHat',
          group: 'foo',
        }
      end
      let :params do
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
        is_expected.to contain_file('mountmap_home').with_path('/etc/auto.home')
        is_expected.to contain_file('mountmap_data').with_path('/etc/auto.data')
      end
      it 'auto.master should contain both files' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\/home \/etc\/auto.home$})
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\/data \/etc\/auto.data})
      end
      it 'auto.master should contain options for data mount' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\/data \/etc\/auto.data --vers=3$})
      end

      it 'the maps should contain the corresponding data' do
        is_expected.to contain_file('mountmap_home').with_content(%r{^server:\/home\/a$})
        is_expected.to contain_file('mountmap_home').with_content(%r{^server:\/home\/b$})
        is_expected.to contain_file('mountmap_home').with_content(%r{^server:\/home\/c$})
        is_expected.to contain_file('mountmap_data').with_content(%r{^server:\/data\/a$})
        is_expected.to contain_file('mountmap_data').with_content(%r{^server:\/data\/b$})
        is_expected.to contain_file('mountmap_data').with_content(%r{^server:\/data\/c$})
      end
    end
    context 'define mountpoint with subpaths' do
      let :facts do
        {
          osfamily: 'RedHat',
          group: 'foo',
        }
      end
      let :params do
        {
          maps: {
            'ftp' => {
              'mountpoint' => 'ftp/projects',
              'mounts'     => ['server:/ftp/a', 'server:/ftp/b', 'server:/ftp/c'],
            },
          },
        }
      end

      it 'auto.master should contain file with correct path' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\/ftp\/projects \/etc\/auto.ftp$})
      end
      it 'contains auto.ftp' do
        is_expected.to contain_file('mountmap_ftp').with_path('/etc/auto.ftp')
      end
      it 'the map should contain the corresponding data' do
        is_expected.to contain_file('mountmap_ftp').with_content(%r{^server:\/ftp\/a$})
        is_expected.to contain_file('mountmap_ftp').with_content(%r{^server:\/ftp\/b$})
        is_expected.to contain_file('mountmap_ftp').with_content(%r{^server:\/ftp\/c$})
      end
    end
    context 'without defining mountpoint' do
      let :facts do
        {
          osfamily: 'RedHat',
          group:    'foo',
        }
      end
      let :params do
        {
          maps: {
            'ftp' => {
              'mounts' => ['server:/ftp/a', 'server:/ftp/b', 'server:/ftp/c'],
            },
          },
        }
      end

      it 'auto.master should contain file with correct path' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\/ftp \/etc\/auto.ftp$})
      end
      it 'contains auto.ftp' do
        is_expected.to contain_file('mountmap_ftp').with_path('/etc/auto.ftp')
      end
    end
    context 'define home as unmanaged' do
      let :facts do
        {
          osfamily: 'RedHat',
          group:    'foo',
        }
      end
      let :params do
        {
          maps: {
            'home' => {
              'mountpoint' => 'home',
              'manage'     => false,
            },
          },
        }
      end

      it 'contains auto.home with null option' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\/home -null$})
      end
    end
    context 'should not load NIS maps' do
      let :facts do
        {
          osfamily: 'RedHat',
          group:    'foo',
        }
      end
      let :params do
        {
          maps: {
            'home' => {
              'mountpoint' => 'home',
            },
          },
          use_nis_maps: false,
        }
      end

      it 'contains auto.home' do
        is_expected.to contain_file('auto.master').with_content(%r{^\s*\/home \/etc\/auto.home$})
      end
      it 'does not contain +auto.master' do
        is_expected.not_to contain_file('auto.master').with_content(%r{^\+auto.master$})
      end
    end
  end
end
