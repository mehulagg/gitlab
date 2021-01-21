# frozen_string_literal: true

class AddDevopsAdoptionGroupSegment < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :analytics_devops_adoption_segments, :namespace_id, :integer
    add_concurrent_foreign_key :analytics_devops_adoption_segments, :namespaces, column: :namespace_id
    add_concurrent_index :analytics_devops_adoption_segments, :namespace_id, unique: true
  end

  def down
    remove_column :analytics_devops_adoption_segments, :namespace_id
  end
end
