# frozen_string_literal: true

class IndexProjectsOnHasVulnerabilities < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_projects_on_has_vulnerabilities'

  disable_ddl_transaction!

  def up
    add_concurrent_index :projects, :has_vulnerabilities, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :projects, INDEX_NAME
  end
end
