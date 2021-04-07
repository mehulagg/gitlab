# frozen_string_literal: true

module Boards
  module EpicLists
    class DestroyService < ::Boards::Lists::BaseDestroyService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(board)
        unless Feature.enabled?(:epic_boards, board.group)
          return ServiceResponse.error(message: 'Epic boards feature is not enabled.')
        end

        super
      end
    end
  end
end
