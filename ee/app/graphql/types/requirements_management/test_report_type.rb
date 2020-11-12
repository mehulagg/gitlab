# frozen_string_literal: true

module Types
  module RequirementsManagement
    class TestReportType < BaseObject
      graphql_name 'TestReport'
      description 'Represents a requirement test report'

      authorize :read_requirement

      field :id, GraphQL::ID_TYPE, null: false,
            description: 'ID of the test report'

      field :state, TestReportStateEnum, null: false,
            description: 'State of the test report'

      field :author, UserType, null: true,
            description: 'Author of the test report',
            resolve: -> (obj, _args, _ctx) { Gitlab::Graphql::Loaders::BatchModelLoader.new(User, obj.author_id).find }

      field :created_at, TimeType, null: false,
            description: 'Timestamp of when the test report was created'
    end
  end
end
