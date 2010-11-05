require 'rspec'
require 'dm-core/spec/setup'
require 'dm-core/spec/lib/adapter_helpers'

require 'dm-is-counter_cacheable'

require 'integration/models/user'
require 'integration/models/post'
require 'integration/models/comment'

DataMapper::Spec.setup

RSpec.configure do |config|
  config.extend(DataMapper::Spec::Adapters::Helpers)
end
