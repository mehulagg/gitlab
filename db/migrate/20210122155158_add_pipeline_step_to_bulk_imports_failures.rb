# frozen_string_literal: true

class AddPipelineStepToBulkImportsFailures < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :bulk_import_failures, :pipeline_step, :text
    end

    add_text_limit :bulk_import_failures, :pipeline_step, 255
  end

  def down
    with_lock_retries do
      remove_column :bulk_import_failures, :pipeline_step
    end
  end
end
