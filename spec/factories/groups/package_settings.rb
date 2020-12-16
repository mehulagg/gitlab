# frozen_string_literal: true

FactoryBot.define do
  factory :group_package_setting do
    group
    maven_duplicates_allowed { true }
    maven_duplicate_exception_regex { 'SNAPSHOT' }
  end
end
