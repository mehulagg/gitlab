# frozen_string_literal: true

module Types
  class NamespaceStatisticsType < BaseObject
    graphql_name 'NamespaceStatistics'

    authorize :read_statistics

    field :storage_size, GraphQL::FLOAT_TYPE, null: false,
          description: 'Storage size of the project in bytes.'
    field :wiki_size, GraphQL::FLOAT_TYPE, null: true,
          description: 'Wiki size of the project in bytes.'
  end
end
