# frozen_string_literal: true

class AddIndexToIssuesUpvotesCount < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'index_issues_on_upvotes_count'

  def up
    add_concurrent_index :issues, :upvotes_count, name: INDEX_NAME
  end

  def down
    remove_concurrent_index :issues, :upvotes_count, name: INDEX_NAME
  end
end
