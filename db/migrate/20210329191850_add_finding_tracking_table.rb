# frozen_string_literal: true

class AddFindingTrackingTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  TRACKING_IDX = :idx_vuln_trackings_on_occurrences_id_and_tracking_sha
  UNIQ_IDX = :idx_vuln_trackings_uniqueness_tracking_sha

  def up
    with_lock_retries do
      create_table :vulnerability_finding_trackings do |t|
        t.references :finding,
          index: true,
          null: false,
          foreign_key: { to_table: :vulnerability_occurrences, column: :finding_id, on_delete: :cascade }

        t.timestamps_with_timezone null: false

        t.integer :algorithm_type, null: false, limit: 2
        t.binary :tracking_sha, null: false

        t.index %i[finding_id tracking_sha],
          name: TRACKING_IDX,
          unique: true # only one link should exist between occurrence and the tracking

        t.index %i[finding_id algorithm_type tracking_sha],
          name: UNIQ_IDX,
          unique: true # these should be unique
      end
    end

  end

  def down
    with_lock_retries do
      drop_table :vulnerability_finding_trackings
    end
  end
end
