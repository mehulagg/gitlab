# frozen_string_literal: true

class AddSecretKeyAndIvToDastSiteProfile < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/AddLimitToTextColumns
  # limit is added in 20201222032018_add_secret_key_and_iv_text_limits
  def change
    add_column :dast_site_profiles, :encrypted_secret_key, :text
    add_column :dast_site_profiles, :encrypted_secret_key_iv, :text, uniqueness: true
    add_column :dast_site_profiles, :encrypted_secret_key_salt, :text

    # unencrypted column value
    add_column :dast_site_profiles, :secret_key_iv, :text
  end
  # rubocop:enable Migration/AddLimitToTextColumns
end
