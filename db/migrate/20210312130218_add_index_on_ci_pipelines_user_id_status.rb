# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexOnCiPipelinesUserIdStatus < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_ci_pipelines_on_user_id_status'

  disable_ddl_transaction!

  def up
    add_concurrent_index(:ci_pipelines, %i[user_id status], name: INDEX_NAME)
  end

  def down
    remove_concurrent_index_by_name(:ci_pipelines, INDEX_NAME)
  end
end
