# frozen_string_literal: true

class AddCloudLicenseAuthTokenApplicationSettingsTextLimit < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_text_limit :application_settings, :cloud_license_auth_token, 255
  end

  def down
    remove_text_limit :application_settings, :cloud_license_auth_token
  end
end
