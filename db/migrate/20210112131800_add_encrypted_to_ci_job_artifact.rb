# frozen_string_literal: true

class AddEncryptedToCiJobArtifact < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :ci_job_artifacts, :encrypted, :boolean
    end
  end

  def down
    with_lock_retries do
      remove_column :ci_job_artifacts, :encrypted
    end
  end
end
