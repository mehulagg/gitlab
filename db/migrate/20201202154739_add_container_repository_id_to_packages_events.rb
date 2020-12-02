# frozen_string_literal: true

class AddContainerRepositoryIdToPackagesEvents < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column(:packages_events, :container_repository_id, :bigint, null: true)
  end
end
