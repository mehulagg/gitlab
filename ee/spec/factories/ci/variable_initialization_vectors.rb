# frozen_string_literal: true

FactoryBot.define do
  factory :ci_variable_initialization_vector, class: 'Ci::VariableInitializationVector' do
    variable { association(:ci_variable) }
    variable_secret_key { association(:ci_variable_secret_key) }

    initialization_vector do
      Ci::VariableInitializationVector.generate_initialization_vector
    end
  end
end
