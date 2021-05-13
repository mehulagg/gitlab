# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddNamespaceLocks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :namespace_locks, id: false do |t|
        t.references :namespace,
          primary_key: true,
          index: true,
          type: :bigint,
          foreign_key: { on_delete: :cascade }
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :namespace_locks
    end
  end
end
