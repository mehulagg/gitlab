# frozen_string_literal: true

class AddDefaultBranchNameToNamespaceSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/AddLimitToTextColumns
  def change
    add_column :namespace_settings, :default_branch_name, :text
  end
  # rubocop:enable Migration/AddLimitToTextColumns
end
