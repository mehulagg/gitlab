module IssueLinks
  class CreateService < IssuableLinks::CreateService
    def relate_issues(referenced_issue)
      link = IssueLink.create(source: issuable, target: referenced_issue)

      yield if link.persisted?
    end

    def linkable_issues(issues)
      @linkable_issues ||= begin
        issues.select { |issue| can?(current_user, :admin_issue_link, issue) }
      end
    end

    def create_notes(referenced_issue, params)
      SystemNoteService.relate_issue(issuable, referenced_issue, current_user)
      SystemNoteService.relate_issue(referenced_issue, issuable, current_user)
    end

    def previous_related_issues
      @related_issues ||= issuable.related_issues(current_user).to_a
    end
  end
end
