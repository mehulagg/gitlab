# frozen_string_literal: true

class CreateImportConfigurations < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:import_configurations)
      create_table :import_configurations do |t|
        t.references :bulk_import, type: :integer, index: true, null: false, foreign_key: { on_delete: :cascade }

        t.text :encrypted_url
        t.text :encrypted_url_iv

        t.text :encrypted_access_token
        t.text :encrypted_access_token_iv

        t.timestamps_with_timezone
      end
    end

    add_text_limit(:import_configurations, :encrypted_url, 255)
    add_text_limit(:import_configurations, :encrypted_url_iv, 255)
    add_text_limit(:import_configurations, :encrypted_access_token, 255)
    add_text_limit(:import_configurations, :encrypted_access_token_iv, 255)
  end

  def down
    drop_table :import_configurations
  end
end
