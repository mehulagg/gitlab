# frozen_string_literal: true

FactoryBot.define do
  factory :ci_reports_security_remediation, class: '::Gitlab::Ci::Reports::Security::Remediation' do
    summary { 'Remediation summary' }
    diff { 'foo' }

    skip_create

    initialize_with do
      ::Gitlab::Ci::Reports::Security::Remediation.new(summary, diff)
    end
  end
end
