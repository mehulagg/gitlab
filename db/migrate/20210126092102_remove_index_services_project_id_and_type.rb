# frozen_string_literal: true

class RemoveIndexServicesProjectIdAndType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_NAME = 'index_services_on_project_id_and_type'

  def up
    remove_concurrent_index :services, [:project_id, :type], name: INDEX_NAME
  end

  def down
    add_concurrent_index :services, [:project_id, :type], name: INDEX_NAME
  end
end
