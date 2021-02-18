# frozen_string_literal: true

module Types
  class UserType < BaseObject
    graphql_name 'User'

    authorize :read_user

    present_using UserPresenter

    expose_permissions Types::PermissionTypes::User

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the user.'
    field :bot, GraphQL::BOOLEAN_TYPE, null: false,
          description: 'Indicates if the user is a bot.',
          method: :bot?
    field :username, GraphQL::STRING_TYPE, null: false,
          description: 'Username of the user. Unique within this instance of GitLab.'
    field :name, GraphQL::STRING_TYPE, null: false,
          description: 'Human-readable name of the user.'
    field :state, Types::UserStateEnum, null: false,
          description: 'State of the user.'
    field :email, GraphQL::STRING_TYPE, null: true,
          description: 'User email.', method: :public_email,
          deprecated: { reason: 'Use public_email', milestone: '13.7' }
    field :public_email, GraphQL::STRING_TYPE, null: true,
          description: "User's public email."
    field :avatar_url, GraphQL::STRING_TYPE, null: true,
          description: "URL of the user's avatar."
    field :web_url, GraphQL::STRING_TYPE, null: false,
          description: 'Web URL of the user.'
    field :web_path, GraphQL::STRING_TYPE, null: false,
          description: 'Web path of the user.'
    field :todos, Types::TodoType.connection_type, null: false,
          resolver: Resolvers::TodoResolver,
          description: 'To-do items of the user.'
    field :group_memberships, Types::GroupMemberType.connection_type, null: true,
          description: 'Group memberships of the user.'
    field :group_count, GraphQL::INT_TYPE, null: true,
          resolver: Resolvers::Users::GroupCountResolver,
          description: 'Group count for the user.',
          feature_flag: :user_group_counts
    field :status, Types::UserStatusType, null: true,
           description: 'User status.'
    field :location, ::GraphQL::STRING_TYPE, null: true,
          description: 'The location of the user.'
    field :project_memberships, Types::ProjectMemberType.connection_type, null: true,
          description: 'Project memberships of the user.'
    field :starred_projects, Types::ProjectType.connection_type, null: true,
          description: 'Projects starred by the user.',
          resolver: Resolvers::UserStarredProjectsResolver
    field :merge_request_interaction, ::Types::UserMergeRequestInteractionType, null: true,
          description: "Details of this user's interactions with a merge request." do
            argument :id, ::Types::GlobalIDType[::MergeRequest], required: true,
                     description: 'ID of the merge request.'
          end

    # Merge request field: MRs can be authored, assigned, or assigned-for-review:
    field :authored_merge_requests,
          resolver: Resolvers::AuthoredMergeRequestsResolver,
          description: 'Merge Requests authored by the user.'
    field :assigned_merge_requests,
          resolver: Resolvers::AssignedMergeRequestsResolver,
          description: 'Merge Requests assigned to the user.'
    field :review_requested_merge_requests,
          resolver: Resolvers::ReviewRequestedMergeRequestsResolver,
          description: 'Merge Requests assigned to the user for review.'

    field :snippets,
          Types::SnippetType.connection_type,
          null: true,
          description: 'Snippets authored by the user.',
          resolver: Resolvers::Users::SnippetsResolver

    def merge_request_interaction(id:)
      # TODO: remove this line when the compatibility layer is removed
      # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
      id = ::Types::GlobalIDType[::MergeRequest].coerce_isolated_input(id)
      GitlabSchema.find_by_gid(id)
    end
  end
end
