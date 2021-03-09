# frozen_string_literal: true

class AddForeignKeyToDastProfileIdOnCiPipeline < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :ci_pipelines, :dast_profiles, column: :dast_profile_id, on_delete: :nullify
  end

  def down
    with_lock_retries do
      remove_foreign_key :ci_pipelines, column: :dast_profile_id
    end
  end
end
