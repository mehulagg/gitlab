# frozen_string_literal: true
module Types
  class PathLockType < BaseObject
    graphql_name 'PathLock'
    description 'Represents a file or directory in the project repository that has been locked.'

    authorize :download_code

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the path lock.'

    field :path, GraphQL::STRING_TYPE, null: true,
          description: 'The locked path.'

    field :user, ::Types::UserType, null: true,
          description: 'The user that has locked this path.'
  end
end
