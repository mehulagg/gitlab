# frozen_string_literal: true

FactoryBot.define do
  factory :ci_unit_test_failures, class: 'Ci::UnitTestFailure' do
    build factory: :ci_build
    unit_test factory: :ci_unit_test
    failed_at { Time.current }
  end
end
