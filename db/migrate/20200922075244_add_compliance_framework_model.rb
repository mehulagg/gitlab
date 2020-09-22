class AddComplianceFrameworkModel < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:compliance_management_frameworks)
      create_table :compliance_management_frameworks do |t|
        t.text :name, null: false
        t.text :description
        t.text :color
      end
    end

    add_text_limit :compliance_management_frameworks, :name, 255
    add_text_limit :compliance_management_frameworks, :description, 255
    add_text_limit :compliance_management_frameworks, :color, 7
  end

  def down
    drop_table :compliance_management_frameworks
  end
end
