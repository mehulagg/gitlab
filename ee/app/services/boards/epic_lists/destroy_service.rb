# frozen_string_literal: true

module Boards
  module EpicLists
    class DestroyService < ::Boards::Lists::BaseDestroyService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(list)
        unless list.board.group.licensed_feature_available?(:epics)
          return ServiceResponse.error(message: 'Epics feature is not available.')
        end

        unless can?(current_user, :admin_epic_board_list, list)
          return ServiceResponse.error(message: 'The epic board list that you are attempting to destroy does not '\
                  'exist or you don\'t have permission to perform this action')
        end

        super
      end
    end
  end
end
