# frozen_string_literal: true

module EE
  module Issues
    module MoveService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(issue, target_project)
        super

        # Updates old issue sent notifications allowing
        # to receive service desk emails on the new moved issue.
        update_service_desk_sent_notifications

        new_entity
      end

      override :update_new_entity
      def update_new_entity
        copy_designs

        super
      end

      override :update_old_entity
      def update_old_entity
        rewrite_epic_issue
        rewrite_related_issues

        super
      end

      private

      def update_service_desk_sent_notifications
        return unless original_entity.from_service_desk?

        original_entity
          .sent_notifications.update_all(project_id: new_entity.project_id, noteable_id: new_entity.id)
      end

      def copy_designs
        ::DesignManagement::CopyDesignsService.new(
          new_entity.project,
          current_user,
          issue: original_entity,
          to_issue: new_entity
        ).execute
      end

      def rewrite_epic_issue
        return unless epic_issue = original_entity.epic_issue
        return unless can?(current_user, :update_epic, epic_issue.epic.group)

        epic_issue.update(issue_id: new_entity.id)
        original_entity.reset
      end

      def rewrite_related_issues
        source_issue_links = IssueLink.for_source_issue(original_entity)
        source_issue_links.update_all(source_id: new_entity.id)

        target_issue_links = IssueLink.for_target_issue(original_entity)
        target_issue_links.update_all(target_id: new_entity.id)
      end
    end
  end
end
