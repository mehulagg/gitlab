# frozen_string_literal: true

module LearnGitlabHelper
  def onboarding_actions_data(project)
    attributes = onboarding_progress(project).attributes.symbolize_keys

    action_urls.map do |action, url|
      [
        action,
        url: url,
        completed: attributes[OnboardingProgress.column_name(action)].present?,
        svg: image_path("learn_gitlab/#{action}.svg")
      ]
    end.to_h
  end

  private

  ACTION_ISSUE_IDS = {
    git_write: 2,
    pipeline_created: 4,
    merge_request_created: 5,
    user_added: 7,
    trial_started: 13,
    required_mr_approvals_enabled: 15,
    code_owners_enabled: 16
  }.freeze

  ACTION_DOC_URLS = {
    security_scan_enabled: 'https://docs.gitlab.com/ee/user/application_security/security_dashboard/#gitlab-security-dashboard-security-center-and-vulnerability-reports'
  }.freeze

  def action_urls
    ACTION_ISSUE_IDS.transform_values { |id| project_issue_url(learn_gitlab_project, id) }.merge(ACTION_DOC_URLS)
  end

  def learn_gitlab_project
    @learn_gitlab_project ||= LearnGitlab.new(current_user).project
  end

  def onboarding_progress(project)
    OnboardingProgress.find_by(namespace: project.namespace) # rubocop: disable CodeReuse/ActiveRecord
  end
end
