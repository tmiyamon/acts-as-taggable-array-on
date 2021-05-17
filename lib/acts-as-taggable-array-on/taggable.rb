# frozen_string_literal: true

module ActsAsTaggableArrayOn
  module Taggable
    def self.included(base)
      base.extend(ClassMethod)
    end

    TYPE_MATCHER = {string: "varchar", text: "text", integer: "integer"}

    module ClassMethod
      def acts_as_taggable_array_on(tag_name, *)
        tag_array_type_fetcher = -> { TYPE_MATCHER[columns_hash[tag_name.to_s].type] }
        parser = ActsAsTaggableArrayOn.parser

        scope :"with_any_#{tag_name}", ->(tags) { where("#{table_name}.#{tag_name} && ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }
        scope :"with_all_#{tag_name}", ->(tags) { where("#{table_name}.#{tag_name} @> ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }
        scope :"without_any_#{tag_name}", ->(tags) { where.not("#{table_name}.#{tag_name} && ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }
        scope :"without_all_#{tag_name}", ->(tags) { where.not("#{table_name}.#{tag_name} @> ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }

        scope :"#{tag_name}_contains", ->(*tags) do
          send("with_any_#{tag_name}", tags)
        end

        self.class.class_eval do
          define_method :"all_#{tag_name}" do |options = {}, &block|
            subquery_scope = unscoped.select("unnest(#{table_name}.#{tag_name}) as tag").distinct
            subquery_scope = subquery_scope.instance_eval(&block) if block

            # this clause is to support models with acts-as-paranoid or paranoia
            if respond_to?(:without_deleted)
              unscope(where: :deleted_at).from(subquery_scope.without_deleted).pluck("tag")
            else
              from(subquery_scope).pluck("tag")
            end
          end

          define_method :"#{tag_name}_cloud" do |options = {}, &block|
            subquery_scope = unscoped.select("unnest(#{table_name}.#{tag_name}) as tag")
            subquery_scope = subquery_scope.instance_eval(&block) if block

            from(subquery_scope).group("tag").order("tag").pluck(Arel.sql("tag, count(*) as count"))
          end

          define_method :"select2_#{tag_name}_search" do |options = {}, search_term|
            t = search_term.try(:split, ' ') || []

            subquery_scope = unscope(:order).order(:tag).select("unnest(#{table_name}.#{tag_name}) as tag").distinct

            q = unscoped.from(subquery_scope).limit(25)
            q = q.where("tag ILIKE ?", "#{t[0]}%") if t[0]
            q = q.where("tag ILIKE ?", "%#{t[1]}") if t[1]

            q.pluck(:tag, 'tag')
          end

        end
      end
      alias_method :taggable_array, :acts_as_taggable_array_on
    end
  end
end
