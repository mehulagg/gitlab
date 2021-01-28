# frozen_string_literal: true

class AddGitCliSessionExpiryToApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column(:application_settings, :git_cli_session_expiry, :integer, default: 15, null: false)
  end
end
