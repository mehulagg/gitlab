# frozen_string_literal: true

class CreatePagesDeploymentRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    unless table_exists?(:pages_deployment_registry)
      ActiveRecord::Base.transaction do
        create_table :pages_deployment_registry, id: :bigserial, force: :cascade do |t|
          t.bigint :pages_deployment_id, null: false
          t.datetime_with_timezone :created_at, null: false
          t.datetime_with_timezone :last_synced_at
          t.datetime_with_timezone :retry_at
          t.datetime_with_timezone :verified_at
          t.datetime_with_timezone :verification_started_at
          t.datetime_with_timezone :verification_retry_at
          t.integer :state, default: 0, null: false, limit: 2
          t.integer :verification_state, default: 0, null: false, limit: 2
          t.integer :retry_count, default: 0, limit: 2, null: false
          t.integer :verification_retry_count, default: 0, limit: 2, null: false
          t.boolean :checksum_mismatch, default: false, null: false
          t.binary :verification_checksum
          t.binary :verification_checksum_mismatched
          t.string :verification_failure, limit: 255 # rubocop:disable Migration/PreventStrings see https://gitlab.com/gitlab-org/gitlab/-/issues/323806
          t.string :last_sync_failure, limit: 255 # rubocop:disable Migration/PreventStrings see https://gitlab.com/gitlab-org/gitlab/-/issues/323806

          t.index :pages_deployment_id, name: :index_pages_deployment_registry_on_pages_deployment_id, unique: true
          t.index :retry_at
          t.index :state
          # To optimize performance of PagesDeploymentRegistry.verification_failed_batch
          t.index :verification_retry_at, name:  :pages_deployment_registry_failed_verification, order: "NULLS FIRST",  where: "((state = 2) AND (verification_state = 3))"
          # To optimize performance of PagesDeploymentRegistry.needs_verification_count
          t.index :verification_state, name:  :pages_deployment_registry_needs_verification, where: "((state = 2)  AND (verification_state = ANY (ARRAY[0, 3])))"
          # To optimize performance of PagesDeploymentRegistry.verification_pending_batch
          t.index :verified_at, name: :pages_deployment_registry_pending_verification, order: "NULLS FIRST", where: "((state = 2) AND (verification_state = 0))"
        end
      end
    end
  end

  def down
    drop_table :pages_deployment_registry
  end
end

