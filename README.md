# dm-is-countercacheable

* [Source](http://github.com/postmodern/dm-is-counter_cacheable)
* [Issues](http://github.com/postmodern/dm-is-counter_cacheable/issues)
* [Docuementation](http://rubydoc.info/gems/dm-is-counter_cacheable)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

A DataMapper plugin for adding counter-cache properties to related models.

## Example

Adds counter properties to Post and User for the number of comments:

    require 'dm-core'
    
    class Comment
    
      include DataMapper::Resource
    
      is :counter_cacheable
    
      property :id, Serial
    
      property :body, Text
    
      belongs_to :post
    
      belongs_to :user
    
      counter_cacheable :post
      counter_cacheable :user, :counter_property => :post_comments_counter
    
    end

## Requirements

* [dm-core](http://github.com/datamapper/dm-core/) ~> 1.0

## Install

    $ sudo gem install dm-is-countercacheable

## License

Copyright (c) 2008-2011 Hal Brodigan

See {file:LICENSE.txt} for license information.
