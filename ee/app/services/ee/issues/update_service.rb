# frozen_string_literal: true

module EE
  module Issues
    module UpdateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(issue)
        handle_epic(issue)
        result = super

        if issue.previous_changes.include?(:milestone_id) && issue.epic
          issue.epic.update_start_and_due_dates
        end

        result
      end

      override :filter_params
      def filter_params(issue)
        epic_iid = params.delete(:epic_iid)
        group = issue.project.group
        if epic_iid.present? && group && can?(current_user, :admin_epic, group)
          finder = EpicsFinder.new(current_user, group_id: group.id)
          params[:epic] = finder.find_by!(iid: epic_iid) # rubocop: disable CodeReuse/ActiveRecord
        end

        super
      end

      private

      def handle_epic(issue)
        return unless params.key?(:epic)

        epic_param = params.delete(:epic)

        if epic_param
          EpicIssues::CreateService.new(epic_param, current_user, { target_issuable: issue }).execute
        else
          link = EpicIssue.find_by(issue_id: issue.id) # rubocop: disable CodeReuse/ActiveRecord

          return unless link

          EpicIssues::DestroyService.new(link, current_user).execute
        end
      end
    end
  end
end
