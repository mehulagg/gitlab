# frozen_string_literal: true

module EE
  module API
    module Entities
      module Board
        extend ActiveSupport::Concern

        prepended do
          expose :group, using: ::API::Entities::BasicGroupDetails

          with_options if: ->(board, _) { board.resource_parent.feature_available?(:scoped_issue_board) } do
            # Default filtering configuration
            expose :milestone do |board|
              if board.milestone.is_a?(Milestone)
                ::API::Entities::Milestone.represent(board.milestone)
              else
                SpecialBoardFilter.represent(board.milestone)
              end
            end
            expose :assignee, using: ::API::Entities::UserBasic
            expose :labels, using: ::API::Entities::LabelBasic
            expose :weight
          end
        end
      end
    end
  end
end
