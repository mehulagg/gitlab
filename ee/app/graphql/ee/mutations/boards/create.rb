# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Create
        include Mutations::Boards::ScopedBoardMutation
      end
    end
  end
end
