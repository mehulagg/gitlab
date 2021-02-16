# frozen_string_literal: true

class RemoveIndexOnIssuesWhereServiceDeskReplyToIsNotNull < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_TABLE = :issues
  INDEX_NAME = 'idx_on_issues_where_service_desk_reply_to_is_not_null'

  def up
    if index_exists_by_name? INDEX_TABLE, INDEX_NAME
      remove_concurrent_index_by_name INDEX_TABLE, INDEX_NAME
    end
  end

  def down
    # noop
  end
end
