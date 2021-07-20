# frozen_string_literal: true

module EE
  module Types
    module Boards
      module NegatedBoardIssueInputType
        extend ActiveSupport::Concern

        prepended do
          argument :iteration_wildcard_id, ::Types::NegatedIterationWildcardIdEnum,
                   required: false,
                   description: 'Filter by iteration ID wildcard.'
        end
      end
    end
  end
end
