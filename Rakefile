require "bundler/gem_tasks"

namespace :db do
  desc "Create database for tests"
  task :create do
    puts `createuser -d acts-as-taggable-array-on -U postgres`
    puts `createdb --username=acts-as-taggable-array-on acts-as-taggable-array-on_test`
  end
end
