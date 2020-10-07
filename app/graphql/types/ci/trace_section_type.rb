# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable GraphQL/AuthorizeTypes
    class TraceSectionType < BaseObject
      graphql_name 'TraceSection'

      # Only accessible through pipeline
      # authorize :read_pipeline

      field :name, GraphQL::STRING_TYPE, null: true,
            description: 'Name of the section'
      field :byte_start, GraphQL::INT_TYPE, null: true,
            description: 'Start index of the section'
      field :byte_end, GraphQL::INT_TYPE, null: true,
            description: 'End index of the section'
      field :date_start, ::Types::TimeType, null: true,
            description: 'Time that the section started'
      field :date_end, ::Types::TimeType, null: true,
            description: 'Time that the section ended'

      def date_start
        time(:date_start)
      end

      def date_end
        time(:date_end)
      end

      def time(key)
        return unless object[key].present?

        Time.parse(object[key])
      end
    end
    # rubocop: enable GraphQL/AuthorizeTypes
  end
end
