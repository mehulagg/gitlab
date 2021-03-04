# frozen_string_literal: true

class CreateIssueCustomTypes < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    with_lock_retries do
      create_table_with_constraints :issue_custom_types do |t|
        t.text :title, null: false
        t.text :description
        t.text :description_html
        t.integer :cached_markdown_version
        t.references :namespace, foreign_key: { on_delete: :cascade }, index: true, null: true
        t.timestamps_with_timezone null: false

        t.text_limit :title, 255
      end
    end
  end

  def down
    drop_table :issue_custom_types
  end
end
