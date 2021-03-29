# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTargetProjectAndSourceBranchIndexToMergeRequest < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  # INDEX = 'index_merge_request_project_id_policy_project_id'

  disable_ddl_transaction!

  def up
    add_concurrent_index :merge_requests, [:target_project_id, :source_branch]
  end

  def down
    remove_concurrent_index :merge_requests, [:target_project_id, :source_branch]
  end
end
