# frozen_string_literal: true

module Types
  class MilestoneTitleWildcardEnum < BaseEnum
    graphql_name 'MilestoneTitleWildcard'
    description 'Milestone title wildcard values'

    value 'NONE', 'No milestone is assigned.'
    value 'ANY', 'An milestone is assigned.'
    value 'STARTED', 'An open milestone with a start date that is before today.'
    value 'UPCOMING', 'An open milestone with a due date in the future.'
  end
end
