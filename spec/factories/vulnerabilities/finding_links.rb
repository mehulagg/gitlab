# frozen_string_literal: true

FactoryBot.define do
  factory :finding_link, class: 'Vulnerabilities::FindingLink' do
    finding factory: :vulnerabilities_finding
    name { 'CVE-2018-1234' }
    url { 'http://cve.mitre.org/cgi-bin/cvename.cgi?name=2018-1234' }
  end
end
