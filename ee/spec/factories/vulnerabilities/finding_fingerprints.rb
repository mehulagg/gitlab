# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilities_finding_fingerprint, class: 'Vulnerabilities::FindingFingerprint' do
    finding factory: :vulnerabilities_finding
    algorithm_type { ::Vulnerabilities::FindingFingerprint.algorithm_types[:hash] }
    fingerprint_sha256 { ::Digest::SHA1.digest(SecureRandom.hex(50)) }
  end
end
