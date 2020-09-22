# frozen_string_literal: true

class CreateGroupImportData < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:group_import_data?)
      with_lock_retries do
        create_table :group_import_data do |t|
          t.references :group, type: :integer, index: true, null: false, foreign_key: { to_table: :namespaces, on_delete: :cascade }

          t.text :encrypted_api_url
          t.text :encrypted_api_url_iv

          t.text :encrypted_access_token
          t.text :encrypted_access_token_iv

          t.timestamps_with_timezone
        end
      end
    end

    add_text_limit(:group_import_data, :encrypted_api_url, 255)
    add_text_limit(:group_import_data, :encrypted_api_url_iv, 255)
    add_text_limit(:group_import_data, :encrypted_access_token, 255)
    add_text_limit(:group_import_data, :encrypted_access_token_iv, 255)
  end

  def down
    with_lock_retries do
      drop_table :group_import_data
    end
  end
end
