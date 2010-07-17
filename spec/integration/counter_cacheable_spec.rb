require 'spec_helper'

describe DataMapper::Is::CounterCacheable do
  before(:all) do
    User.create(
      :name => 'bob',
      :posts => [
        {:title => 'Hello', :body => 'Hello there.'}
      ]
    )

    @user = User.first
    @post = @user.posts.first
  end

  it "should define the default counter cache property" do
    Post.properties.should be_named('comments_counter')
  end

  it "should allow defining custom named counter cache properties" do
    User.properties.should be_named('post_comments_counter')
  end

  it "should have a counter cache of 0 by default" do
    @post.comments_counter.should == 0
  end
end
