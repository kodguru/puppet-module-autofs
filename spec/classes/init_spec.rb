require 'spec_helper'

describe 'autofs' do
  let :facts do
    {
      :osfamily => 'RedHat',
      :group    => 'foo',
      :fqdn     => 'foo.example.com',
    }
  end

  platforms = {
    'RedHat' =>
      {
        :autofs_package           => 'autofs',
        :autofs_service           => 'autofs',
        :autofs_sysconfig         => '/etc/sysconfig/autofs',
        :autofs_sysconfig_fixture => 'files/autofs.linux',
        :autofs_auto_master       => '/etc/auto.master',
      },
    'Suse' =>
      {
        :autofs_package           => 'autofs',
        :autofs_service           => 'autofs',
        :autofs_sysconfig         => '/etc/sysconfig/autofs',
        :autofs_sysconfig_fixture => 'files/autofs.linux',
        :autofs_auto_master       => '/etc/auto.master',
      },
    'Debian' =>
      {
        :autofs_package           => 'autofs',
        :autofs_service           => 'autofs',
        :autofs_sysconfig         => '/etc/default/autofs',
        :autofs_sysconfig_fixture => 'files/autofs.linux',
        :autofs_auto_master       => '/etc/auto.master',
      },
    'Solaris' =>
      {
        :autofs_package           => 'SUNWatfsr',
        :autofs_service           => 'autofs',
        :autofs_sysconfig         => '/etc/default/autofs',
        :autofs_sysconfig_fixture => 'files/autofs.solaris',
        :autofs_auto_master       => '/etc/auto_master',
      },
  }

  # full tests of all settings for a valid osfamily
  context 'with defaults for all parameters on supported OS RedHat' do
    it { should compile.with_all_deps }
    it { should contain_class('autofs')}
    it {
      should contain_package('autofs').with({
        'ensure'  => 'installed',
        'name'    => 'autofs',
      })
    }
    it {
      should contain_file('autofs_sysconfig').with({
        'ensure'  => 'file',
        'path'    => '/etc/sysconfig/autofs',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[autofs]',
        'content' => File.read(fixtures('files/autofs.linux')),
      })
    }
    it {
      should contain_file('auto.master').with({
        'ensure'  => 'file',
        'path'    => '/etc/auto.master',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[autofs]',
        'content' => "#{File.read(fixtures('files/auto.master.minimal'))}\n+auto.master\n",
      })
    }
    it {
      should contain_service('autofs').with({
        'ensure'    => 'running',
        'name'      => 'autofs',
        'enable'    => 'true',
        'require'   => 'Package[autofs]',
        'subscribe' => ['File[autofs_sysconfig]','File[auto.master]'],
      })
    }
  end

  # tests of the minimum OS related divergences
  platforms.sort.each do |osfamily,v|
    describe "with defaults for all parameters on supported OS #{osfamily}" do
      let :facts do
        {
          :osfamily => osfamily,
          :group    => 'foo',
        }
      end
      content = File.read(fixtures(v[:autofs_sysconfig_fixture]))

      it { should contain_package('autofs').with_name(v[:autofs_package]) }
      it { should contain_file('autofs_sysconfig').with_path(v[:autofs_sysconfig]) }
      it { should contain_file('autofs_sysconfig').with_content(content) }
      it { should contain_file('auto.master').with_path(v[:autofs_auto_master]) }
      it { should contain_service('autofs').with_name(v[:autofs_service]) }
    end
  end

  context 'on supported OS RedHat' do
    context 'with browse_mode set to valid value <YES>' do
      let(:params) { { :browse_mode => 'YES' } }
      it { should contain_file('autofs_sysconfig').with_content(/^BROWSE_MODE=\"YES\"$/) }
    end

    context 'with timeout set to valid value <242>' do
      let(:params) { { :timeout => '242' } }
      it { should contain_file('autofs_sysconfig').with_content(/^TIMEOUT=242$/) }
    end

    context 'with negative_timeout set to valid value <242>' do
      let(:params) { { :negative_timeout => '242' } }
      it { should contain_file('autofs_sysconfig').with_content(/^NEGATIVE_TIMEOUT=242$/) }
    end

    context 'with mount_wait set to valid value <242>' do
      let(:params) { { :mount_wait => '242' } }
      it { should contain_file('autofs_sysconfig').with_content(/^MOUNT_WAIT=242$/) }
    end

    context 'with umount_wait set to valid value <242>' do
      let(:params) { { :umount_wait => '242' } }
      it { should contain_file('autofs_sysconfig').with_content(/^UMOUNT_WAIT=242$/) }
    end

    context 'with mount_nfs_default_protocol set to valid value <3>' do
      let(:params) { { :mount_nfs_default_protocol => '3' } }
      it { should contain_file('autofs_sysconfig').with_content(/^MOUNT_NFS_DEFAULT_PROTOCOL=3$/) }
    end

    context 'with append_options set to valid value <no>' do
      let(:params) { { :append_options => 'no' } }
      it { should contain_file('autofs_sysconfig').with_content(/^APPEND_OPTIONS=\"no\"$/) }
    end

    context 'with logging set to valid value <verbose>' do
      let(:params) { { :logging => 'verbose' } }
      it { should contain_file('autofs_sysconfig').with_content(/^LOGGING=\"verbose\"$/) }
    end

    context "with maps set to valid value <{'home'=>{'mountpoint'=>'home','mounts'=>['spec nfsserver:/path/to/spec','test nfsserver:/path/to/test']}}>" do
      let(:params) { { :maps => {'home'=>{'mountpoint'=>'home','mounts'=>['spec nfsserver:/path/to/spec','test nfsserver:/path/to/test']}} } }
      it { should have_autofs__map_resource_count(1) }
      it {
        should contain_autofs__map('home').with({
          'mountpoint' => 'home',
          'mounts'     => ['spec nfsserver:/path/to/spec','test nfsserver:/path/to/test']
        })
      }
    end

    describe 'with maps_hiera_merge' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :fqdn     => 'hieramerge.example.local',
          :group    => 'spectest',
        }
      end

      context 'set to valid value <false>' do
        let(:params) { { :maps_hiera_merge => 'false' } }
        it { should have_autofs__map_resource_count(2) }
        it {
          should contain_autofs__map('group').with({
            'mountpoint' => 'group',
            'mounts'     => ['group2 nfsserver:/fqdn/group2']
          })
        }
        it {
          should contain_autofs__map('home_from_fqdn').with({
            'mountpoint' => 'home',
            'mounts'     => ['user2  nfsserver:/fqdn/user2','user3  nfsserver:/fqdn/user3']
          })
        }
      end

      context 'set to valid value <true>' do
        let(:params) { { :maps_hiera_merge => 'true' } }
        it { should have_autofs__map_resource_count(3) }
        it {
          should contain_autofs__map('home_from_fqdn').with({
            'mountpoint' => 'home',
            'mounts'     => ['user2  nfsserver:/fqdn/user2','user3  nfsserver:/fqdn/user3']
          })
        }
        it {
          should contain_autofs__map('home_from_group').with({
            'mountpoint' => 'home',
            'mounts'     => ['user1  nfsserver:/group/user1']
          })
        }
        it {
          should contain_autofs__map('group').with({
            'mountpoint' => 'group',
            'mounts'     => ['group2 nfsserver:/fqdn/group2']
          })
        }
      end
    end

    context 'with autofs_package set to valid value <bikefs>' do
      let(:params) { { :autofs_package => 'bikefs' } }
      it { should contain_package('autofs').with_name('bikefs') }
    end

    context 'with autofs_sysconfig set to valid value </etc/sys/autofs>' do
      let(:params) { { :autofs_sysconfig => '/etc/sys/autofs' } }
      it { should contain_file('autofs_sysconfig').with_path('/etc/sys/autofs') }
    end

    context 'with autofs_auto_master set to valid value </etc/bike.master>' do
      let(:params) { { :autofs_auto_master => '/etc/bike.master' } }
      it { should contain_file('auto.master').with_path('/etc/bike.master') }
    end

    context 'with use_nis_maps set to valid value <false>' do
      let(:params) { { :use_nis_maps => 'false' } }
      it { should contain_file('auto.master').without_content(/\+auto\.master/) }
    end

    context 'with use_dash_hosts_for_net set to valid value <false>' do
      let(:params) { { :use_dash_hosts_for_net => false } }
      it { should contain_file('auto.master').with_content(/\/net \/etc\/auto.net --timeout=60/) }
    end

    context 'with nis_master_name set to valid value <bike.meister>' do
      let(:params) { { :nis_master_name => 'bike.meister' } }
      it { should contain_file('auto.master').with_content(/\+bike\.meister/) }
    end

    context 'with service_ensure set to valid value <stopped>' do
      let(:params) { { :service_ensure => 'stopped' } }
      it { should contain_service('autofs').with_ensure('stopped') }
    end

    context 'with service_enable set to valid value <false>' do
      let(:params) { { :service_enable => 'false' } }
      it { should contain_service('autofs').with_enable('false') }
    end
  end

  context 'on supported OS Solaris' do
    let(:facts) do
      {
        :osfamily => 'Solaris',
        :group    => 'foo',
      }
    end

    context 'with use_dash_hosts_for_net set to valid value <false>' do
      let(:params) { { :use_dash_hosts_for_net => false } }
      it { should contain_file('auto.master').with_content(/\/net \/etc\/auto.net --timeout=60/) }
    end
  end

  context 'auto.master file' do
    let :params do
      { :maps => {
          'home' =>
            { 'mountpoint' => 'home',
              'mounts'     => [ 'server:/home/a' ]
            }
        }
      }
    end
    fixture = File.read(fixtures('files/auto.master.minimal'))

    context 'with one mount managed' do
      it { should contain_file('auto.master').with_content("#{fixture}/home /etc/auto.home\n\n+auto.master\n") }
    end

    context 'with one mount managed and nis maps disabled' do
      let :params do
        { :use_nis_maps => false,
          :maps => {
            'home' =>
              { 'mountpoint' => 'home',
                'mounts'     => [ 'server:/home/a' ]
              }
          }
        }
      end
      it { should contain_file('auto.master').with_content("#{fixture}/home /etc/auto.home\n\n") }
    end

    context 'with one mount managed and options set' do
      let :params do
        { :maps => {
            'home' =>
              { 'mountpoint' => 'home',
                'mounts'     => [ 'server:/home/a' ],
                'options'    => 'ro'
              }
          }
        }
      end
      it { should contain_file('auto.master').with_content("#{fixture}/home /etc/auto.home ro\n\n+auto.master\n") }
    end

    context 'with two mounts managed' do
      let :params do
        { :maps => {
            'home' =>
              { 'mountpoint' => 'home',
                'mounts'     => [ 'server:/home/a' ]
              },
            'data' =>
              { 'mountpoint' => 'data',
                'mounts'     => [ 'server:/data/a' ]
              }
          }
        }
      end
      it { should contain_file('auto.master').with_content("#{fixture}/data /etc/auto.data\n/home /etc/auto.home\n\n+auto.master\n") }
    end

    context 'with two mounts managed and options set on /home' do
      let :params do
        { :maps => {
            'home' =>
              { 'mountpoint' => 'home',
                'mounts'     => [ 'server:/home/a' ],
                'options'    => 'ro'
              },
            'data' =>
              { 'mountpoint' => 'data',
                'mounts'     => [ 'server:/data/a' ]
              }
          }
        }
      end
      it { should contain_file('auto.master').with_content("#{fixture}/data /etc/auto.data\n/home /etc/auto.home ro\n\n+auto.master\n") }
    end
  end

  describe 'running on unsupported OS' do
    let :facts do
      {
        :osfamily => 'WierdOS',
        :group    => 'foo',
      }
    end

    it 'should fail' do
      expect {
        should contain_class(subject)
      }.to raise_error(Puppet::Error,/Operating system family WierdOS is not supported/)
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) { {
      :osfamily => 'RedHat',
      :fqdn     => 'hieramerge.example.local',
      :group    => 'spectest',
    } }
    let(:validation_params) { {
#      :param => 'value',
    } }

    validations = {
# use validate_absolute_path()
#      'absolute_path' => {
#        :name    => ['autofs_sysconfig','autofs_auto_master'],
#        :valid   => ['/absolute/filepath','/absolute/directory/'],
#        :invalid => ['invalid',3,2.42,['array'],a={'ha'=>'sh'}],
#        :message => 'is not an absolute path',
#      },
      'bool_stringified' => {
        :name    => ['maps_hiera_merge','use_nis_maps','use_dash_hosts_for_net','service_enable'],
        :valid   => [true,'true',false,'false'],
        :invalid => [nil,'invalid',3,2.42,['array'],a={'ha'=>'sh'}],
        :message => '(is not a boolean|Unknown type of boolean)',
      },
# use validate_hash()
#      'hash' => {
#        :name    => ['maps'],
#        :valid   => [a={'ha'=>'sh'},a={'test1@test.void'=>'destination1','test2@test.void'=>['destination2','destination3']}],
#        :invalid => [true,false,'invalid',3,2.42,['array']],
#        :message => 'is not a Hash',
#      },
# use validate_integer(value,max,min)
#      'integer' => {
#        :name    => ['timeout','negative_timeout','mount_wait','umount_wait','mount_nfs_default_protocol'],
#        :valid   => ['242','-242'],
#        :invalid => ['invalid',2.42,['array'],a={'ha'=>'sh'}],
#        :message => 'must be an integer',
#      },
      'regex_service_ensure' => {
        :name    => ['service_ensure'],
        :valid   => ['stopped','running'],
        :invalid => ['invalid','true','false',['array'],a={'ha'=>'sh'},3,2.42,true,false,nil],
        :message => '(must be running or stopped|input needs to be a String)',
      },
# add missing validate_string() for 'browse_mode','append_options','logging','autofs_package','autofs_service'
      'string' => {
#        :name    => ['browse_mode','append_options','logging','autofs_package','autofs_service','nis_master_name'],
        :name    => ['nis_master_name'],
        :valid   => ['valid'],
        :invalid => [['array'],a={'ha'=>'sh'}],
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type,var|
      var[:name].each do |var_name|

        var[:valid].each do |valid|
          context "with #{var_name} (#{type}) set to valid #{valid} (as #{valid.class})" do
            let(:params) { validation_params.merge({:"#{var_name}" => valid, }) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { validation_params.merge({:"#{var_name}" => invalid, }) }
            it 'should fail' do
              expect {
                should contain_class(subject)
              }.to raise_error(Puppet::Error,/#{var[:message]}/)
            end
          end
        end

      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
