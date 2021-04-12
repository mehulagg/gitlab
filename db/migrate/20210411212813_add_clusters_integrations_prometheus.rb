# frozen_string_literal: true

class AddClustersIntegrationsPrometheus < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  def up
    with_lock_retries do
      create_table :clusters_integration_prometheus do |t|
        t.references :cluster, index: { unique: true }, null: false, foreign_key: { on_delete: :cascade }
        t.boolean :enabled, null: false, default: true
        t.timestamps_with_timezone null: false
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :clusters_integration_prometheus
    end
  end
end
