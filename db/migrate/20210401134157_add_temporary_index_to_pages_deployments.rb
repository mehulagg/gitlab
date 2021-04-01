# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTemporaryIndexToPagesDeployments < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'tmp_index_pages_deployments_on_file_store'

  def up
    add_concurrent_index :pages_deployments, :file_store, name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :pages_deployments, INDEX_NAME
  end
end
