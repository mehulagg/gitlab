# frozen_string_literal: true

module Boards
  module EpicLists
    class CreateService < ::Boards::Lists::BaseCreateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(board)
        super
      end
    end
  end
end
