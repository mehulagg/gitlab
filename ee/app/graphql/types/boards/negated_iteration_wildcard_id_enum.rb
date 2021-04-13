# frozen_string_literal: true

module Types
  module Boards
    class NegatedIterationWildcardIdEnum < BaseEnum
      graphql_name 'NegatedIterationWildcardId'
      description 'Negated Iteration ID wildcard values'

      value 'CURRENT', 'Current iteration.'
    end
  end
end
