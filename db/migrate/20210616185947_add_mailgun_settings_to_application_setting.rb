# frozen_string_literal: true

class AddMailgunSettingsToApplicationSetting < ActiveRecord::Migration[6.1]
  def change
    # rubocop:disable Migration/AddLimitToTextColumns
    # limit is added in 20210616190446_add_text_limit_to_mailgun_signing_key_on_application_settings
    add_column :application_settings, :mailgun_signing_key, :text
    # rubocop:enable Migration/AddLimitToTextColumns

    add_column :application_settings, :mailgun_events_enabled, :boolean, default: false, null: false
  end
end
