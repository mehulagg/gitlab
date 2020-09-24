# frozen_string_literal: true

class RenameComplianceFrameworkForeignKey < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    cleanup_concurrent_column_rename :project_compliance_framework_settings, :framework, :framework_id
  end

  def down
    undo_cleanup_concurrent_column_rename :project_compliance_framework_settings, :framework, :framework_id, batch_column_name: :project_id
  end
end
