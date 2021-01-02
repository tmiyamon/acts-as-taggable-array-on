# ActsAsTaggableArrayOn
[![Build Status](https://travis-ci.org/tmiyamon/acts-as-taggable-array-on.svg?branch=master)](https://travis-ci.org/tmiyamon/acts-as-taggable-array-on)

A simple implementation for tagging system with postgres array. Only PostgreSQL is supported.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "acts-as-taggable-array-on"
```

And then execute:

```shell
bundle
```


## Setup
To use it, you need to have an array column to act as taggable - `tags`. 

```ruby
class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :tags, array: true, default: []
      t.timestamps
    end
    add_index :users, :tags, using: "gin"
  end
end
```

- You can change from `string` to any other type here. But in case of any doubt, `string` is a great default.
- Make sure not to lose `default: []`, it's important to always have empty array as default.

Run a migration:

```shell
rake db:migrate
```

Indicate that attribute is "taggable" in a Rails model, like this:

```ruby
class User < ActiveRecord::Base
  taggable_array :tags
end
```

### Types
We currently tested only following types for underlying arrays:

- `varchar[]`
  - `t.string :tags, array: true, default: []`
  - `add_column :users, :tags, :string, array: true, default: []`
- `text[]`
  - `t.text :tags, array: true, default: []`
  - `add_column :users, :tags, :text, array: true, default: []`
- `integer[]`
  - `t.integer :tags, array: true, default: []`
  - `add_column :users, :tags, :integer, array: true, default: []`


## Usage

```ruby
#set
user.tags = ["awesome", "slick"]
user.tags = "{awesome,slick}"

#add
user.tags += ["awesome"]
user.tags += ["awesome", "slick"]
user.tags << "awesome"

#remove
user.tags -= ["awesome"]
user.tags -= ["awesome", "slick"]
```

### Scopes

#### `with_any_#{tag_name}`

```ruby
# Find a user with any of the tags
User.with_any_tags("awesome, slick")
User.with_any_tags(["awesome", "slick"])
```

#### `with_all_#{tag_name}`

```ruby
# Find a user with all of the tags
User.with_all_tags("awesome, slick")
User.with_all_tags(["awesome", "slick"])
```

#### `without_any_#{tag_name}`

```ruby
# Find a user without any of the tags
User.without_any_tags("awesome, slick")
User.without_any_tags(["awesome", "slick"])
```

#### `without_all_#{tag_name}`

```ruby
# Find a user without all of the tags
User.without_all_tags("awesome, slick")
User.without_all_tags(["awesome", "slick"])
```


### Class methods

#### `all_#{tag_name}`

```ruby
User.all_tags
# ["awesome", "slick"]
```

You can use block to add scopes to the query.

```ruby
User.all_tags { where(name: ["ken", "tom"]) }
```

Or simply use your existing scopes:

```ruby
# scope :by_join_date, ->{order("created_at DESC")}
User.all_tags.by_join_date
```

SQL field is named "tag" and you can use it to modify the query.

```ruby
User.where("tag like ?", "aws%").all_tags { where(name: ["ken", "tom"]) }
```

#### `#{tag_name}_cloud`

Calculates the number of occurrences of each tag.

```ruby
User.tags_cloud
# [["slick" => 2], ["awesome" => 1]]
```

You can use block to add scopes to the query.

```ruby
User.tags_cloud { where(name: ["ken", "tom"]) }
```

SQL fields are named "tag" and "count" and you can use them to modify the query.

```ruby
User.where("tag like ?", "aws%").limit(10).order("count desc").tags_cloud { where(name: ["ken", "tom"]) }
```


## Benchmark
Based on the [article](https://adamnengland.wordpress.com/2014/02/19/benchmarks-acts-as-taggable-on-vs-postgresql-arrays/), I built [simple benchmark app](https://github.com/tmiyamon/acts-as-taggable-benchmark/) to compare only the main features ActsAsTaggableArrayOn has.

This result does NOT insist ActsAsTaggableArrayOn is better than acts-as-taggable-on since it provides much more features than this gem.
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

## Development

- To run testsuite you'll need to setup local PG database/user with `rake db:create`
After that just running `rspec` should work.
- Before submitting code for a review, please be sure to run `bundle exec standardrb --fix`

## Contributing

1. Fork it ( http://github.com/tmiyamon/acts-as-taggable-array-on/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
