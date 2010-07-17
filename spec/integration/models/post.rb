require 'dm-core'
require 'dm-migrations'

class Post

  include DataMapper::Resource
  include DataMapper::Migrations

  property :id, Serial

  property :title, String

  property :body, Text

  has 0..n, :comments

  belongs_to :user

end
