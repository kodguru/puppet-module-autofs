require 'spec_helper'
describe 'autofs::map' do
  head = <<-END.gsub(%r{^\s+\|}, '')
    |# This file is being maintained by Puppet.
    |# DO NOT EDIT
    |
  END

  let(:title) { 'example' }

  on_supported_os.sort.each do |os, os_facts|
    describe "on #{os} with default values for parameters" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it do
        is_expected.to contain_file('autofs__map_mountmap_example').only_with(
          'ensure'  => 'file',
          'path'    => '/etc/auto.example',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => head,
        )
      end

      it do
        is_expected.to contain_concat__fragment('auto.master_example').only_with(
          'target'  => 'auto.master',
          'content' => "/example /etc/auto.example\n",
          'order'   => '10',
        )
      end

      it do
        is_expected.to contain_concat__fragment('auto.master_linebreak').only_with(
          'target'  => 'auto.master',
          'content' => "\n",
          'order'   => '98',
        )
      end
    end

    describe "on #{os} with functional parameters set" do
      context 'on #{os} with mounts set to valid array <[spec srv:/path/spec\, test srv:/path/test]>' do
        let(:params) { { mounts: ['spec srv:/path/spec', 'test srv:/path/test'] } }

        it {
          is_expected.to contain_file('autofs__map_mountmap_example').with('content' => "#{head}spec srv:/path/spec\ntest srv:/path/test\n")
        }
      end

      context 'with mounts set to valid string <spectest server:/spec/test]>' do
        let(:params) { { mounts: ['spectest server:/spec/test'] } }

        it {
          is_expected.to contain_file('autofs__map_mountmap_example').with('content' => "#{head}spectest server:/spec/test\n")
        }
      end

      context 'with file set to <puppet:///files/autofs/specific.map>' do
        let(:params) { { file: 'puppet:///files/autofs/specific.map' } }

        it {
          is_expected.to contain_file('autofs__map_mountmap_example').only_with(
            'ensure' => 'file',
            'path'   => '/etc/auto.example',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
            'source' => 'puppet:///files/autofs/specific.map',
          )
        }
      end

      context 'with mappath set to valid string </test/ing>' do
        let(:params) { { mappath: '/test/ing' } }

        it {
          is_expected.to contain_file('autofs__map_mountmap_example').with('path' => '/test/ing')
        }
      end

      context 'with mapname set to valid string <string>' do
        let(:params) { { mapname: 'string' } }

        it {
          is_expected.to contain_file('autofs__map_string')
        }
      end

      context 'with manage_content set to false' do
        let(:params) { { manage_content: false } }

        it do
          is_expected.to contain_file('autofs__map_mountmap_example').with('content' => nil)
        end
      end
    end

    describe "on #{os} with non-functional parameters set" do
      # $autofs::maps is also used for auto.master template.
      # The following parameters are not used in autofs::map.
      # But they need to exist to avoid "invalid parameter options" errors.
      ['mountpoint', 'maptype', 'manage', 'options'].each do |param|
        context "with #{param} set to <unneeded>" do
          let(:params) { { "#{param}": 'unneeded' } }

          it {
            is_expected.to contain_file('autofs__map_mountmap_example').only_with(
              'ensure' => 'file',
              'path'    => '/etc/auto.example',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => head,
            )
          }
        end
      end
    end
  end

  describe 'variable type and content validations' do
    # The following tests are OS independent, so we only test one supported OS
    redhat = {
      supported_os: [
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['7'],
        },
      ],
    }

    on_supported_os(redhat).each do |_os, os_facts|
      let(:facts) { os_facts }
      # set needed custom facts and variables
      let(:title) { 'example' }

      validations = {
        'Array' => {
          name:    ['mounts'],
          valid:   [['array']],
          invalid: ['string', { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects an Array',
        },
        'Optional[Stdlib::Absolutepath]' => {
          name:    ['mappath'],
          valid:   ['/absolute/filepath', '/absolute/directory/'],
          invalid: ['../invalid', 3, 2.42, ['array'], { 'ha' => 'sh' }, false],
          message: 'expects a Stdlib::Absolutepath',
        },
        'Optional[Stdlib::Filesource]' => {
          name:    ['file'],
          valid:   ['puppet:///test', '/test/ing', 'file:///test/ing'],
          invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects a Stdlib::Filesource',
        },
        'Optional[String[1]]' => {
          name:    ['mapname'],
          valid:   ['string'],
          invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects a value of type Undef or String,',
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
end
