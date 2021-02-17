# frozen_string_literal: true

module Types
  module Ci
    class CiCdSettingType < BaseObject
      graphql_name 'ProjectCiCdSetting'

      authorize :admin_project

      field :keep_latest_artifact, GraphQL::BOOLEAN_TYPE, null: true,
        description: 'Whether to keep the latest builds artifacts.',
        method: :keep_latest_artifacts_available?
      field :project, Types::ProjectType, null: true,
        description: 'Project the CI/CD settings belong to.'
    end
  end
end

Types::Ci::CiCdSettingType.prepend_if_ee('EE::Types::Ci::CiCdSettingType')
