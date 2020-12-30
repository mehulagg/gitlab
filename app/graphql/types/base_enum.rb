# frozen_string_literal: true

module Types
  class BaseEnum < GraphQL::Schema::Enum
    extend GitlabStyleDeprecations

    class << self
      # Registers enum values by the given Hash object like
      # the return value of ActiveRecord enum methods.
      def values_from_hash(enum)
        enum.keys.map(&:to_s).each { |val| value(val.upcase, value: val) }
      end

      def value(*args, **kwargs, &block)
        enum[args[0].downcase] = kwargs[:value] || args[0]
        kwargs = gitlab_deprecation(kwargs)

        super(*args, **kwargs, &block)
      end

      # Returns an indifferent access hash with the key being the downcased name of the attribute
      # and the value being the Ruby value (either the explicit `value` passed or the same as the value attr).
      def enum
        @enum_values ||= {}.with_indifferent_access
      end
    end
  end
end
