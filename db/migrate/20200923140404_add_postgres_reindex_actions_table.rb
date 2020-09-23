# frozen_string_literal: true

class AddPostgresReindexActionsTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :postgres_reindex_actions, if_not_exists: true do |t|
      t.datetime_with_timezone :reindex_start, null: false
      t.datetime_with_timezone :reindex_end
      t.bigint :ondisk_size_bytes_start, null: false
      t.bigint :ondisk_size_bytes_end
      t.text :index_identifier, null: false, index: true
    end

    add_text_limit(:postgres_reindex_actions, :index_identifier, 255)
  end

  def down
    drop_table :postgres_reindex_actions
  end
end
