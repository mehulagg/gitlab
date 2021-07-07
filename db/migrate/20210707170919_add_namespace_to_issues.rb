# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddNamespaceToIssues < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    add_column :issues, :project_namespace_id, :integer

    with_lock_retries do
      add_foreign_key :issues, :namespaces, column: :project_namespace_id
    end
  end

  def down
    remove_column :issues, :project_namespace_id
  end
end
