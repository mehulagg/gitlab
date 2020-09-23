# frozen_string_literal: true

module EE
  module ProjectPresenter
    extend ::Gitlab::Utils::Override

    override :statistics_buttons
    def statistics_buttons(show_auto_devops_callout:)
      super + extra_statistics_buttons
    end

    def extra_statistics_buttons
      []
    end

    def approver_groups
      ::ApproverGroup.filtered_approver_groups(project.approver_groups, current_user)
    end
  end
end
