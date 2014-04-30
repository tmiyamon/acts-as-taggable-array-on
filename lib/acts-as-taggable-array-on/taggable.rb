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
          define_method :"all_#{tag_name}" do
            all.uniq.pluck("unnest(#{tag_name})")
          end

          define_method :"#{tag_name}_cloud" do
            from(select("unnest(#{tag_name}) as tag")).group('tag').order('tag').pluck('tag, count(*) as count')
          end
        end
      end
    end
  end
end
