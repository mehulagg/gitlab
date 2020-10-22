# frozen_string_literal: true

class AddSecretDetectionTokenRevocationApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/PreventStrings
  # rubocop:disable Migration/AddLimitToTextColumns
  def up
    add_column :application_settings, :secret_detection_token_revocation_enabled, :boolean, default: false, null: false
    add_column :application_settings, :secret_detection_token_revocation_url, :text, null: true

    add_column :application_settings, :encrypted_secret_detection_token_revocation_token, :text
    add_column :application_settings, :encrypted_secret_detection_token_revocation_token_iv, :string, limit: 255
  end

  def down
    remove_column :application_settings, :secret_detection_token_revocation_enabled
    remove_column :application_settings, :secret_detection_token_revocation_url

    remove_column :application_settings, :encrypted_secret_detection_token_revocation_token
    remove_column :application_settings, :encrypted_secret_detection_token_revocation_token_iv
  end
  # rubocop:enable Migration/PreventStrings
  # rubocop:enable Migration/AddLimitToTextColumns
end
