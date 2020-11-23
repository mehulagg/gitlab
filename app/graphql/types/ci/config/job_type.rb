# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    module Config
      class JobType < BaseObject
        graphql_name 'CiConfigJobs'

        field :name, GraphQL::STRING_TYPE, null: true,
              description: 'Name of the job'
        field :needs, [Types::Ci::Config::NeedType], null: true,
              description: 'Builds that must complete before the jobs run'
      end
    end
  end
end
