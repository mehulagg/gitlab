# frozen_string_literal: true

class AddTextLimitToMailgunSigningKeyOnApplicationSettings < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers
  disable_ddl_transaction!

  def up
    add_text_limit :application_settings, :mailgun_signing_key, 255
  end

  def down
    remove_text_limit :application_settings, :mailgun_signing_key
  end
end
