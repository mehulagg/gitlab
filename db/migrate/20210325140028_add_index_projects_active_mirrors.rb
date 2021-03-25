# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexProjectsActiveMirrors < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  INDEX_NAME = 'index_projects_active_mirrors'

  disable_ddl_transaction!

  def up
    add_concurrent_index :projects,
      :id,
      where: "(archived = false) AND (pending_delete = false) AND (mirror=true)",
      name: INDEX_NAME
  end

  def down
    remove_concurrent_index :projects,
      :id,
      where: "(archived = false) AND (pending_delete = false) AND (mirror=true)",
      name: INDEX_NAME
  end
end
