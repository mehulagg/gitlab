# frozen_string_literal: true

FactoryBot.define do
  factory :ci_reports_license_scanning_report, class: '::Gitlab::Ci::Reports::LicenseScanning::Report', aliases: [:license_scan_report] do
    trait :version_1 do
      version { '1.0' }
    end
    trait :version_2 do
      version { '2.0' }
    end
    trait :report_1 do
      after(:build) do |report, evaluator|
        report.add_license(id: 'MIT', name: 'MIT', url: 'https://opensource.org/licenses/mit').add_dependency('Library1')
        report.add_license(id: 'WTFPL', name: 'WTFPL', url: 'https://opensource.org/licenses/wtfpl').add_dependency('Library2')
      end
    end

    trait :report_2 do
      after(:build) do |report, evaluator|
        report.add_license(id: 'MIT', name: 'MIT', url: 'https://opensource.org/licenses/mit').add_dependency('Library1')
        report.add_license(id: 'Apache-2.0', name: 'Apache 2.0', url: 'https://opensource.org/licenses/apache').add_dependency('Library3')
      end
    end

    trait :mit do
      after(:build) do |report, evaluator|
        report.add_license(id: 'MIT', name: 'MIT', url: 'https://opensource.org/licenses/mit').add_dependency('rails')
      end
    end
  end
end
