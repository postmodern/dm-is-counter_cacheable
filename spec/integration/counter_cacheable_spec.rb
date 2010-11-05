require 'spec_helper'

describe DataMapper::Is::CounterCacheable do
  before(:all) do
    DataMapper.auto_migrate!

    User.create(
      :name => 'bob',
      :posts => [
        {:title => 'Hello', :body => 'Hello there.'}
      ]
    )
  end

  before(:each) do
    @user = User.first
    @post = @user.posts.first
  end

  it "should define the default counter cache property" do
    Post.properties.should be_named('comments_counter')
  end

  it "should allow defining custom named counter cache properties" do
    User.properties.should be_named('post_comments_counter')
  end

  it "should optionally define a counter index column" do
    Comment.properties.should be_named('user_comments_index')
  end

  it "should have a counter cache of 0 by default" do
    @post.comments_counter.should == 0
  end

  it "should increment the counter cache by 1 when a new resource is created" do
    orig_counter = @post.comments_counter

    @post.comments.create(
      :body => 'lol',
      :user => @user
    )

    new_counter = @post.comments_counter

    (new_counter - orig_counter).should == 1
  end

  it "should increment the counter cache by 1 when a new resource is saved" do
    orig_counter = @post.comments_counter

    @post.comments.new(
      :body => 'omg',
      :user => @user
    ).save

    new_counter = @post.comments_counter

    (new_counter - orig_counter).should == 1
  end

  it "should set the counter index to the counter value when a new resource is created" do
    @post.comments.create(
      :body => 'lol',
      :user => @user
    )

    @post.comments.last.user_comments_index.should == @user.post_comments_counter
  end

  it "should decrement the counter cache by 1 when a resource is destroyed" do
    @post.comments.create(
      :body => 'wtf',
      :user => @user
    )

    orig_counter = @post.comments_counter

    @post.comments.first.destroy

    new_counter = @post.comments_counter

    (new_counter - orig_counter).should == -1
  end
end
