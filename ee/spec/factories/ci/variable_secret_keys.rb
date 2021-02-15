# frozen_string_literal: true

FactoryBot.define do
  factory :ci_variable_secret_key, class: 'Ci::VariableSecretKey' do
    secret_key { Ci::VariableSecretKey.generate_secret_key }
  end
end
