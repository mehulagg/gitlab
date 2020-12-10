# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerabilities_remediation, class: 'Vulnerabilities::Remediation' do
    project
    summary { 'Remediation Summary' }
    file { Tempfile.new }

    sequence :checksum do |i|
      Digest::SHA256.hexdigest(i.to_s)
    end
  end
end
