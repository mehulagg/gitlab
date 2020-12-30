# frozen_string_literal: true

class AddRateLimitingResponseTextToApplicationSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column :application_settings, :rate_limiting_response_text, :text
    add_text_limit :application_settings, :rate_limiting_response_text, 255
  end
end
