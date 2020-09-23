# frozen_string_literal: true

FactoryBot.define do
  factory :description_version do
    description { generate(:title) }

    after(:build) do |description_version|
      description_version.issue = create(:issue) unless description_version.issuable
    end
  end
end
