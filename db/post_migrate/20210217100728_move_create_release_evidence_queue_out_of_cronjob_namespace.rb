# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MoveCreateReleaseEvidenceQueueOutOfCronjobNamespace < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    sidekiq_queue_migrate 'cronjob:releases_create_evidence', to: 'releases_create_evidence'
  end

  def down
    sidekiq_queue_migrate 'releases_create_evidence', to: 'cronjob:releases_create_evidence'
  end
end
