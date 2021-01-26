# frozen_string_literal: true

module Types
  module CiConfiguration
    module ApiFuzzing
      class ScanProfile < BaseObject
        graphql_name 'ApiFuzzingScanProfile'

        field :name, GraphQL::STRING_TYPE, null: true,
              description: 'The unique name of the profile.'

        field :description, GraphQL::STRING_TYPE, null: true,
              description: 'A short description of the profile.'

        field :yaml, GraphQL::STRING_TYPE, null: true,
              description: 'The stringified YAML implementation of the profile.'
      end
    end
  end
end
