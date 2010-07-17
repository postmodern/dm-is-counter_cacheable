require 'dm-core'
require 'dm-migrations'

class User

  include DataMapper::Resource
  include DataMapper::Migrations

  property :id, Serial

  property :name, String

  has 0..n, :posts

  has 0..n, :comments, :through => :posts

end
