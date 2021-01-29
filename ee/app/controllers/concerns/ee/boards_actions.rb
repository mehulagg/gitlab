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
      return super unless params[:controller] == 'groups/epic_boards'

      existing_boards = ::Boards::EpicBoardsFinder.new(parent).execute
      return existing_boards if existing_boards.any?

      # if no epic board exists, create one for this group
      [::Boards::EpicBoards::CreateService.new(parent, current_user).execute.payload]
    end

    override :get_board
    def get_board
      return super unless params[:controller] == 'groups/epic_boards'

      ::Boards::EpicBoardsFinder.new(parent, id: params[:board_id]).execute.first
    end

    private

    def push_licensed_features
      # This is pushing a licensed Feature to the frontend.
      push_frontend_feature_flag(:wip_limits, type: :licensed, default_enabled: true) if parent.feature_available?(:wip_limits)
      push_frontend_feature_flag(:swimlanes, type: :licensed, default_enabled: true) if parent.feature_available?(:swimlanes)
      push_frontend_feature_flag(:issue_weights, type: :licensed, default_enabled: true) if parent.feature_available?(:issue_weights)
    end
  end
end
