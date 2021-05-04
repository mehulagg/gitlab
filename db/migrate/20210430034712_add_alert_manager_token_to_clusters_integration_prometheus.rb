# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddAlertManagerTokenToClustersIntegrationPrometheus < ActiveRecord::Migration[6.0]
  def change
    change_table :clusters_integration_prometheus do |t|
      t.string :encrypted_alert_manager_token
      t.string :encrypted_alert_manager_token_iv
    end
  end
end
