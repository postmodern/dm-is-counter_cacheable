require 'dm-core'
require 'dm-migrations'

class Comment

  include DataMapper::Resource
  include DataMapper::Migrations

  is :counter_cacheable

  property :id, Serial

  property :body, Text

  belongs_to :post

  belongs_to :user

  counter_cacheable :post
  counter_cacheable :user, :counter_property => :post_comments_count

end
