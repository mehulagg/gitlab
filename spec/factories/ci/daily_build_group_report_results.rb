# frozen_string_literal: true

FactoryBot.define do
  factory :ci_daily_build_group_report_result, class: 'Ci::DailyBuildGroupReportResult' do
    ref_path { Gitlab::Git::BRANCH_REF_PREFIX + 'master' }
    date { Time.zone.now.to_date }
    project
    last_pipeline factory: :ci_pipeline
    group_name { 'rspec' }
    data do
      { 'coverage' => 77.0 }
    end
    default_branch { false }

    trait :with_default_branch do
      default_branch { true }
    end
  end
end
