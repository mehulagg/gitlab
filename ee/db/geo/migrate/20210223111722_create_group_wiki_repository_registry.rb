# frozen_string_literal: true

class CreateGroupWikiRepositoryRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :group_wiki_repository_registry, id: :bigserial, force: :cascade do |t|
      t.datetime_with_timezone :retry_at
      t.datetime_with_timezone :last_synced_at
      t.datetime_with_timezone :created_at, null: false
      t.bigint :group_wiki_repository_id, null: false
      t.integer :state, default: 0, null: false, limit: 2
      t.integer :retry_count, default: 0, limit: 2
      t.text :last_sync_failure
      t.boolean :force_to_redownload
      t.boolean :missing_on_primary

      t.index :group_wiki_repository_id, name: :index_g_wiki_repository_registry_on_group_wiki_repository_id, unique: true
      t.index :retry_at
      t.index :state
    end

    add_text_limit :group_wiki_repository_registry, :last_sync_failure, 255
  end

  def down
    drop_table :group_wiki_repository_registry
  end
end
