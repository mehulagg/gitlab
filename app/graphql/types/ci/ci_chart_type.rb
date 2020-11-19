# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class CiChartType < BaseObject
      graphql_name 'CiChart'

      field :total_pipeline_count, GraphQL::INT_TYPE, null: false,
            description: 'Total pipelines created'
    end
  end
end
