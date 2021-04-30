# frozen_string_literal: true

class AddElasticsearchUsernamePasswordToApplicationSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    add_column :application_settings, :elasticsearch_username, :text
    add_column :application_settings, :elasticsearch_password, :text

    add_text_limit :application_settings, :elasticsearch_username, 255
    add_text_limit :application_settings, :elasticsearch_password, 255
  end

  def down
    remove_column :application_settings, :elasticsearch_username
    remove_column :application_settings, :elasticsearch_password
  end
end
