# frozen_string_literal: true

class AddDastProfileIdToCiPipeline < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :ci_pipelines, :dast_profile_id, :integer # rubocop:disable Migration/AddColumnsToWideTables
    end
  end

  def down
    with_lock_retries do
      remove_column :ci_pipelines, :dast_profile_id
    end
  end
end
