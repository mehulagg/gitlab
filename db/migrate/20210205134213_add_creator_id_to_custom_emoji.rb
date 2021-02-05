# frozen_string_literal: true

class AddCreatorIdToCustomEmoji < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    # Custom emoji is still behind a, default-disabled, feature flag so the
    # table (probably) will be empty.
    execute 'DELETE FROM custom_emoji'

    add_column :custom_emoji, :creator_id, :bigint, null: false, index: true

    with_lock_retries do
      add_foreign_key :custom_emoji, :users, on_delete: :cascade, column: :creator_id
    end
  end

  def down
    remove_column :custom_emoji, :creator_id
  end
end
