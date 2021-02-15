# frozen_string_literal: true

module Types
  module IncidentManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class OncallRotationActivePeriodInputType < BaseInputObject
      graphql_name 'OncallRotationActivePeriodInputType'
      description 'Active period time range for on-call rotation'

      argument :from, GraphQL::STRING_TYPE,
                required: true,
                description: 'The start of the rotation interval.'

      argument :to, GraphQL::STRING_TYPE,
                required: true,
                description: 'The end of the rotation interval.'

      TIME_FORMAT = %r[^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$].freeze

      def prepare
        raise invalid_time_error unless TIME_FORMAT.match?(from)
        raise invalid_time_error unless TIME_FORMAT.match?(to)

        parsed_from = Time.parse(from)
        parsed_to = Time.parse(to)

        if parsed_to < parsed_from
          raise ::Gitlab::Graphql::Errors::ArgumentError, "'from' time must be before 'to' time"
        end

        to_h
      end

      private

      def invalid_time_error
        ::Gitlab::Graphql::Errors::ArgumentError.new 'Time given is invalid'
      end
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
