# frozen_string_literal: true

module EE
  module BoardsHelper
    extend ::Gitlab::Utils::Override

    override :board_list_data
    def board_list_data
      super.merge(list_milestone_path: board_milestones_path(board, :json),
                  list_assignees_path: board_users_path(board, :json))
    end

    override :board_data
    def board_data
      show_feature_promotion = @project && show_promotions? &&
                               !@project.feature_available?(:scoped_issue_board)

      data = {
        board_milestone_title: board.milestone&.name,
        board_milestone_id: board.milestone_id,
        board_assignee_username: board.assignee&.username,
        label_ids: board.label_ids,
        labels: board.labels.to_json(only: [:id, :title, :color, :text_color] ),
        board_weight: board.weight,
        weight_feature_available: current_board_parent.feature_available?(:issue_weights).to_s,
        show_promotion: show_feature_promotion,
        scoped_labels: current_board_parent.feature_available?(:scoped_labels)&.to_s
      }

      super.merge(data)
    end

    override :recent_boards_path
    def recent_boards_path
      return recent_group_boards_path(@group) if current_board_parent.is_a?(Group)

      super
    end
  end
end
