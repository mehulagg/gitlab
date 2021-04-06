# frozen_string_literal: true

module Types
  module Boards
    # rubocop: disable Graphql/AuthorizeTypes
    class BoardIssueInputBaseType < BoardIssuableInputBaseType
      argument :milestone_title, GraphQL::STRING_TYPE,
               required: false,
               description: 'Filter by milestone title.'

      argument :assignee_username, GraphQL::STRING_TYPE.to_list_type,
               required: false,
               description: 'Filter by assignee username.'

      argument :release_tag, GraphQL::STRING_TYPE,
               required: false,
               description: 'Filter by release tag.'
    end
  end
end

Types::Boards::BoardIssueInputBaseType.prepend_if_ee('::EE::Types::Boards::BoardIssueInputBaseType')
