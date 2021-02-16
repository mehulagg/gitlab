# frozen_string_literal: true

module Ci
  class VariableInitializationVector < ApplicationRecord
    self.table_name = 'ci_variable_initialization_vectors'

    CIPHER = 'aes-256-gcm'

    validates :variable_id, :variable_secret_key_id, presence: true
    validates :initialization_vector, length: { maximum: 255 }, presence: true, uniqueness: true

    belongs_to :variable, class_name: 'Ci::Variable', foreign_key: 'variable_id'
    belongs_to :variable_secret_key, class_name: 'Ci::VariableSecretKey', foreign_key: 'variable_secret_key_id'

    CIPHER = 'aes-256-gcm'

    def self.generate_initialization_vector
      cipher = OpenSSL::Cipher.new(CIPHER)
      cipher.encrypt

      Base64.encode64(cipher.random_iv)
    end
  end
end
