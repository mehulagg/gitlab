# frozen_string_literal: true

FactoryBot.define do
  factory :gitlab_slack_application_service do
    project
    active { true }
    type { 'GitlabSlackApplicationService' }
  end

  factory :github_service do
    project
    type { 'GithubService' }
    active { true }
    token { 'github-token' }
  end
end
