# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddPartialTemporaryIndexToServicesOnProjectId < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'tmp_index_on_project_id_partial_with_prometheus_services'
  PARTIAL_FILTER = "type = 'PrometheusService'"

  disable_ddl_transaction!

  def up
    add_concurrent_index :services, [:project_id, :id], where: PARTIAL_FILTER, name: INDEX_NAME
  end

  def down
    remove_concurrent_index :services, [:project_id, :id], where: PARTIAL_FILTER, name: INDEX_NAME
  end
end
