# frozen_string_literal: true

class AddPreventForkingOutsideGroupToNamespaceSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :namespace_settings, :lock_prevent_forking_outside_group, :boolean, default: false, null: false
  end
end
