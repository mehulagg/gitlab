class CreateUserPermissionUploads < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      unless table_exists?(:user_permission_uploads)
        create_table :user_permission_uploads do |t|
          t.timestamps_with_timezone null: false
          t.references :user, foreign_key: { on_delete: :cascade }, index: true, null: false
          t.string :status, limit: 255, null: false
          t.string :file, limit: 255
          t.integer :file_store
        end
      end
    end
  end

  def down
    drop_table :user_permission_uploads
  end
end
