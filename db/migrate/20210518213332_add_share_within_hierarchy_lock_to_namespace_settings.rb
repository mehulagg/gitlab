# frozen_string_literal: true

class AddShareWithinHierarchyLockToNamespaceSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :namespace_settings, :share_within_hierarchy_lock, :boolean, default: false, null: false
  end
end
