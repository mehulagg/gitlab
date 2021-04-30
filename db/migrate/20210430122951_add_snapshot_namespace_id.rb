# frozen_string_literal: true

class AddSnapshotNamespaceId < ActiveRecord::Migration[6.0]
  def change
    add_column :analytics_devops_adoption_snapshots, :namespace_id, :integer
    add_foreign_key :analytics_devops_adoption_snapshots, :namespaces, on_delete: :cascade
  end
end
