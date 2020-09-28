# frozen_string_literal: true

class CreateRequiredCodeOwnersSections < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:required_code_owners_sections)
      with_lock_retries do
        create_table :required_code_owners_sections do |t|
          t.references :protected_branch, null: false, foreign_key: { on_delete: :cascade }
          t.text :name, null: false
        end
      end
    end

    add_text_limit :required_code_owners_sections, :name, 1024
  end

  def down
    if table_exists?(:required_code_owners_sections)
      with_lock_retries do
        drop_table :required_code_owners_sections
      end
    end
  end
end
