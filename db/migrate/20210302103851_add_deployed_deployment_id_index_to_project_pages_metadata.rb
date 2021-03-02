# frozen_string_literal: true

class AddDeployedDeploymentIdIndexToProjectPagesMetadata < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  NAME = 'index_pages_metadata_on_pages_deployment_id_and_deployed'

  def up
    add_concurrent_index :project_pages_metadata, :pages_deployment_id, where: "deployed = TRUE", name: NAME
  end

  def down
    remove_concurrent_index_by_name :project_pages_metadata, INDEX_NAME
  end
end
