# frozen_string_literal: true

class AddTextLimitToRateLimitBypassHeader < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_text_limit :application_settings, :rate_limit_bypass_header, 255
  end

  def down
    remove_text_limit :application_settings, :rate_limit_bypass_header
  end
end
