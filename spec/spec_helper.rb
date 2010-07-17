require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:runtime, :test)
rescue Bundler::BundlerError => e
  STDERR.puts e.message
  STDERR.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'spec'
require 'dm-core/spec/setup'
require 'dm-core/spec/lib/adapter_helpers'

require 'dm-is-counter_cacheable'

require 'integration/models/user'
require 'integration/models/post'
require 'integration/models/comment'

DataMapper::Spec.setup

Spec::Runner.configure do |config|
  config.extend(DataMapper::Spec::Adapters::Helpers)

  config.before(:suite) do
    DataMapper.auto_migrate!
  end
end
