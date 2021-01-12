# frozen_string_literal: true

class ChangeNamespacesDelayedProjectRemovalNull < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    change_column :namespaces, :delayed_project_removal, :boolean, null: true, default: nil
  end

  def down
    change_column_default :namespaces, :delayed_project_removal, false
    change_column_null :namespaces, :delayed_project_removal, false, false
  end
end
