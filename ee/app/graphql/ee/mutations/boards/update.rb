# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Update
        extend ActiveSupport::Concern

        prepended do
          include ::EE::Mutations::Boards::ScopedBoardMutation
        end
      end
    end
  end
end
