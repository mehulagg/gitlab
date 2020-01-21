# frozen_string_literal: true

module Types
  class SubscriptionType < ::Types::BaseObject
    graphql_name 'Subscription'

    field :issue_updated,
          Types::IssueType,
          null: false,
          description: 'Triggered when an issue is updated' do
      argument :id, GraphQL::ID_TYPE, required: true,
               description: 'ID of the issue'
    end

    def issue_updated(id:)
      issue = Issue.find_by_id(id)

      unless issue && Ability.allowed?(context[:current_user], :read_issue, issue)
        raise GraphQL::ExecutionError.new("Can't subscribe to id: #{id}")
      end
    end
  end
end
