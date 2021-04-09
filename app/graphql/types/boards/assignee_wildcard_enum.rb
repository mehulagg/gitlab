# frozen_string_literal: true

module Types
  module Boards
    class AssigneeWildcardEnum < BaseEnum
      graphql_name 'AssigneeWildcard'
      description 'Assignee wildcard values'

      value 'NONE', 'No assignee is assigned.'
      value 'ANY', 'Any assignee is assigned.'
    end
  end
end
