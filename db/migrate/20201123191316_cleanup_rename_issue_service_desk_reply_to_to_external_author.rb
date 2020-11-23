# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

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
