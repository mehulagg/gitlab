# frozen_string_literal: true

module Boards
  module EpicBoards
    class UpdateService < Boards::BaseService
      # extend ::Gitlab::Utils::Override

      # override :execute
      def execute(board)
        filter_labels

        board.update(params)
      end
    end
  end
end
