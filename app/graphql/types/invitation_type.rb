# frozen_string_literal: true

module Types
  class InvitationType < BaseObject
    graphql_name 'Invitation'

    field :iid, GraphQL::ID_TYPE, null: true,
          description: 'ID of the member'
    field :email, GraphQL::STRING_TYPE, null: false,
          description: 'Email of the invited member'
    field :access_level, Types::AccessLevelType, null: true,
          description: 'Access level of the member'

    present_using InvitationPresenter
  end
end
