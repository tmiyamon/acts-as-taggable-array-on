## Unreleased
- Standard linter used as a style guide
- Ruby 2.4 support dropped
- Support for Ruby 3.0 added
- Support for Rails 6.1 added
- Adds validate option using allow list to define allowed tags

## 0.6
- Drop support for `EOL` versions of Ruby (below `2.4)`, and Rails (below `5.2`)
- Alias `acts_as_taggable_on` to `taggable_array`
- Stop rails 6 deprecation warnings

## 0.5.1
- Don't fail during load time if DB is missing

## 0.5
- Don't fail if table is not defined
- Defines columns ambiguously, so table joins would work
