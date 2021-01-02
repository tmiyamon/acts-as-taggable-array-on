require "active_record"

require "acts-as-taggable-array-on/version"
require "acts-as-taggable-array-on/taggable"
require "acts-as-taggable-array-on/parser"

ActiveSupport.on_load(:active_record) do
  include ActsAsTaggableArrayOn::Taggable
end
