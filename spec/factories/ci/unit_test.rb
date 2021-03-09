# frozen_string_literal: true

FactoryBot.define do
  factory :ci_unit_test, class: 'Ci::UnitTest' do
    project
    key_hash { Digest::SHA256.hexdigest(SecureRandom.hex) }
  end
end
