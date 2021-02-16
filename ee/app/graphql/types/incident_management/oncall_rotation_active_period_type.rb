# frozen_string_literal: true

module Types
  module IncidentManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class OncallRotationActivePeriodType < BaseObject
      graphql_name 'OncallRotationActivePeriodType'
      description 'Active period time range for on-call rotation'

      field :from, GraphQL::STRING_TYPE,
                null: true,
                description: 'The start of the rotation interval.'

      field :to, GraphQL::STRING_TYPE,
                null: true,
                description: 'The end of the rotation interval.'

      def from
        object.start_time&.strftime('%H:%M')
      end

      def to
        object.end_time&.strftime('%H:%M')
      end
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
