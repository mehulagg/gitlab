# frozen_string_literal: true
# rubocop:disable Graphql/AuthorizeTypes

module Types
  module Admin
    module Analytics
      module DevopsAdoption
        class SnapshotType < BaseObject
          graphql_name 'DevopsAdoptionSnapshot'
          description 'Snapshot'

          field :issue_opened, GraphQL::BOOLEAN_TYPE, null: false,
                description: 'An issue was opened in the last 30 days'
          field :merge_request_opened, GraphQL::BOOLEAN_TYPE, null: false,
                description: 'A merge request was opened in the last 30 days'
          field :merge_request_approved, GraphQL::BOOLEAN_TYPE, null: false,
                description: 'A merge request was opened in the last 30 days'
          field :runner_configured, GraphQL::BOOLEAN_TYPE, null: false,
                description: 'A runner was used in the last 30 days'
          field :pipeline_succeeded, GraphQL::BOOLEAN_TYPE, null: false,
                description: 'A pipeline was succeeded in the last 30 days'
          field :deploy_succeeded, GraphQL::BOOLEAN_TYPE, null: false,
                description: 'A deployment was succeeded in the last 30 days'
          field :security_scan_succeeded, GraphQL::BOOLEAN_TYPE, null: false,
                description: 'A security scan was succeeded in the last 30 days'
          field :recorded_at, Types::TimeType, null: false,
                description: 'The time the snapshot was recorded'
        end
      end
    end
  end
end
