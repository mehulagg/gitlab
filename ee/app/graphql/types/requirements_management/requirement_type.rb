# frozen_string_literal: true

module Types
  module RequirementsManagement
    class RequirementType < BaseObject
      graphql_name 'Requirement'
      description 'Represents a requirement'

      authorize :read_requirement

      expose_permissions Types::PermissionTypes::Requirement

      field :id, GraphQL::ID_TYPE, null: false,
            description: 'ID of the requirement'

      field :iid, GraphQL::ID_TYPE, null: false,
            description: 'Internal ID of the requirement'

      field :title, GraphQL::STRING_TYPE, null: true,
            description: 'Title of the requirement'
      markdown_field :title_html, null: true

      field :description, GraphQL::STRING_TYPE, null: true,
            description: 'Description of the requirement'
      markdown_field :description_html, null: true

      field :state, RequirementsManagement::RequirementStateEnum, null: false,
            description: 'State of the requirement'

      field :last_test_report_state, RequirementsManagement::TestReportStateEnum, null: true, complexity: 5,
            description: 'Latest requirement test report state'

      field :last_test_report_manually_created,
            GraphQL::BOOLEAN_TYPE,
            method: :last_test_report_manually_created?,
            null: true,
            complexity: 5,
            description: 'Indicates if latest test report was created by user'

      field :project, ProjectType, null: false,
            description: 'Project to which the requirement belongs',
            resolve: -> (obj, _args, _ctx) { Gitlab::Graphql::Loaders::BatchModelLoader.new(Project, obj.project_id).find }

      field :author, UserType, null: false,
            description: 'Author of the requirement',
            resolve: -> (obj, _args, _ctx) { Gitlab::Graphql::Loaders::BatchModelLoader.new(User, obj.author_id).find }

      field :test_reports, TestReportType.connection_type, null: true, complexity: 5,
            description: 'Test reports of the requirement',
            resolver: Resolvers::RequirementsManagement::TestReportsResolver

      field :created_at, Types::TimeType, null: false,
            description: 'Timestamp of when the requirement was created'

      field :updated_at, Types::TimeType, null: false,
            description: 'Timestamp of when the requirement was last updated'
    end
  end
end
