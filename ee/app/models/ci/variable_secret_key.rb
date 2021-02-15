# frozen_string_literal: true

module Ci
  class VariableSecretKey < ApplicationRecord
    self.table_name = "ci_variable_secret_keys"

    # has_many :variable_initialization_vectors, class_name: 'Ci::VariableInitializationVector'
    # has_many :variables, through: :variable_initialization_vectors, class_name: 'Ci::VariableInitializationVector'
  end
end
