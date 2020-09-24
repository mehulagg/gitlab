# frozen_string_literal: true

FactoryBot.define do
  factory :ci_sources_project, class: 'Ci::Sources::Project' do
    pipeline factory: :ci_pipeline
    source_project factory: :project
  end
end
