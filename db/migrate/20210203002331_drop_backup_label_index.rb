# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class DropBackupLabelIndex < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  INDEX_NAME = 'backup_labels_project_id_title_idx'

  def up
    remove_index :backup_labels, name: INDEX_NAME
  end

  def down
    add_index :backup_labels, [:project_id, :title], name: INDEX_NAME, unique: true, where: 'group_id = NULL::integer'
  end
end
