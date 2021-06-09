# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddMergeRequestDiffCommitUserColumns < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    add_column(:merge_request_diff_commits, :author_id, :bigint)
    add_column(:merge_request_diff_commits, :committer_id, :bigint)

    add_concurrent_index(:merge_request_diff_commits, :author_id)
    add_concurrent_index(:merge_request_diff_commits, :committer_id)

    add_concurrent_foreign_key(
      :merge_request_diff_commits,
      :merge_request_diff_commit_users,
      column: :author_id,
      on_delete: :nullify
    )

    add_concurrent_foreign_key(
      :merge_request_diff_commits,
      :merge_request_diff_commit_users,
      column: :committer_id,
      on_delete: :nullify
    )
  end

  def down
    remove_column(:merge_request_diff_commits, :author_id)
    remove_column(:merge_request_diff_commits, :committer_id)
  end
end
