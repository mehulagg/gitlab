# frozen_string_literal: true

module Boards
  module EpicBoards
    class UpdateService < Boards::UpdateService
      extend ::Gitlab::Utils::Override

      override :permitted_params
      def permitted_params
        permitted = PERMITTED_PARAMS

        if parent.feature_available?(:scoped_issue_board)
          permitted += %i(labels label_ids)
        end

        permitted
      end
    end
  end
end
