require 'active_record'

require "acts-as-taggable-array-on/version"
require "acts-as-taggable-array-on/taggable"

ActiveSupport.on_load(:active_record) do
  include ActsAsTaggableArrayOn::Taggable
end
