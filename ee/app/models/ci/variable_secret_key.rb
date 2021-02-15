# frozen_string_literal: true

module Ci
  class VariableSecretKey < ApplicationRecord
    CIPHER = 'aes-256-gcm'

    self.table_name = "ci_variable_secret_keys"

    # has_many :variable_initialization_vectors, class_name: 'Ci::VariableInitializationVector'
    # has_many :variables, through: :variable_initialization_vectors, class_name: 'Ci::VariableInitializationVector'

    attr_encrypted :secret_key,
                   mode: :per_attribute_iv_and_salt,
                   insecure_mode: true,
                   key: Settings.attr_encrypted_db_key_base,
                   algorithm: CIPHER

    def self.generate_secret_key
      cipher = OpenSSL::Cipher.new(CIPHER)
      cipher.encrypt

      Base64.encode64(cipher.random_key)
    end
  end
end
