# frozen_string_literal: true

module Types
  module Boards
    class EpicWildcardIdEnum < BaseEnum
      graphql_name 'EpicWildcardId'
      description 'Epic ID wildcard values'

      value 'NONE', 'No epic is assigned.'
      value 'ANY', 'Any epic is assigned.'
    end
  end
end
