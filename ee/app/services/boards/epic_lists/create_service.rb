# frozen_string_literal: true

module Boards
  module EpicLists
    class CreateService < ::Boards::Lists::BaseCreateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(board)
        unless Feature.enabled?(:epic_boards, board.group, default_enabled: :yaml)
          return ServiceResponse.error(message: 'Epic boards feature is not enabled.')
        end

        super
      end
    end
  end
end
