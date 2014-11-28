# ActsAsTaggableArrayOn
[![Build Status](https://travis-ci.org/tmiyamon/acts-as-taggable-array-on.svg?branch=master)](https://travis-ci.org/tmiyamon/acts-as-taggable-array-on)

A simple implementation for tagging system with postgres array.
So, this gem works only on postgres.


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
      t.string :tags, array: true, default: '{}'
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
User.with_all_tags("awesome, slick")
User.with_all_tags(["awesome", "slick"])

# Find a user with any of the tags
User.with_any_tags("awesome, slick")
User.with_any_tags(["awesome", "slick"])

# Find a user without all of the tags
User.without_all_tags("awesome, slick")
User.without_all_tags(["awesome", "slick"])

# Find a user without any of the tags
User.without_any_tags("awesome, slick")
User.without_any_tags(["awesome", "slick"])

# Chain with the other scopes
User.with_any_tags("awesome").without_any_tags("slick").by_join_date.paginate(:page => params[:page], :per_page => 20)
```

### Tag cloud calculations

Calculation to count for each tags is supported. Currently, it does not care its order.

```ruby
User.tags_cloud
# [['awesome' => 1], ['slick' => 2]]
```

Tag cloud calculation uses subquery internally. To add scopes to the query, use block.

```ruby
User.tags_cloud { where name: ['ken', 'tom'] }
```

To handle the result tags named 'tag' and 'count', prepend scopes.

```ruby
User.where('tag like ?', 'aws%').limit(10).order('count desc').tags_cloud { where name: ['ken', 'tom'] }
```

### All Tags

Can get all tags easily.

```ruby
User.all_tags
# ['awesome', 'slick']
```

As the same to tag cloud calculation, you can use block to add scopes to the query.


```ruby
User.all_tags { where name: ['ken', 'tom'] }
```

To handle the result tags named 'tag', prepend scopes.

```ruby
User.where('tag like ?', 'aws%').all_tags { where name: ['ken', 'tom'] }
```

## Benchmark
Based on the [article](https://adamnengland.wordpress.com/2014/02/19/benchmarks-acts-as-taggable-on-vs-postgresql-arrays/), I built [simple benchmark app](https://github.com/tmiyamon/acts-as-taggable-benchmark/) to compare only the main features acts-as-taggable-array-on has.

This result does NOT insist acts-as-taggable-array-on is better than acts-as-taggable-on since it provides much more features than this gem.
In the case you need simple tag functionality, acts-as-taggable-array-on may be helpful to improve its performance.

```bash
% rake bench:write bench:find_by_id bench:find_by_tag
Deleted all ActsAsTaggableOn::Tag
Deleted all ActsAsTaggableOn::Tagging
Deleted all TaggableUser
Deleted all TaggableArrayUser
Finsihed to clean


###################################################################

bench:write
Rehearsal ---------------------------------------------------------
Using Taggable          6.950000   0.420000   7.370000 (  9.223704)
Using Postgres Arrays   0.710000   0.090000   0.800000 (  1.184734)
------------------------------------------------ total: 8.170000sec

                            user     system      total        real
Using Taggable          5.800000   0.340000   6.140000 (  7.842051)
Using Postgres Arrays   0.680000   0.090000   0.770000 (  1.117812)

###################################################################

bench:find_by_id
Rehearsal ---------------------------------------------------------
Using Taggable          1.490000   0.110000   1.600000 (  2.079776)
Using Postgres Arrays   0.240000   0.030000   0.270000 (  0.419430)
------------------------------------------------ total: 1.870000sec

                            user     system      total        real
Using Taggable          1.440000   0.100000   1.540000 (  2.023188)
Using Postgres Arrays   0.250000   0.040000   0.290000 (  0.434233)

###################################################################

bench:find_by_tag
Rehearsal ---------------------------------------------------------
Using Taggable          0.600000   0.040000   0.640000 (  1.107227)
Using Postgres Arrays   0.060000   0.000000   0.060000 (  0.060019)
------------------------------------------------ total: 0.700000sec

                            user     system      total        real
Using Taggable          0.600000   0.040000   0.640000 (  1.100302)
Using Postgres Arrays   0.030000   0.000000   0.030000 (  0.033001)
rake bench:write bench:find_by_id bench:find_by_tag  20.29s user 1.52s system 77% cpu 28.322 total
```


## Contributing

1. Fork it ( http://github.com/tmiyamon/acts-as-taggable-array-on/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
