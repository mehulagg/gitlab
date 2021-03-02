# frozen_string_literal: true

class AddTierToEnvironments < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :environments, :tier, :smallint
    end

    add_index :environments, [:project_id, :tier], where: 'tier IS NOT NULL'
  end

  def down
    remove_index :environments, [:project_id, :tier]

    with_lock_retries do
      remove_column :environments, :tier
    end
  end
end
