$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'active_record/railtie'
ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = 3

require 'acts-as-taggable-array-on'

#Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base; end

RSpec.configure do |config|
  config.before(:all) do
    ActiveRecord::Base.establish_connection(
      adapter: "postgresql",
      encoding: 'unicode',
      database: "acts-as-taggable-array-on_test",
      username: "acts-as-taggable-array-on"
    )
    create_database
  end

  config.after(:all) do
    drop_database
  end

  config.after(:each) do
    User.delete_all
  end
end

def create_database
  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string :name
      t.string :colors, array: true, default: []
      t.timestamps null: true
    end
  end
end

def drop_database
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end
