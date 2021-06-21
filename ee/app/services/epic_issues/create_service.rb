# frozen_string_literal: true

module EpicIssues
  class CreateService < IssuableLinks::CreateService
    private

    # rubocop: disable CodeReuse/ActiveRecord
    def relate_issuables(referenced_issue)
      link = EpicIssue.find_or_initialize_by(issue: referenced_issue)

      params = if link.persisted?
                 { issue_moved: true, original_epic: link.epic }
               else
                 {}
               end

      link.epic = issuable
      link.move_to_start

      if link.save
        Epics::NewEpicIssueWorker.perform_async(issuable.id, referenced_issue.id, current_user.id, params)
      end

      link
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def extractor_context
      { group: issuable.group }
    end

    def affected_epics(issues)
      [issuable, Epic.in_issues(issues)].flatten.uniq
    end

    def linkable_issuables(issues)
      @linkable_issues ||= begin
        return [] unless can?(current_user, :admin_epic, issuable.group)

        issues.select do |issue|
          issue.supports_epic? &&
            issuable_group_descendants.include?(issue.project.group) &&
            !previous_related_issuables.include?(issue)
        end
      end
    end

    def previous_related_issuables
      @related_issues ||= issuable.issues.to_a
    end

    def issuable_group_descendants
      @descendants ||= issuable.group.self_and_descendants
    end
  end
end
