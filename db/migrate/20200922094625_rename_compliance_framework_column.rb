# frozen_string_literal: true

class RenameComplianceFrameworkColumn < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  disable_ddl_transaction!

  DOWNTIME = false

  def up
    rename_column_concurrently :project_compliance_framework_settings, :framework, :framework_id, batch_column_name: :project_id
    add_concurrent_foreign_key :project_compliance_framework_settings,
                    :compliance_management_frameworks,
                    on_delete: :cascade, validate: false, column: :framework_id
    add_concurrent_index(:project_compliance_framework_settings, :framework_id, name: 'index_project_compliance_framework_settings_framework_id')
  end

  def down
    remove_concurrent_index(:project_compliance_framework_settings, :framework_id, name: 'index_project_compliance_framework_settings_framework_id')
    remove_foreign_key_if_exists :project_compliance_framework_settings, column: :framework_id
    undo_rename_column_concurrently :project_compliance_framework_settings, :framework, :framework_id
  end
end
