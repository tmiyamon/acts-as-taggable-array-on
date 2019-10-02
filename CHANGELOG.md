## HEAD
- Drop support for `EOL` versions of Ruby (below `2.4)`, and Rails (below `5.2`)
- Alias `acts_as_taggable_on` to `taggable_array`

## 0.5.1
- Don't fail during load time if DB is missing

## 0.5
- Don't fail if table is not defined
- Defines columns ambiguously, so table joins would work
