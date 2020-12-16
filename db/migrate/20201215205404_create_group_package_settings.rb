# frozen_string_literal: true

class CreateGroupPackageSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :group_package_settings, if_not_exists: true, id: false do |t|
        t.references :group, primary_key: true, index: false, null: false, foreign_key: { to_table: :namespaces, on_delete: :cascade }, type: :bigint
        t.boolean :maven_duplicates_allowed, null: false, default: true
        t.text :maven_duplicate_exception_regex, null: false, default: ''
      end
    end

    add_text_limit :group_package_settings, :maven_duplicate_exception_regex, 255
  end

  def down
    drop_table :group_package_settings
  end
end
