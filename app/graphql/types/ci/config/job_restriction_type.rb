# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    module Config
      class JobRestrictionType < BaseObject
        graphql_name 'CiConfigJobRestriction'

        field :refs, [GraphQL::STRING_TYPE], null: true,
              description: 'The Git refs for which the job restriction applies.'
      end
    end
  end
end
