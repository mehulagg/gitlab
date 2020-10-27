# frozen_string_literal: true

class AddRateLimitBypassHeader < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/AddLimitToTextColumns
  # limit is added in 20201027171007_add_text_limit_to_rate_limit_bypass_header
  def change
    add_column :application_settings, :rate_limit_bypass_header, :text
  end
end
