# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Create
        extend ActiveSupport::Concern

        prepended do
          prepend ::Mutations::Boards::ScopedIssueBoardArguments
          prepend ::Mutations::Boards::ScopedBoardMutation
        end
      end
    end
  end
end
