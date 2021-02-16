# frozen_string_literal: true

module Ci
  class VariableSecretKey < ApplicationRecord
    self.table_name = 'ci_variable_secret_keys'

    CIPHER = 'aes-256-gcm'

    validates :encrypted_secret_key, length: { maximum: 255 }, presence: true
    validates :encrypted_secret_key_iv, length: { maximum: 255 }, presence: true, uniqueness: true
    validates :encrypted_secret_key_salt, length: { maximum: 255 }, presence: true

    has_many :variable_initialization_vectors, class_name: 'Ci::VariableInitializationVector'
    has_many :variables, through: :variable_initialization_vectors, class_name: 'Ci::Variable'

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
