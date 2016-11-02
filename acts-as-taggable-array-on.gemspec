# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts-as-taggable-array-on/version'

Gem::Specification.new do |spec|
  spec.name          = "acts-as-taggable-array-on"
  spec.version       = ActsAsTagPgarray::VERSION
  spec.authors       = ["Takuya Miyamoto"]
  spec.email         = ["miyamototakuya@gmail.com"]
  spec.summary       = %q{Simple tagging gem for Rails using postgres array.}
  spec.description   = %q{Simple tagging gem for Rails using postgres array.}
  spec.homepage      = "https://github.com/tmiyamon/acts-as-taggable-array-on"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activerecord',  ['>= 4']
  spec.add_runtime_dependency 'activesupport', ['>= 4']

  spec.add_development_dependency 'pg'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "listen",  "~> 3.0.0"
end
