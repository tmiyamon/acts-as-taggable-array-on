module ActsAsTaggableArrayOn
  module Taggable
    def self.included(base)
      base.extend(ClassMethod)
    end

    module ClassMethod
      def acts_as_taggable_array_on(*tag_def)
        tag_name = tag_def.first

        scope :"with_any_#{tag_name}", ->(* tags){where("#{tag_name} && ARRAY[?]", tags)}
        scope :"with_all_#{tag_name}", ->(* tags){where("#{tag_name} @> ARRAY[?]", tags)}
        scope :"without_any_#{tag_name}", ->(* tags){where.not("#{tag_name} && ARRAY[?]", tags)}
        scope :"without_all_#{tag_name}", ->(* tags){where.not("#{tag_name} @> ARRAY[?]", tags)}

        self.class.class_eval do
          define_method :"all_#{tag_name}" do |options = {}, &block|
            query_scope = all
            query_scope = query_scope.merge(instance_eval(&block)) if block

            query_scope.uniq.pluck("unnest(#{table_name}.#{tag_name})")
          end

          define_method :"#{tag_name}_cloud" do |options = {}, &block|
            query_scope = select("unnest(#{table_name}.#{tag_name}) as tag")
            query_scope = query_scope.merge(instance_eval(&block)) if block

            from(query_scope).group('tag').order('tag').pluck('tag, count(*)')
          end
        end
      end
    end
  end
end
