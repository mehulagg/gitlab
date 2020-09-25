# frozen_string_literal: true

class ImportConfiguration < ApplicationRecord
  belongs_to :bulk_import, inverse_of: :configuration, optional: false

  validates :url, :access_token, length: { maximum: 255 }
  validates :url, public_url: { schemes: %w[http https], enforce_sanitization: true, ascii_only: true },
    allow_nil: true

  attr_encrypted :url,
    key: Settings.attr_encrypted_db_key_base_truncated,
    encode: true,
    mode: :per_attribute_iv,
    algorithm: 'aes-256-gcm'
  attr_encrypted :access_token,
    key: Settings.attr_encrypted_db_key_base_truncated,
    encode: true,
    mode: :per_attribute_iv,
    algorithm: 'aes-256-gcm'
end
