# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CascadeDeleteFreezePeriods < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    remove_foreign_key :ci_freeze_periods, :projects, column: :project_id
    add_concurrent_foreign_key :ci_freeze_periods, :projects, column: :project_id, on_delete: :cascade
  end

  def down
    remove_foreign_key :ci_freeze_periods, :projects, column: :project_id
    add_concurrent_foreign_key :ci_freeze_peroiods, :projects, column: :project_id, on_delete: nil
  end
end
