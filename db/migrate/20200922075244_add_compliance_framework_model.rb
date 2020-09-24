# frozen_string_literal: true

class AddComplianceFrameworkModel < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:compliance_management_frameworks)
      create_table :compliance_management_frameworks do |t|
        t.text :name, null: false
        t.text :description, null: false
        t.text :color, null: false
      end
    end

    add_text_limit :compliance_management_frameworks, :name, 255
    add_text_limit :compliance_management_frameworks, :description, 255
    add_text_limit :compliance_management_frameworks, :color, 7

    ComplianceManagement::Framework.ensure_default_frameworks!
    execute("ALTER SEQUENCE compliance_management_frameworks_id_seq RESTART WITH 6;")
  end

  def down
    drop_table :compliance_management_frameworks, force: :cascade
  end
end
