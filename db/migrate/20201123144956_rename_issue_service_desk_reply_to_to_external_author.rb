# frozen_string_literal: true

class RenameIssueServiceDeskReplyToToExternalAuthor < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    rename_column_concurrently :issues, :service_desk_reply_to, :external_author
  end

  def down
    undo_rename_column_concurrently :issues, :service_desk_reply_to, :external_author
  end
end
