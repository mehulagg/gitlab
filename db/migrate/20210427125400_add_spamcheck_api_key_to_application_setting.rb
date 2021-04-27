
# frozen_string_literal: true

class AddSpamcheckApiKeyToApplicationSetting < ActiveRecord::Migration[6.0]
  def up
    add_column :application_settings, :encrypted_spam_check_api_key, :text
    add_column :application_settings, :encrypted_spam_check_api_key_iv, :text
  end

  def down
    remove_column :application_settings, :encrypted_spam_check_api_key, :text
    remove_column :application_settings, :encrypted_spam_check_api_key_iv, :text
  end
end
