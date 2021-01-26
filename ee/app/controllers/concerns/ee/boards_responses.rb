# frozen_string_literal: true

module EE
  module BoardsResponses
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :board_params
    def board_params
      params.require(:board).permit(:name, :weight, :milestone_id, :iteration_id, :assignee_id, label_ids: [])
    end

    def authorize_read_parent
      authorize_action_for!(board, :read_parent)
    end

    def authorize_read_milestone
      authorize_action_for!(board, :read_milestone)
    end
  end
end
