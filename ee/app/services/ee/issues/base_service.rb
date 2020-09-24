# frozen_string_literal: true

module EE
  module Issues
    module BaseService
      extend ::Gitlab::Utils::Override

      class EpicAssignmentError < ::ArgumentError; end

      def handle_epic(issue)
        return unless epic_param_present?

        epic = epic_param(issue)
        result = epic ? assign_epic(issue, epic) : unassign_epic(issue)
        issue.reload_epic

        if result[:status] == :error
          raise EpicAssignmentError, result[:message]
        end
      end

      def assign_epic(issue, epic)
        issue.confidential = true if !issue.persisted? && epic.confidential

        link_params = { target_issuable: issue, skip_epic_dates_update: true }

        EpicIssues::CreateService.new(epic, current_user, link_params).execute
      end

      def unassign_epic(issue)
        link = EpicIssue.find_by_issue_id(issue.id)
        return success unless link

        EpicIssues::DestroyService.new(link, current_user).execute
      end

      def epic_param(issue)
        epic_id = params.delete(:epic_id)
        epic = params.delete(:epic) || find_epic(issue, epic_id)

        return unless epic

        unless can?(current_user, :admin_epic, epic)
          raise ::Gitlab::Access::AccessDeniedError
        end

        epic
      end

      def find_epic(issue, epic_id)
        return if epic_id.to_i == 0

        group = issue.project.group
        return unless group.present?

        EpicsFinder.new(current_user, group_id: group.id,
                        include_ancestor_groups: true).find(epic_id)
      end

      def epic_param_present?
        params.key?(:epic) || params.key?(:epic_id)
      end
    end
  end
end
