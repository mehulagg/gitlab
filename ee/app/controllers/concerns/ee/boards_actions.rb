# frozen_string_literal: true

module EE
  module BoardsActions
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      include ::MultipleBoardsActions
    end

    override :get_boards
    def get_boards
      return super unless board_type == 'epic'

      ::Boards::EpicBoardsFinder.new(parent).execute
    end

    override :get_board
    def get_board
      return super unless board_type == 'epic'

      ::Boards::EpicBoardsFinder.new(parent, id: params[:board_id]).execute
    end

    def board_type
      strong_memoize(:board_type) do
        params[:board_type]
      end
    end

    def push_licensed_features
      # This is pushing a licensed Feature to the frontend.
      push_frontend_feature_flag(:wip_limits, type: :licensed, default_enabled: true) if parent.feature_available?(:wip_limits)
      push_frontend_feature_flag(:swimlanes, type: :licensed, default_enabled: true) if parent.feature_available?(:swimlanes)
      push_frontend_feature_flag(:issue_weights, type: :licensed, default_enabled: true) if parent.feature_available?(:issue_weights)
    end
  end
end
