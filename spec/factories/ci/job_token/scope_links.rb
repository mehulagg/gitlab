# frozen_string_literal: true

FactoryBot.define do
  factory :ci_job_token_scope_link, class: 'Ci::JobToken::ScopeLink' do
    source_project factory: :project
    target_project factory: :project
    added_by factory: :user
  end
end
