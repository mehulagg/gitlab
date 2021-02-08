# frozen_string_literal: true

module Issues
  class CreateService < Issues::BaseService
    include ResolveDiscussions

    def execute(skip_system_notes: false)
      @request = params.delete(:request)
      @spam_params = Spam::SpamActionService.filter_spam_params!(params)

      @issue = BuildService.new(project, current_user, params).execute

      filter_resolve_discussion_params

      create(@issue, skip_system_notes: skip_system_notes)
    end

    def before_create(issue)
      Spam::SpamActionService.new(
        spammable: issue,
        request: request,
        user: current_user,
        action: :create
      ).execute(spam_params: spam_params)

      # current_user (defined in BaseService) is not available within run_after_commit block
      user = current_user
      issue.run_after_commit do
        NewIssueWorker.perform_async(issue.id, user.id)
        IssuePlacementWorker.perform_async(nil, issue.project_id)
      end
    end

    def after_create(issue)
      add_incident_label(issue)
      todo_service.new_issue(issue, current_user)
      user_agent_detail_service.create
      resolve_discussions_with_issue(issue)
      delete_milestone_total_issue_counter_cache(issue.milestone)
      track_incident_action(current_user, issue, :incident_created)
      create_namespace_onboarding_action(issue)

      super
    end

    def resolve_discussions_with_issue(issue)
      return if discussions_to_resolve.empty?

      Discussions::ResolveService.new(project, current_user,
                                      one_or_more_discussions: discussions_to_resolve,
                                      follow_up_issue: issue).execute
    end

    private

    attr_reader :request, :spam_params

    def user_agent_detail_service
      UserAgentDetailService.new(@issue, request)
    end

    # Applies label "incident" (creates it if missing) to incident issues.
    # For use in "after" hooks only to ensure we are not appyling
    # labels prematurely.
    def add_incident_label(issue)
      return unless issue.incident?

      label = ::IncidentManagement::CreateIncidentLabelService
        .new(project, current_user)
        .execute
        .payload[:label]

      return if issue.label_ids.include?(label.id)

      issue.labels << label
    end

    def create_namespace_onboarding_action(issue)
      Namespaces::OnboardingIssueCreatedWorker.perform_async(issue.namespace.id)
    end
  end
end

Issues::CreateService.prepend_if_ee('EE::Issues::CreateService')
