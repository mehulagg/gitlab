# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTrackingFingerprintTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  FULL_SHA_IDX = :idx_vuln_tracking_fingerprints_on_occurrences_id_and_full_sha
  UNIQ_IDX = :idx_vuln_tracking_fingerprints_uniqueness

  def up
    with_lock_retries do
      create_table :vulnerability_tracking_fingerprints do |t|
        t.references :finding,
          references: :vulnerability_occurrences,
          column: :finding_id,
          index: true,
          null: false
        t.foreign_key :vulnerability_occurrences, column: :finding_id, on_delete: :cascade

        t.binary :inner_sha, null: false
        t.integer :priority, null: false
        t.integer :type, null: false
        t.integer :method, null: false

        t.binary :full_sha, null: false

        t.index %i[finding_id full_sha],
          name: FULL_SHA_IDX,
          unique: true # only one link should exist between occurrence and the full sha

        t.index %i[finding_id type method inner_sha],
          name: UNIQ_IDX,
          unique: true # these should be unique

        t.timestamps_with_timezone null: false
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :vulnerability_tracking_fingerprints
    end
  end
end
