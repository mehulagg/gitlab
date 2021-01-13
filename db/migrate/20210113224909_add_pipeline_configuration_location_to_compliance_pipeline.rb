# frozen_string_literal: true

class AddPipelineConfigurationLocationToCompliancePipeline < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless column_exists?(:compliance_management_frameworks, :pipeline_configuration_location)
      with_lock_retries do
        add_column :compliance_management_frameworks, :pipeline_configuration_location, :text
      end
    end

    add_text_limit :compliance_management_frameworks, :pipeline_configuration_location, 255
  end

  def down
    with_lock_retries do
      remove_column :compliance_management_frameworks, :pipeline_configuration_location
    end

    remove_text_limit :compliance_management_frameworks, :pipeline_configuration_location
  end
end
