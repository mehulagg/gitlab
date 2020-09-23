# frozen_string_literal: true

FactoryBot.define do
  factory :ci_reports_security_scanner, class: '::Gitlab::Ci::Reports::Security::Scanner' do
    external_id { 'find_sec_bugs' }
    name { 'Find Security Bugs' }
    vendor { 'Security Scanner Vendor' }

    skip_create

    initialize_with do
      ::Gitlab::Ci::Reports::Security::Scanner.new(attributes)
    end
  end
end
