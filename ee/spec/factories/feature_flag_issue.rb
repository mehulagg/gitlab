# frozen_string_literal: true

FactoryBot.define do
  factory :feature_flag_issue do
    feature_flag factory: :operations_feature_flag
    issue
  end
end
