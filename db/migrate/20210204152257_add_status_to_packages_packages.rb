# frozen_string_literal: true

class AddStatusToPackagesPackages < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :packages_packages, :status, :integer, limit: 2, default: 1, null: false
  end
end
