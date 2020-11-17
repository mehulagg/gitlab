# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    module Config
      class GroupType < BaseObject
        graphql_name 'CiConfigGroup'

        field :name, GraphQL::STRING_TYPE, null: true,
              description: 'Name of the job group'
        field :jobs, [Types::Ci::Config::JobType], null: true,
              description: 'Jobs in group'
      end
    end
  end
end

