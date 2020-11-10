# frozen_string_literal: true

module Types
  module Boards
    class IterationWildcardIdEnum < BaseEnum
      graphql_name 'IterationWildcardId'
      description 'Iteration ID wildcard values'

      value 'NONE', 'No iteration is assigned'
      value 'ANY', 'Any iteration is assigned'
    end
  end
end
