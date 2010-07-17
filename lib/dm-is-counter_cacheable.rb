require 'dm-core'
require 'dm-is-counter_cacheable/is/counter_cacheable'

DataMapper::Model.append_extensions DataMapper::Is::CounterCacheable
