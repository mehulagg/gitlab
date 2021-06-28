# frozen_string_literal: true

class ResetJobTokenScopeEnabled < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_column_in_batches(:project_ci_cd_settings, :job_token_scope_enabled, false) do |table, query|
      query.where(table[:job_token_scope_enabled].eq(true))
    end
  end

  def down
    # Irreversible
  end
end
