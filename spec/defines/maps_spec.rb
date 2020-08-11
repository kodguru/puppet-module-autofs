require 'spec_helper'
describe 'autofs::map' do
  let(:title) { 'example' }
  let(:facts) { { osfamily: 'RedHat' } }

  context 'with default values for parameters on valid OS' do
    it { is_expected.to compile.with_all_deps }
    it {
      is_expected.to contain_file('mountmap_example').with(
        'ensure'  => 'file',
        'path'    => '/etc/auto.example',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n\n",
      )
    }
  end

  context 'with optional parameters set' do
    context 'with mounts set to valid array <[\'spec srv:/path/spec\',\'test srv:/path/test\']>' do
      let(:params) { { mounts: ['spec srv:/path/spec', 'test srv:/path/test'] } }

      it {
        is_expected.to contain_file('mountmap_example').with('content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n\nspec srv:/path/spec\ntest srv:/path/test\n")
      }
    end

    # enhancement: move conditional logic from template to code
    context 'with mounts set to valid string <spectest server:/spec/test]>' do
      let(:params) { { mounts: ['spectest server:/spec/test'] } }

      it {
        is_expected.to contain_file('mountmap_example').with('content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n\nspectest server:/spec/test\n")
      }
    end

    context 'with file set to <puppet:///files/autofs/specific.map>' do
      let(:params) { { file: 'puppet:///files/autofs/specific.map' } }

      it {
        is_expected.to contain_file('mountmap_example').with(
          'ensure' => 'file',
          'path'   => '/etc/auto.example',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
          'source' => 'puppet:///files/autofs/specific.map',
        )
      }
    end
  end

  context 'with ignoreable parameters set' do
    # $autofs::maps is also used for auto.master template
    # these parameters are not functional here
    # they are needed to avoid "invalid parameter options" errors
    ['mountpoint', 'maptype', 'manage', 'options'].each do |param|
      context "with #{param} set to <unneeded>" do
        let(:params) { { :"#{param}" => 'unneeded' } }

        it {
          is_expected.to contain_file('mountmap_example').with(
            'ensure' => 'file',
            'path'    => '/etc/auto.example',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n\n",
          )
        }
      end
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:title) { 'example' }
    let(:facts) do
      {
        osfamily: 'RedHat',
      }
    end
    let(:validation_params) do
      {
        #      :param => 'value',
      }
    end

    validations = {
      # use validate_hash()
      #      'hash' => {
      #        :name    => ['mounts'],
      #        :valid   => [ ['hello','spectest'],],
      #        :invalid => [true,false,'invalid',3,2.42,['array']],
      #        :message => 'is not a Hash',
      #      },
      # use validate_string()
      #      'string' => {
      #        :name    => ['mounts'],
      #        :valid   => ['hello spectest'],
      #        :invalid => [['array'],a={'ha'=>'sh'},3,2.42,true,false],
      #        :message => 'must be a string',
      #      },
      # use validate_string()
      #      'string_file_source' => {
      #        :name    => ['file'],
      #        :valid   => ['puppet:///files/autofs/specific.map'],
      #        :invalid => [['array'],a={'ha'=>'sh'},3,2.42,true,false],
      #        :message => 'must be a string',
      #      },
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
                is_expected.to contain_define(:subject)
              }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
