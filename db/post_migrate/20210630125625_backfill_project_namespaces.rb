# frozen_string_literal: true

class BackfillProjectNamespaces < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    # TODO: this is a very naive approach
    Project.all.each do |project|
      next if project.personal?
      next if project.project_namespace.present?

      ProjectNamespace.create!(name: project.name, path: "#{project.path}-namespace", parent_id: project.namespace_id, project: project)
    end
  end

  def down
    ProjectNamespace.destroy_all
  end
end
