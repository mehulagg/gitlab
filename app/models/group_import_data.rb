# frozen_string_literal: true

class GroupImportData < ApplicationRecord
  belongs_to :group, inverse_of: :import_data, optional: false

  validates :api_url, :access_token, length: { maximum: 255 }
  validates :api_url, public_url: { schemes: %w[http https], enforce_sanitization: true, ascii_only: true },
    allow_nil: true

  attr_encrypted :api_url,
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
