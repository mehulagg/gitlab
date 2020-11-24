# frozen_string_literal: true

class CleanupRenameIssueServiceDeskReplyToToExternalAuthor < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    cleanup_concurrent_column_rename :issues, :service_desk_reply_to, :external_author
  end

  def down
    undo_cleanup_concurrent_column_rename :issues, :service_desk_reply_to, :external_author
  end
end
