# frozen_string_literal: true

module Types
  class UserType < BaseObject
    graphql_name 'User'

    authorize :read_user

    present_using UserPresenter

    expose_permissions Types::PermissionTypes::User

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the user'
    field :username, GraphQL::STRING_TYPE, null: false,
          description: 'Username of the user. Unique within this instance of GitLab'
    field :name, GraphQL::STRING_TYPE, null: false,
          description: 'Human-readable name of the user'
    field :state, Types::UserStateEnum, null: false,
          description: 'State of the user'
    field :avatar_url, GraphQL::STRING_TYPE, null: true,
          description: "URL of the user's avatar"
    field :web_url, GraphQL::STRING_TYPE, null: false,
          description: 'Web URL of the user'
    field :todos, Types::TodoType.connection_type, null: false,
          resolver: Resolvers::TodoResolver,
          description: 'Todos of the user'

    # Merge request field: MRs can be either authored or assigned:
    field :authored_merge_requests, Types::MergeRequestType.connection_type, null: true,
          resolver: Resolvers::Users::AuthoredMergeRequestsResolver,
          description: 'Merge Requests authored by the user'
    field :assigned_merge_requests, Types::MergeRequestType.connection_type, null: true,
          resolver: Resolvers::Users::AssignedMergeRequestsResolver,
          description: 'Merge Requests assigned to the user'

    field :snippets,
          Types::SnippetType.connection_type,
          null: true,
          description: 'Snippets authored by the user',
          resolver: Resolvers::Users::SnippetsResolver
  end
end
