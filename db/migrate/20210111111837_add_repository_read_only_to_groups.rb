# frozen_string_literal: true

class AddRepositoryReadOnlyToGroups < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :namespaces, :repository_read_only, :boolean, default: false, null: false
  end
end
