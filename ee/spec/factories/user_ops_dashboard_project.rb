# frozen_string_literal: true

FactoryBot.define do
  factory :users_ops_dashboard_project, class: 'UsersOpsDashboardProject' do
    user factory: :user
    project factory: :project
  end
end
