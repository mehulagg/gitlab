# frozen_string_literal: true

class AddSecretKeyAndIvTextLimits < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_text_limit :dast_site_profiles, :encrypted_secret_key, 255
    add_text_limit :dast_site_profiles, :encrypted_secret_key_iv, 255
    add_text_limit :dast_site_profiles, :encrypted_secret_key_salt, 255
    add_text_limit :dast_site_profiles, :secret_key_iv, 255
  end

  def down
    remove_text_limit :dast_site_profiles, :encrypted_secret_key
    remove_text_limit :dast_site_profiles, :encrypted_secret_key_iv
    remove_text_limit :dast_site_profiles, :encrypted_secret_key_salt
    remove_text_limit :dast_site_profiles, :secret_key_iv
  end
end
