# frozen_string_literal: true

class AddDefaultComplianceFrameworks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false
  DEFAULT_FRAMEWORKS = [
      {
          name: 'GDPR',
          description: 'General Data Protection Regulation',
          color: '#1aaa55',
          id: 1
      },
      {
          name: 'HIPAA',
          description: 'Health Insurance Portability and Accountability Act',
          color: '#1f75cb',
          id: 2
      },
      {
          name: 'PCI-DSS',
          description: 'Payment Card Industry-Data Security Standard',
          color: '#6666c4',
          id: 3
      },
      {
          name: 'SOC 2',
          description: 'Service Organization Control 2',
          color: '#dd2b0e',
          id: 4
      },
      {
          name: 'SOX',
          description: 'Sarbanes-Oxley',
          color: '#fc9403',
          id: 5
      }
  ]

  def up
    DEFAULT_FRAMEWORKS.each do |framework|
      ComplianceManagement::Framework.create!(framework)
    end
    execute("ALTER SEQUENCE compliance_management_frameworks_id_seq RESTART WITH 6;")
    add_foreign_key :project_compliance_framework_settings,
                    :compliance_management_frameworks,
                    on_delete: :cascade, validate: false, column: :framework
  end

  def down
    ComplianceManagement::ComplianceFramework::FRAMEWORKS.each do |_, v|
      ComplianceManagement::Framework.delete(v)
    end

    remove_foreign_key_if_exists :project_compliance_framework_settings, column: :framework
  end
end
