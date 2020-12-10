# frozen_string_literal: true

FactoryBot.define do
  factory :user_permission_export_upload do
    user
    created

    trait :created do
      status { 0 }
    end

    trait :running do
      status { 1 }
    end

    trait :finished do
      status { 2 }
      file { fixture_file_upload('spec/fixtures/csv_comma.csv') }
    end

    trait :failed do
      status { 3 }
    end
  end
end
