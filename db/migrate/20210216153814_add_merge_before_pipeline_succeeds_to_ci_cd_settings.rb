# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddMergeBeforePipelineSucceedsToCiCdSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :project_ci_cd_settings, :merge_before_pipeline_completes_enabled, :boolean, default: true, null: false
    end
  end

  def down
    with_lock_retries do
      remove_column :project_ci_cd_settings, :merge_before_pipeline_completes_enabled
    end
  end
end
