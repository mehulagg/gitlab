# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIssueIdToTestReport < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :requirements_management_test_reports, :issue_id, :bigint, null: true
    end
    add_concurrent_foreign_key :requirements_management_test_reports, :issues, column: :issue_id
  end

  def down
    with_lock_retries do
      remove_foreign_key_if_exists(:requirements_management_test_reports, column: :issue_id)
    end

    with_lock_retries do
      remove_column :requirements_management_test_reports, :issue_id
    end
  end
end
