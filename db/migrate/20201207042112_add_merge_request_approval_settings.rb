# frozen_string_literal: true

class AddMergeRequestApprovalSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:merge_request_approval_settings)
      with_lock_retries do
        create_table :merge_request_approval_settings do |t|
          t.timestamps_with_timezone null: false
          t.references :namespace, null: true, index: true, foreign_key: { on_delete: :cascade }
          t.boolean :allow_author_approval, null: false, default: true
        end
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :merge_request_approval_settings
    end
  end
end
