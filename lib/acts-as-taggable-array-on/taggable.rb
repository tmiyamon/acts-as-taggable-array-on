module ActsAsTaggableArrayOn
  module Taggable
    def self.included(base)
      base.extend(ClassMethod)
    end

    TYPE_MATCHER = { string: 'varchar', text: 'text' }.freeze

    module ClassMethod
      def acts_as_taggable_array_on(*tag_def)
        tag_name = tag_def.first
        parser = ActsAsTaggableArrayOn.parser

        scope :"with_any_#{tag_name}", ->(tags){ where("#{tag_name} && ARRAY[?]::#{column_type(tag_name)}[]", parser.parse(tags)) }
        scope :"with_all_#{tag_name}", ->(tags){ where("#{tag_name} @> ARRAY[?]::#{column_type(tag_name)}[]", parser.parse(tags)) }
        scope :"without_any_#{tag_name}", ->(tags){ where.not("#{tag_name} && ARRAY[?]::#{column_type(tag_name)}[]", parser.parse(tags)) }
        scope :"without_all_#{tag_name}", ->(tags){ where.not("#{tag_name} @> ARRAY[?]::#{column_type(tag_name)}[]", parser.parse(tags)) }

        self.class.class_eval do
          define_method :"all_#{tag_name}" do |options = {}, &block|
            subquery_scope = unscoped.select("unnest(#{table_name}.#{tag_name}) as tag").distinct
            subquery_scope = subquery_scope.instance_eval(&block) if block

            from(subquery_scope).pluck('tag')
          end

          define_method :"#{tag_name}_cloud" do |options = {}, &block|
            subquery_scope = unscoped.select("unnest(#{table_name}.#{tag_name}) as tag")
            subquery_scope = subquery_scope.instance_eval(&block) if block

            from(subquery_scope).group('tag').order('tag').pluck('tag, count(*) as count')
          end
        end
      end

      def column_type(column_name)
        TYPE_MATCHER[columns_hash[column_name.to_s].type]
      end
    end
  end
end
