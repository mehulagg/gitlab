# frozen_string_literal: true

module Types
  # Keep in mind when using this type, that it is not recommended to use it
  # when the structure of the JSON data is known beforehand.
  # More info here:
  # https://docs.gitlab.com/ee/development/api_graphql_styleguide.html#json
  class JsonStringType < BaseScalar
    graphql_name 'JsonString'
    description 'JSON object as raw string'

    def self.coerce_input(value, _ctx)
      ::Gitlab::Json.parse!(value)
    rescue JSON::ParserError => e
      raise GraphQL::CoercionError, "Invalid JSON string: #{e.message}"
    end

    def self.coerce_result(value, _ctx)
      value.to_json
    end
  end
end
