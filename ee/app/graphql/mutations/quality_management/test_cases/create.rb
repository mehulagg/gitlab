# frozen_string_literal: true

module Mutations
  module QualityManagement
    module TestCases
      class Create < BaseMutation
        include ResolvesProject

        graphql_name 'CreateTestCase'

        authorize :admin_issue

        argument :title, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The test case title.'

        argument :description, GraphQL::STRING_TYPE,
                 required: false,
                 description: 'The test case description.'

        argument :label_ids,
                 [GraphQL::ID_TYPE],
                 required: false,
                 description: 'The IDs of labels to be added to the test case.'

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project full path to create the test case.'

        field :test_case, Types::IssueType,
              null: true,
              description: 'The test case created.'

        def resolve(args)
          project_path = args.delete(:project_path)
          project = authorized_find!(full_path: project_path)

          result = ::QualityManagement::TestCases::CreateService.new(
            project,
            context[:current_user],
            **args
          ).execute

          test_case = result.payload[:issue]

          {
            test_case: test_case&.persisted? ? test_case : nil,
            errors: Array.wrap(result.message)
          }
        end

        private

        def find_object(full_path:)
          resolve_project(full_path: full_path)
        end
      end
    end
  end
end
