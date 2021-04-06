# frozen_string_literal: true

module Types
  class StringOrIntType < BaseScalar
    graphql_name 'StringOrInt'
    description 'String or integer.'

    def self.coerce_input(value, ctx)
      return value if value.is_a?(::Integer)

      GraphQL::STRING_TYPE.coerce_input(value, ctx)
    end

    def self.coerce_result(value, ctx)
      return value if value.is_a?(::Integer)

      GraphQL::STRING_TYPE.coerce_result(value, ctx)
    end
  end
end
