# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateIndexOnNotesNote < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  INDEX_NAME = 'index_notes_on_note_gin_trigram'

  disable_ddl_transaction!

  def up
    add_concurrent_index :notes, :note, name: INDEX_NAME, using: :gin, opclass: :gin_trgm_ops
  end

  def down
    remove_concurrent_index_by_name(:notes, INDEX_NAME)
  end
end
