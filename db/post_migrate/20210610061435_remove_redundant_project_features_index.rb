# frozen_string_literal: true

class RemoveRedundantProjectFeaturesIndex < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'index_project_features_on_project_id'

  def up
    remove_concurrent_index_by_name('project_features', INDEX_NAME)
  end

  def down
    add_concurrent_index('project_features', :project_id, name: INDEX_NAME, unique: true)
  end
end
