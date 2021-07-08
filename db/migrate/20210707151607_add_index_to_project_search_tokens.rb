# frozen_string_literal: true

class AddIndexToProjectSearchTokens < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'index_project_search_tokens_token'

  def up
    add_concurrent_index :project_search_tokens, :tokens, name: INDEX_NAME, using: :gin
  end

  def down
    remove_concurrent_index_by_name :project_search_tokens, INDEX_NAME
  end
end
