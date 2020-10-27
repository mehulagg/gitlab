# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MigrateServicesToHttpIntegrations < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  ALERT_SERVICE_TYPE = 'AlertsService'
  SERVICE_NAMES_IDENTIFIER = {
    name: 'Legacy Endpoint',
    identifier: 'legacy'
  }

  class AlertManagement::HttpIntegration < ActiveRecord::Base
    self.table_name = 'alert_management_http_integrations'
  end

  # For each project,
  # Get the Alerts service
  # Create the HttpIntegrations
  def up
    AlertManagement::HttpIntegration.reset_column_information

    sql = <<~SQL
      SELECT * FROM services
      JOIN alerts_service_data
      ON (services.id = alerts_service_data.service_id)
      WHERE type = #{ALERT_SERVICE_TYPE}
    SQL

    select_all(sql).each do |alerts_service|
      AlertManagement::HttpIntegration.create!(
        project_id: alerts_service['project_id'],
        name: SERVICE_NAMES_IDENTIFIER[:name],
        endpoint_identifier: SERVICE_NAMES_IDENTIFIER[:identifier],
        encrypted_token: alerts_service['encrypted_token'],
        encrypted_token_iv: alerts_service['encrypted_token_iv'],
        active: alerts_service['active']
      )
    end
  end

  def down
    # NO-OP
  end
end
