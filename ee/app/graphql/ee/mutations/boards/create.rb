# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Create
        extend ActiveSupport::Concern
        include Mutations::Boards::ScopedBoardMutation

        prepended do
          include Mutations::Boards::ScopedBoardArguments
        end
      end
    end
  end
end
