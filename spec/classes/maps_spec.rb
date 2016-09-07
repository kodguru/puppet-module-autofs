require 'spec_helper'

describe 'autofs' do
  describe 'mountmap' do
    context 'defines /home' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :maps =>
          {
            'home' =>
              {
                'mountpoint' => 'home',
                'mounts'     => [ 'server:/home/a', 'server:/home/b', 'server:/home/c' ]
              }
          }
        }
      end

      it 'should contain auto.home' do
        should contain_file('mountmap_home').with_path('/etc/auto.home')
      end
      it 'should have correct permissions' do
        should contain_file('mountmap_home').with({
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      end

      it 'auto.home should be referenced in auto.master' do
        should contain_file('auto.master').with_content(/^\s*\/home \/etc\/auto.home$/)
      end

      it 'auto.home should contain the map' do
        should contain_file('mountmap_home').with_content(/^server:\/home\/a$/)
        should contain_file('mountmap_home').with_content(/^server:\/home\/b$/)
        should contain_file('mountmap_home').with_content(/^server:\/home\/c$/)
      end
    end
    context 'defines /home as NIS map' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :maps =>
          {
            'auto.home' =>
              {
                'mountpoint' => 'home',
                'maptype'     => 'yp'
              }
          }
        }
      end

      it 'should contain auto.master definition' do
        should contain_file('auto.master').with_content(/^\s*\/home yp auto.home$/)
      end

    end
    context 'have a +auto.master as default' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :maps =>
          {
            'auto.home' =>
              {
                'mountpoint' => 'home',
                'maptype'     => 'yp'
              }
          }
        }
      end

      it 'should contain NIS auto.master' do
        should contain_file('auto.master').with_content(/^\s*\+auto.master$/)
      end

    end
    context 'have a custom NIS master' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :nis_master_name => 'auto.custommaster',
          :maps =>
          {
            'auto.home' =>
              {
                'mountpoint' => 'home',
                'maptype'     => 'yp'
              }
          }
        }
      end

      it 'should contain NIS auto.master' do
        should contain_file('auto.master').with_content(/^\s*\+auto.custommaster$/)
      end

    end
    context 'have +auto.master disabled' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :use_nis_maps => 'false',
          :maps =>
          {
            'auto.home' =>
              {
                'mountpoint' => 'home',
                'maptype'     => 'yp'
              }
          }
        }
      end

      it 'should contain auto.master definition' do
        should_not contain_file('auto.master').with_content(/^\s*\+auto.master$/)
      end

    end
    context 'defines two mountpoints' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :maps =>
          {
            'home' =>
            {
              'mountpoint' => 'home',
              'mounts'     => [ 'server:/home/a', 'server:/home/b', 'server:/home/c' ]
            },
            'data' =>
            {
              'mountpoint' => 'data',
              'mounts'     => [ 'server:/data/a', 'server:/data/b', 'server:/data/c'],
              'options'    => '--vers=3',
            }
          }
        }
      end

      it 'should contain both auto.home and auto.data' do
        should contain_file('mountmap_home').with_path('/etc/auto.home')
        should contain_file('mountmap_data').with_path('/etc/auto.data')
      end
      it 'auto.master should contain both files' do
        should contain_file('auto.master').with_content(/^\s*\/home \/etc\/auto.home$/)
        should contain_file('auto.master').with_content(/^\s*\/data \/etc\/auto.data/)
      end
      it 'auto.master should contain options for data mount' do
        should contain_file('auto.master').with_content(/^\s*\/data \/etc\/auto.data --vers=3$/)
      end

      it 'the maps should contain the corresponding data' do
        should contain_file('mountmap_home').with_content(/^server:\/home\/a$/)
        should contain_file('mountmap_home').with_content(/^server:\/home\/b$/)
        should contain_file('mountmap_home').with_content(/^server:\/home\/c$/)
        should contain_file('mountmap_data').with_content(/^server:\/data\/a$/)
        should contain_file('mountmap_data').with_content(/^server:\/data\/b$/)
        should contain_file('mountmap_data').with_content(/^server:\/data\/c$/)
      end
    end
    context 'define mountpoint with subpaths' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :maps =>
          {
            'ftp' =>
            {
              'mountpoint' => 'ftp/projects',
              'mounts'     => [ 'server:/ftp/a', 'server:/ftp/b', 'server:/ftp/c' ]
            },
          }
        }
      end
      it 'auto.master should contain file with correct path' do
        should contain_file('auto.master').with_content(/^\s*\/ftp\/projects \/etc\/auto.ftp$/)
      end
      it 'should contain auto.ftp' do
        should contain_file('mountmap_ftp').with_path('/etc/auto.ftp')
      end
      it 'the map should contain the corresponding data' do
        should contain_file('mountmap_ftp').with_content(/^server:\/ftp\/a$/)
        should contain_file('mountmap_ftp').with_content(/^server:\/ftp\/b$/)
        should contain_file('mountmap_ftp').with_content(/^server:\/ftp\/c$/)
      end
    end
    context 'without defining mountpoint' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :maps =>
          {
            'ftp' =>
            {
              'mounts'     => [ 'server:/ftp/a', 'server:/ftp/b', 'server:/ftp/c' ]
            },
          }
        }
      end
      it 'auto.master should contain file with correct path' do
        should contain_file('auto.master').with_content(/^\s*\/ftp \/etc\/auto.ftp$/)
      end
      it 'should contain auto.ftp' do
        should contain_file('mountmap_ftp').with_path('/etc/auto.ftp')
      end
    end
    context 'define home as unmanaged' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :maps =>
          {
            'home' =>
            {
              'mountpoint'      =>  'home',
              'manage'          =>  false
            },
          }
        }
      end
      it 'should contain auto.home with null option' do
        should contain_file('auto.master').with_content(/^\s*\/home -null$/)
      end
    end
    context 'should not load NIS maps' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :group    => 'foo',
        }
      end
      let :params do
        {
          :maps =>
          {
            'home' =>
            {
              'mountpoint'      =>  'home'
            },
          },
          :use_nis_maps => false
        }
      end
      it 'should contain auto.home' do
        should contain_file('auto.master').with_content(/^\s*\/home \/etc\/auto.home$/)
      end
      it 'should not contain +auto.master' do
        should_not contain_file('auto.master').with_content(/^\+auto.master$/)
      end
    end
  end
end
