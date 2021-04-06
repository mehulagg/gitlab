# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class ShadowProjectBackfill < ActiveRecord::Migration[6.0]
  class Project < ActiveRecord::Base
  end

  class Namespace < ActiveRecord::Base
    self.inheritance_column = :_type_disabled
  end

  def up
    # TODO - break these into BG migrations
    admin = User.find_by_admin(true)

    Namespace.where(parent_id: nil).find_each do |namespace|
      # TODO: make name/path generation more robust
      # TODO: N+1 in finding parents
      project = Project.create!(namespace_id: namespace.id, shadow: true, name: "#{namespace.name}-shadow", path: "#{namespace.path}-shadow", creator_id: admin.id)
      backfill_descendants(namespace, project, admin)
    end
  end

  def down
    Project.where(shadow: true).delete_all
  end

  # TODO - create proper BG migration
  def backfill_descendants(parent_namespace, parent_project, admin)
    Namespace.where(parent_id: parent_namespace.id).find_each do |namespace|
      project = Project.create!(namespace_id: namespace.id, shadow: true, name: "#{namespace.name}-shadow", path: "#{namespace.path}-shadow", creator_id: admin.id, parent_id: parent_project.id)
      backfill_descendants(namespace, project, admin)
    end
  end
end
