# frozen_string_literal: true

FactoryBot.define do
  factory :ci_namespace_monthly_usage, class: 'Ci::Minutes::NamespaceMonthlyUsage' do
    amount_used { 100 }
    namespace factory: :namespace
  end
end
