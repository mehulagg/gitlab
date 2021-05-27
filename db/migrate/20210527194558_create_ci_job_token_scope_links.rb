# frozen_string_literal: true

class CreateCiJobTokenScopeLinks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:ci_job_token_scope_links)
      with_lock_retries do
        create_table :ci_job_token_scope_links do |t|
          t.belongs_to :source_project, null: false, foreign_key: { to_table: :projects, on_delete: :cascade }
          t.belongs_to :target_project, null: false, foreign_key: { to_table: :projects, on_delete: :cascade }
          t.belongs_to :added_by, foreign_key: { to_table: :users, on_delete: :nullify }
          t.datetime_with_timezone :created_at, null: false

          t.index [:source_project_id, :target_project_id], unique: true, name: 'i_ci_job_token_scope_links_on_source_and_target_project'
        end
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :ci_job_token_scope_links
    end
  end
end
