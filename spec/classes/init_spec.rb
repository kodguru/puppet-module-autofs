require 'spec_helper'

describe 'autofs' do
  platforms = {
    'RedHat' =>
      {
        autofs_package:           'autofs',
        autofs_service:           'autofs',
        autofs_sysconfig:         '/etc/sysconfig/autofs',
        autofs_sysconfig_fixture: 'files/autofs.linux',
        autofs_auto_master:       '/etc/auto.master',
      },
    'Suse' =>
      {
        autofs_package:           'autofs',
        autofs_service:           'autofs',
        autofs_sysconfig:         '/etc/sysconfig/autofs',
        autofs_sysconfig_fixture: 'files/autofs.linux',
        autofs_auto_master:       '/etc/auto.master',
      },
    'Debian' =>
      {
        autofs_package:           'autofs',
        autofs_service:           'autofs',
        autofs_sysconfig:         '/etc/default/autofs',
        autofs_sysconfig_fixture: 'files/autofs.linux',
        autofs_auto_master:       '/etc/auto.master',
      },
    'Solaris' =>
      {
        autofs_package:           'SUNWatfsr',
        autofs_service:           'autofs',
        autofs_sysconfig:         '/etc/default/autofs',
        autofs_sysconfig_fixture: 'files/autofs.solaris',
        autofs_auto_master:       '/etc/auto_master',
      },
  }

  auto_master_header = "# This file is being maintained by Puppet.\n# DO NOT EDIT\n\n"

  platforms.sort.each do |osfamily, v|
    describe "with defaults for all parameters on supported OS #{osfamily}" do
      let(:facts) { { osfamily: osfamily } }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('autofs') }

      it {
        is_expected.to contain_package('autofs').with(
          'ensure' => 'installed',
          'name'   => v[:autofs_package],
        )
      }
      it {
        is_expected.to contain_file('autofs_sysconfig').with(
          'ensure'  => 'file',
          'path'    => v[:autofs_sysconfig],
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'Package[autofs]',
          'content' => File.read(fixtures(v[:autofs_sysconfig_fixture])),
        )
      }
      it {
        is_expected.to contain_file('auto.master').with(
          'ensure'  => 'file',
          'path'    => v[:autofs_auto_master],
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'Package[autofs]',
          'content' => "#{auto_master_header}/net -hosts\n\n\n+auto.master\n",
        )
      }
      it {
        is_expected.to contain_service('autofs').with(
          'ensure'    => 'running',
          'name'      => v[:autofs_service],
          'enable'    => 'true',
          'require'   => 'Package[autofs]',
          'subscribe' => ['File[autofs_sysconfig]', 'File[auto.master]'],
        )
      }
    end
  end

  context 'on supported OS RedHat' do
    context 'with browse_mode set to valid value <YES>' do
      let(:params) { { browse_mode: 'YES' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^BROWSE_MODE=\"YES\"$}) }
    end

    context 'with timeout set to valid value <242>' do
      let(:params) { { timeout: '242' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^TIMEOUT=242$}) }
    end

    context 'with negative_timeout set to valid value <242>' do
      let(:params) { { negative_timeout: '242' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^NEGATIVE_TIMEOUT=242$}) }
    end

    context 'with mount_wait set to valid value <242>' do
      let(:params) { { mount_wait: '242' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^MOUNT_WAIT=242$}) }
    end

    context 'with umount_wait set to valid value <242>' do
      let(:params) { { umount_wait: '242' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_content(%r{^UMOUNT_WAIT=242$}) }
    end

    context 'with mount_nfs_default_protocol set to valid value <3>' do
      let(:params) { { mount_nfs_default_protocol: '3' } }

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
      it {
        is_expected.to contain_autofs__map('home').with(
          'mountpoint' => 'home',
          'mounts'     => ['spec nfsserver:/path/to/spec', 'test nfsserver:/path/to/test'],
        )
      }
    end

    describe 'with maps_hiera_merge' do
      let :facts do
        {
          fqdn:     'hieramerge.example.local',
          group:    'spectest',
        }
      end

      context 'set to valid value <false>' do
        let(:params) { { maps_hiera_merge: 'false' } }

        it { is_expected.to have_autofs__map_resource_count(2) }
        it {
          is_expected.to contain_autofs__map('group').with(
            'mountpoint' => 'group',
            'mounts'     => ['group2 nfsserver:/fqdn/group2'],
          )
        }
        it {
          is_expected.to contain_autofs__map('home_from_fqdn').with(
            'mountpoint' => 'home',
            'mounts'     => ['user2  nfsserver:/fqdn/user2', 'user3  nfsserver:/fqdn/user3'],
          )
        }
      end

      context 'set to valid value <true>' do
        let(:params) { { maps_hiera_merge: 'true' } }

        it { is_expected.to have_autofs__map_resource_count(3) }
        it {
          is_expected.to contain_autofs__map('home_from_fqdn').with(
            'mountpoint' => 'home',
            'mounts'     => ['user2  nfsserver:/fqdn/user2', 'user3  nfsserver:/fqdn/user3'],
          )
        }
        it {
          is_expected.to contain_autofs__map('home_from_group').with(
            'mountpoint' => 'home',
            'mounts'     => ['user1  nfsserver:/group/user1'],
          )
        }
        it {
          is_expected.to contain_autofs__map('group').with(
            'mountpoint' => 'group',
            'mounts'     => ['group2 nfsserver:/fqdn/group2'],
          )
        }
      end
    end

    context 'with autofs_package set to valid value <bikefs>' do
      let(:params) { { autofs_package: 'bikefs' } }

      it { is_expected.to contain_package('autofs').with_name('bikefs') }
    end

    context 'with autofs_sysconfig set to valid value </etc/sys/autofs>' do
      let(:params) { { autofs_sysconfig: '/etc/sys/autofs' } }

      it { is_expected.to contain_file('autofs_sysconfig').with_path('/etc/sys/autofs') }
    end

    context 'with autofs_auto_master set to valid value </etc/bike.master>' do
      let(:params) { { autofs_auto_master: '/etc/bike.master' } }

      it { is_expected.to contain_file('auto.master').with_path('/etc/bike.master') }
    end

    context 'with use_nis_maps set to valid value <false>' do
      let(:params) { { use_nis_maps: 'false' } }

      it { is_expected.to contain_file('auto.master').with_content("#{auto_master_header}/net -hosts\n\n\n") }
    end

    context 'with use_dash_hosts_for_net set to valid value <false>' do
      let(:params) { { use_dash_hosts_for_net: false } }

      it { is_expected.to contain_file('auto.master').with_content("#{auto_master_header}/net \/etc\/auto.net --timeout=60\n\n\n+auto.master\n") }
    end

    context 'with nis_master_name set to valid value <bike.meister>' do
      let(:params) { { nis_master_name: 'bike.meister' } }

      it { is_expected.to contain_file('auto.master').with_content("#{auto_master_header}/net -hosts\n\n\n+bike\.meister\n") }
    end

    context 'with service_ensure set to valid value <stopped>' do
      let(:params) { { service_ensure: 'stopped' } }

      it { is_expected.to contain_service('autofs').with_ensure('stopped') }
    end

    context 'with service_enable set to valid value <false>' do
      let(:params) { { service_enable: 'false' } }

      it { is_expected.to contain_service('autofs').with_enable('false') }
    end
  end

  context 'on supported OS Solaris' do
    let(:facts) { { osfamily: 'Solaris' } }

    context 'with use_dash_hosts_for_net set to valid value <false>' do
      let(:params) { { use_dash_hosts_for_net: false } }

      it { is_expected.to contain_file('auto.master').with_content(%r{\/net \/etc\/auto.net --timeout=60}) }
    end
  end

  context 'with maps on RedHat (for auto.master file) set to valid value' do
    head = "# This file is being maintained by Puppet.\n# DO NOT EDIT\n\n/net -hosts\n\n"
    tail = "\n\n+auto.master\n"

    context '<test => {}>' do
      let(:params) { { maps: { 'test' => {} } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/test /etc/auto.test#{tail}") }
    end

    context '<test => { mountpoint => mountpoint }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint /etc/auto.test#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint nis test#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis, manage => false }> maptype overrides manage' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis', 'manage' => false } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint nis test#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, manage => false }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'manage' => false } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint -null#{tail}") }
    end

    # same test as above with options set
    context '<test => { options => ro }>' do
      let(:params) { { maps: { 'test' => { 'options' => 'ro' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/test /etc/auto.test ro#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, options => ro }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'options' => 'ro' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint /etc/auto.test ro#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis, options => ro }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis', 'options' => 'ro' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint nis test ro#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, manage => false, options => ro }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'manage' => false, 'options' => 'ro' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint -null ro#{tail}") }
    end

    # multi mounts example with easy readable result
    context 'which manage five mounts ' do
      example = <<-END.gsub(%r{^\s+\|}, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |
        |/net -hosts
        |
        |/test1 /etc/auto.test1
        |/mountpoint2 /etc/auto.test2
        |/mountpoint3 /etc/auto.test3 ro
        |/mountpoint4 nis test4
        |/mountpoint5 -null
        |
        |+auto.master
      END

      let :params do
        {
          maps: {
            'test1' => {},
            'test2' => { 'mountpoint' => 'mountpoint2' },
            'test3' => { 'mountpoint' => 'mountpoint3', 'options' => 'ro' },
            'test4' => { 'mountpoint' => 'mountpoint4', 'maptype' => 'nis' },
            'test5' => { 'mountpoint' => 'mountpoint5', 'manage' => false },
          },
        }
      end

      it { is_expected.to contain_file('auto.master').with_content(example) }
    end
  end

  # TODO: Discuss and clarify the maptype function on Solaris. Currently maptype is added to output.
  context 'with maps on Solaris (for auto.master file) set to valid value' do
    head = "# This file is being maintained by Puppet.\n# DO NOT EDIT\n\n/net -hosts\n\n"
    tail = "\n\n+auto.master\n"
    let(:facts) { { osfamily: 'Solaris' } }

    context '<test => {}>' do
      let(:params) { { maps: { 'test' => {} } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/test /etc/auto.test#{tail}") }
    end

    context '<test => { mountpoint => mountpoint }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint /etc/auto.test#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint test#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis, manage => false }> maptype overrides manage' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis', 'manage' => false } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint test#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, manage => false }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'manage' => false } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint -null#{tail}") }
    end

    # same test as above with options set
    context '<test => { options => ro }>' do
      let(:params) { { maps: { 'test' => { 'options' => 'ro' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/test /etc/auto.test ro#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, options => ro }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'options' => 'ro' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint /etc/auto.test ro#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, maptype => nis, options => ro }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'maptype' => 'nis', 'options' => 'ro' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint test ro#{tail}") }
    end

    context '<test => { mountpoint => mountpoint, manage => false, options => ro }>' do
      let(:params) { { maps: { 'test' => { 'mountpoint' => 'mountpoint', 'manage' => false, 'options' => 'ro' } } } }

      it { is_expected.to contain_file('auto.master').with_content("#{head}/mountpoint -null ro#{tail}") }
    end

    # multi mounts example with easy readable result
    context 'which manage five mounts ' do
      example = <<-END.gsub(%r{^\s+\|}, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |
        |/net -hosts
        |
        |/test1 /etc/auto.test1
        |/mountpoint2 /etc/auto.test2
        |/mountpoint3 /etc/auto.test3 ro
        |/mountpoint4 test4
        |/mountpoint5 -null
        |
        |+auto.master
      END

      let :params do
        {
          maps: {
            'test1' => {},
            'test2' => { 'mountpoint' => 'mountpoint2' },
            'test3' => { 'mountpoint' => 'mountpoint3', 'options' => 'ro' },
            'test4' => { 'mountpoint' => 'mountpoint4', 'maptype' => 'nis' },
            'test5' => { 'mountpoint' => 'mountpoint5', 'manage' => false },
          },
        }
      end

      it { is_expected.to contain_file('auto.master').with_content(example) }
    end
  end

  describe 'running on unsupported OS' do
    let(:facts) { { osfamily: 'WierdOS' } }

    it 'fails' do
      expect {
        is_expected.to contain_class(:subject)
      }.to raise_error(Puppet::Error, %r{Operating system family WierdOS is not supported})
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let :facts do
      {
        fqdn:     'hieramerge.example.local',
        group:    'spectest',
      }
    end
    let :validation_params do
      {
        #      :param => 'value',
      }
    end

    validations = {
      # use validate_absolute_path()
      #      'absolute_path' => {
      #        :name    => ['autofs_sysconfig','autofs_auto_master'],
      #        :valid   => ['/absolute/filepath','/absolute/directory/'],
      #        :invalid => ['invalid',3,2.42,['array'],a={'ha'=>'sh'}],
      #        :message => 'is not an absolute path',
      #      },
      'bool_stringified' => {
        name:    ['maps_hiera_merge', 'use_nis_maps', 'use_dash_hosts_for_net', 'service_enable'],
        valid:   [true, 'true', false, 'false'],
        invalid: [nil, 'invalid', 3, 2.42, ['array'], { 'ha' => 'sh' }],
        message: '(is not a boolean|Unknown type of boolean)',
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
        name:    ['service_ensure'],
        valid:   ['stopped', 'running'],
        invalid: ['invalid', 'true', 'false', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        message: '(must be running or stopped|input needs to be a String)',
      },
      # add missing validate_string() for 'browse_mode','append_options','logging','autofs_package','autofs_service'
      'string' => {
        #        :name    => ['browse_mode','append_options','logging','autofs_package','autofs_service','nis_master_name'],
        name:    ['nis_master_name'],
        valid:   ['valid'],
        invalid: [['array'], { 'ha' => 'sh' }],
        message: 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:valid].each do |valid|
          context "with #{var_name} (#{type}) set to valid #{valid} (as #{valid.class})" do
            let(:params) { validation_params.merge(:"#{var_name}" => valid) }

            it { is_expected.to compile }
          end
        end

        var[:invalid].each do |invalid|
          context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { validation_params.merge(:"#{var_name}" => invalid) }

            it 'fails' do
              expect {
                is_expected.to contain_class(:subject)
              }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
