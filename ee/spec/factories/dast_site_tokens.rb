# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_token do
    project

    token { SecureRandom.uuid }

    url { generate(:url) }
  end
end
