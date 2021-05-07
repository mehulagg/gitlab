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
        create_notes(referenced_issue, params)
        usage_ping_record_epic_issue_added
      end

      link
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def create_notes(referenced_issue, params)
      if params[:issue_moved]
        SystemNoteService.epic_issue_moved(
          params[:original_epic], referenced_issue, issuable, current_user
        )
        SystemNoteService.issue_epic_change(referenced_issue, issuable, current_user)
      else
        SystemNoteService.epic_issue(issuable, referenced_issue, current_user, :added)
        SystemNoteService.issue_on_epic(referenced_issue, issuable, current_user, :added)
      end
    end

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

    def usage_ping_record_epic_issue_added
      ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_issue_added(author: current_user)
    end
  end
end
