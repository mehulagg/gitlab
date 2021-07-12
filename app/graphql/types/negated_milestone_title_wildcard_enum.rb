# frozen_string_literal: true

module Types
  class NegatedMilestoneTitleWildcardEnum < BaseEnum
    graphql_name 'NegatedMilestoneTitleWildcard'
    description 'Negated Milestone title wildcard values'

    value 'CURRENT', 'A current milestone is assigned.'
    value 'UPCOMING', 'An upcoming milestone is assigned.'
  end
end
