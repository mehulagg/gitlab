# frozen_string_literal: true

class AddDisplayNamespaceIdToSegments < ActiveRecord::Migration[6.0]
  def change
    add_column :analytics_devops_adoption_segments, :display_namespace_id, :integer
    add_foreign_key :analytics_devops_adoption_segments, :namespaces, column: :display_namespace_id, on_delete: :cascade
  end
end
