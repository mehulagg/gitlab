# frozen_string_literal: true

FactoryBot.define do
  factory :ci_build_report_results, class: 'Ci::BuildReportResults' do
    build factory: :ci_build
    project factory: :project
    title { "title" }

    trait :with_junit_success do
      data do
        {
          junit: {
            name: "rspec",
            duration: "0.42",
            failed: 0,
            errored: 0,
            skipped: 0,
            success: 2
          }
        }
      end
    end

    trait :with_junit_errors do
      data do
        {
          junit: {
            name: "rspec",
            duration: "0.42",
            failed: 0,
            errored: 2,
            skipped: 0,
            success: 0
          }
        }
      end
    end

    trait :with_coverage do
      data { { coverage: 80.0 } }
    end
  end
end
