# frozen_string_literal: true

class CreateAlertManagementHttpIntegrations < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :alert_management_http_integrations, if_not_exists: true do |t|
      t.timestamps_with_timezone

      t.bigint :project_id, index: true, null: false
      t.boolean :active, index: true, null: false, default: false

      t.text :encrypted_token
      t.text :encrypted_token_iv

      t.text :endpoint_identifier
      t.text :name
    end

    add_text_limit :alert_management_http_integrations, :encrypted_token, 255
    add_text_limit :alert_management_http_integrations, :encrypted_token_iv, 255
    add_text_limit :alert_management_http_integrations, :endpoint_identifier, 255
    add_text_limit :alert_management_http_integrations, :name, 255
  end

  def down
    drop_table :alert_management_http_integrations
  end
end
