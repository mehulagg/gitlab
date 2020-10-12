# frozen_string_literal: true

class CreateSamlGroupLinks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:saml_group_links)
      with_lock_retries do
        create_table :saml_group_links do |t|
          t.references :group, foreign_key: { to_table: :namespaces, on_delete: :cascade }, null: false
          t.timestamps_with_timezone
          t.integer :access_level, null: false
          t.text :group_name, null: false

          t.index [:group_id, :group_name], unique: true
        end
      end
    end

    add_text_limit :saml_group_links, :group_name, 255
  end

  def down
    with_lock_retries do
      drop_table :saml_group_links
    end
  end
end
