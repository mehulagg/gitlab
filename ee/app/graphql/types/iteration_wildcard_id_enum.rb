# frozen_string_literal: true

module Types
  class IterationWildcardIdEnum < BaseEnum
    graphql_name 'IterationWildcardId'
    description 'Iteration ID wildcard values'

    value 'NONE', 'No iteration is assigned.'
    value 'ANY', 'An iteration is assigned.'
    value 'CURRENT', 'Current iteration.'
  end
end
