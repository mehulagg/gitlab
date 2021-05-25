# frozen_string_literal: true

class AddForeignKeyForLatestPipelineIdToCiPipelines < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :vulnerability_statistics, :ci_pipelines, on_delete: :nullify # why don't we have on-update?
  end
end
