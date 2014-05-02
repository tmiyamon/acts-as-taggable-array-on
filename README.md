# ActsAsTaggableArrayOn
[![Build Status](https://travis-ci.org/tmiyamon/acts-as-taggable-array-on.svg?branch=master)](https://travis-ci.org/tmiyamon/acts-as-taggable-array-on)

A simple implementation for tagging sysytem with postgres array.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'acts-as-taggable-array-on'
```

And then execute:

```shell
bundle
```


## Setup

To use it, you need to have an array column to act as taggable.

```ruby
class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :tags, array: true, default: '{}'
      t.timestamps
    end
    add_index :users, :tags, using: 'gin'
  end
end
```

and bundle:

```shell
rake db:migrate
```

then

```ruby
class User < ActiveRecord::Base
  acts_as_taggable_array_on :tags
end
@user = User.new(:name => "Bobby")
```

acts_as_taggable_array_on defines 4 scope and 2 class methods as below.

### scopes

- with_any_#{tag_name}
- with_all_#{tag_name}
- without_any_#{tag_name}
- without_all_#{tag_name}

### class methods

- all_#{tag_name}
- #{tag_name}_cloud


## Usage

Set, add and remove

```ruby
#set
@user.tags = ["awesome", "slick"]
@user.tags = '{awesome,slick}'

#add
@user.tags += ["awesome"]
@user.tags += ["awesome", "slick"]

#remove
@user.tags -= ["awesome"]
@user.tags -= ["awesome", "slick"]
```

### Finding Tagged Objects

```ruby
class User < ActiveRecord::Base
  acts_as_taggable_array_on :tags
  scope :by_join_date, ->{order("created_at DESC")}
end

# Find a user with all of the tags
User.with_all_tags("awesome")

# Find a user with any of the tags
User.with_any_tags("awesome")

# Find a user without all of the tags
User.without_all_tags("awesome")

# Find a user without any of the tags
User.without_any_tags("awesome")

# Chain with the other scopes
User.with_any_tags("awesome").without_any_tags("slick").by_join_date.paginate(:page => params[:page], :per_page => 20)
```

### Tag cloud calculations

Calculation to count for each tags is supported. Currently, it does not care its order.

```ruby
User.tags_cloud
# [['awesome' => 1], ['slick' => 2]]
```

### All Tags

Can get all tags easily.

```ruby
User.all_tags
# ['awesome', 'slick']
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/acts-as-taggable-array-on/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
