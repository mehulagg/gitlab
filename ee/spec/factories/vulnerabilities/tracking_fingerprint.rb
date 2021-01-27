# frozen_string_literal: true

FactoryBot.define do
  factory :tracking_fingerprint, class: 'Vulnerabilities::TrackingFingerprint' do
    finding factory: :vulnerabilities_finding
    track_type { :source }
    track_method { :location }
    priority { :source_location }
    sha { generate(:sha) }
  end
end
