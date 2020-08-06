RSpec.configure do |config|
  config.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  config.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  config.default_facts = {
    osfamily: 'RedHat',
    group:    'foo',
    fqdn:     'foo.example.com',
  }
end
