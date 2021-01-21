# frozen_string_literal: true

module Boards
  module Epics
    class CreateService < Boards::CreateService
      extend ::Gitlab::Utils::Override

      override :can_create_board?
      def can_create_board?
        parent_board_collection.empty?
      end

      override :parent_board_collection
      def parent_board_collection
        parent.epic_boards
      end
    end
  end
end
