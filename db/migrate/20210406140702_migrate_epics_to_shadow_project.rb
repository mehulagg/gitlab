# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MigrateEpicsToShadowProject < ActiveRecord::Migration[6.0]
  DOWNTIME = false
  disable_ddl_transaction!

  class Epic < ActiveRecord::Base
  end

  class Project < ActiveRecord::Base
  end

  class Namespace < ActiveRecord::Base
    self.inheritance_column = :_type_disabled

    has_one :shadow_project, -> { where(shadow: true) }, dependent: :destroy, class_name: 'Project'
  end

  def up
    add_column :epics, :project_id, :bigint
    add_concurrent_foreign_key :epics, :projects, on_delete: :cascade

    # TODO: require either project or group not null
    change_column_null :epics, :group_id, true

    # TODO
    Epic.reset_column_information
    Namespace.reset_column_information

    # TODO: for POC only - convert to a regular BG migration
    # set shadow project reference for each epic
    Namespace.find_each do |group|
      raise "shadow project not found" unless group.shadow_project

      Epic.where(group_id: group.id).update_all(project_id: group.shadow_project.id)
    end
  end

  def down
    remove_column :epics, :project_id, :bigint
  end
end
