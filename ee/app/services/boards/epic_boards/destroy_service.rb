# frozen_string_literal: true

module Boards
  module EpicBoards
    class DestroyService < ::Boards::DestroyService
      extend ::Gitlab::Utils::Override

      override :boards
      def boards
        parent.epic_boards
      end
    end
  end
end
