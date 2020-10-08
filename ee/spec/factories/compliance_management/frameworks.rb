# frozen_string_literal: true

FactoryBot.define do
  factory :compliance_framework, class: 'ComplianceManagement::Framework' do
    association :group, factory: :group

    name { 'GDPR' }
    description { 'The General Data Protection Regulation (GDPR) is a regulation in EU law on data protection and privacy in the European Union (EU) and the European Economic Area (EEA).' }
    color { '#004494' }
  end
end
