# frozen_string_literal: true

module ActsAsTaggableArrayOn
  module Taggable
    class TaggableError < StandardError; end

    class InvalidAllowListTypeError < TaggableError
      def to_s
        "Allow list has to be an array"
      end
    end

    def self.included(base)
      base.extend(ClassMethod)
    end

    TYPE_MATCHER = {string: "varchar", text: "text", integer: "integer"}

    module ClassMethod
      def acts_as_taggable_array_on(tag_name, **args)
        define_allowed_validations!(tag_name, args[:allowed]) if args[:allowed].present?

        tag_array_type_fetcher = -> { TYPE_MATCHER[columns_hash[tag_name.to_s].type] }
        parser = ActsAsTaggableArrayOn.parser

        scope :"with_any_#{tag_name}", ->(tags) { where("#{table_name}.#{tag_name} && ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }
        scope :"with_all_#{tag_name}", ->(tags) { where("#{table_name}.#{tag_name} @> ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }
        scope :"without_any_#{tag_name}", ->(tags) { where.not("#{table_name}.#{tag_name} && ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }
        scope :"without_all_#{tag_name}", ->(tags) { where.not("#{table_name}.#{tag_name} @> ARRAY[?]::#{tag_array_type_fetcher.call}[]", parser.parse(tags)) }

        self.class.class_eval do
          define_method :"all_#{tag_name}" do |options = {}, &block|
            subquery_scope = unscoped.select("unnest(#{table_name}.#{tag_name}) as tag").distinct
            subquery_scope = subquery_scope.instance_eval(&block) if block
            # Remove the STI inheritance type from the outer query since it is in the subquery
            unscope(where: :type).from(subquery_scope).pluck(:tag)
          end

          define_method :"#{tag_name}_cloud" do |options = {}, &block|
            subquery_scope = unscoped.select("unnest(#{table_name}.#{tag_name}) as tag")
            subquery_scope = subquery_scope.instance_eval(&block) if block
            # Remove the STI inheritance type from the outer query since it is in the subquery
            unscope(where: :type).from(subquery_scope).group(:tag).order(:tag).count(:tag)
          end
        end
      end
      alias_method :taggable_array, :acts_as_taggable_array_on

      private

      def define_allowed_validations!(tag_name, allowed)
        raise InvalidAllowListTypeError if !allowed.is_a?(Array)

        define_method :"#{tag_name}_allowed" do
          allowed.map(&:to_s)
        end
        private :"#{tag_name}_allowed"

        validate :"#{tag_name}_permitted"

        define_method :"#{tag_name}_permitted" do
          return unless send(tag_name).any? { |i| !send(:"#{tag_name}_allowed").include?(i.to_s) }

          errors.add(:"#{tag_name}", "allowed values are #{send(:"#{tag_name}_allowed").to_sentence}")
        end
      end
    end
  end
end
