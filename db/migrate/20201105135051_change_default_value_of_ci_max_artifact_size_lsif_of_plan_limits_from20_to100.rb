# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class ChangeDefaultValueOfCiMaxArtifactSizeLsifOfPlanLimitsFrom20To100 < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      change_column_default :plan_limits, :ci_max_artifact_size_lsif, 100
      execute('UPDATE plan_limits SET ci_max_artifact_size_lsif = 100 WHERE ci_max_artifact_size_lsif = 20')
    end
  end

  def down
    with_lock_retries do
      change_column_default :plan_limits, :ci_max_artifact_size_lsif, 20
      execute('UPDATE plan_limits SET ci_max_artifact_size_lsif = 20 WHERE ci_max_artifact_size_lsif = 100')
    end
  end
end
