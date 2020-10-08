# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_token do
    token { SecureRandom.uuid }
    url { FFaker::Internet.uri(:https) }

    before(:create) do |dast_site_token|
      dast_site_token.project ||= FactoryBot.create(:project)
    end
  end
end
