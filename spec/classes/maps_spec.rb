require 'spec_helper'

describe 'autofs' do
  describe 'mountmap' do
    context 'defines /home' do
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
    context 'defines two mountpoints' do
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
              'mounts'     => [ 'server:/data/a', 'server:/data/b', 'server:/data/c']
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
        should contain_file('auto.master').with_content(/^\s*\/data \/etc\/auto.data$/)
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
  end
end


