# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilities_finding_tracking, class: 'Vulnerabilities::FindingTracking' do
    finding factory: :vulnerabilities_finding
    algorithm_type { ::Vulnerabilities::FindingTracking.algorithm_types[:hash] }
    tracking_sha { ::Digest::SHA1.digest(SecureRandom.hex(50)) }
  end
end
