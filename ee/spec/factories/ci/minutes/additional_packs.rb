# frozen_string_literal: true

FactoryBot.define do
  factory :ci_minutes_additional_pack, class: 'Ci::Minutes::AdditionalPack' do
    namespace
    number_of_minutes { 10_000 }
    expires_at { Date.today + 1.year }
    purchase_xid { SecureRandom.hex(32) }
  end
end
