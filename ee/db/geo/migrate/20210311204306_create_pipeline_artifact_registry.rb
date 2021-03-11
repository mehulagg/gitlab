# frozen_string_literal: true

class CreatePipelineArtifactRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :pipeline_artifact_registry, id: :bigserial, force: :cascade do |t|
      t.bigint :pipeline_artifact_id, null: false
      t.datetime_with_timezone :created_at, null: false
      t.datetime_with_timezone :last_synced_at
      t.datetime_with_timezone :retry_at
      t.datetime_with_timezone :verified_at
      t.datetime_with_timezone :verification_started_at
      t.datetime_with_timezone :verification_retry_at
      t.integer :state, default: 0, null: false, limit: 2
      t.integer :verification_state, default: 0, null: false, limit: 2
      t.integer :retry_count, default: 0, limit: 2
      t.integer :verification_retry_count, default: 0, limit: 2
      t.boolean :checksum_mismatch
      t.binary :verification_checksum
      t.binary :verification_checksum_mismatched
      t.text :verification_failure
      t.text :last_sync_failure

      t.index :pipeline_artifact_id, name: :index_pipeline_artifact_registry_on_pipeline_artifact_id, unique: true
      t.index :retry_at
      t.index :state
      t.index :verification_retry_at, name: :pipeline_artifact_registry_failed_verification, order: "NULLS FIRST", where: "((state = 2) AND (verification_state = 3))"
      t.index :verification_state, name: :pipeline_artifact_registry_needs_verification, where: "((state = 2)  AND (verification_state = ANY (ARRAY[0, 3])))"
      t.index :verified_at, name: :pipeline_artifact_registry_pending_verification, order: "NULLS FIRST", where: "((state = 2) AND (verification_state = 0))"
    end

    add_text_limit :pipeline_artifact_registry, :verification_failure, 255
    add_text_limit :pipeline_artifact_registry, :last_sync_failure, 255
  end

  def down
  end
end
