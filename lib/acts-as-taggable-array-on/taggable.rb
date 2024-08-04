# frozen_string_literal: true

module ActsAsTaggableArrayOn
  module Taggable
    def self.included(base)
      base.extend(ClassMethod)
    end

    TYPE_MATCHER = {string: "varchar", text: "text", integer: "integer", citext: "citext", uuid: "uuid"}

    module ClassMethod
      def acts_as_taggable_array_on(tag_name, *)
        tag_array_type_fetcher = -> { TYPE_MATCHER[columns_hash[tag_name.to_s].type] }
        parser = ActsAsTaggableArrayOn.parser

        scope :"with_any_#{tag_name}", ->(tags) { where("#{table_name}.#{tag_name} && ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }
        scope :"with_all_#{tag_name}", ->(tags) { where("#{table_name}.#{tag_name} @> ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }
        scope :"without_any_#{tag_name}", ->(tags) { where.not("#{table_name}.#{tag_name} && ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }
        scope :"without_all_#{tag_name}", ->(tags) { where.not("#{table_name}.#{tag_name} @> ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }

        self.class.class_eval do
          define_method :"all_#{tag_name}" do |options = {}, &block|
            # Handles the unique case of prepending method with "where("tag like ?", "aws%")"
            missing_like_tag_prepend = current_scope&.where_clause&.send(:predicates)&.none? { |pred| pred.to_s.include?("tag like") }
            if current_scope && missing_like_tag_prepend
              # For relations
              current_scope.pluck(tag_name).flatten.uniq
            else
              # For classes
              subquery_scope = unscoped.select("unnest(#{table_name}.#{tag_name}) as tag").distinct
              subquery_scope = subquery_scope.instance_eval(&block) if block
              # Remove the STI inheritance type from the outer query since it is in the subquery
              unscope(where: :type).from(subquery_scope).pluck(:tag)
            end
          end

          define_method :"#{tag_name}_cloud" do |options = {}, &block|
            # Handles the unique case of prepending method with "where("tag like ?", "aws%")"
            missing_like_tag_prepend = current_scope&.where_clause&.send(:predicates)&.none? { |pred| pred.to_s.include?("tag like") }
            if current_scope && missing_like_tag_prepend
              # For relations
              current_scope.pluck(tag_name).flatten.group_by(&:itself).transform_values(&:count)
            else
              # For classes
              subquery_scope = unscoped.select("unnest(#{table_name}.#{tag_name}) as tag")
              subquery_scope = subquery_scope.instance_eval(&block) if block
              # Remove the STI inheritance type from the outer query since it is in the subquery
              unscope(where: :type).from(subquery_scope).group(:tag).order(:tag).count(:tag)
            end
          end
        end
      end
      alias_method :taggable_array, :acts_as_taggable_array_on
    end
  end
end
