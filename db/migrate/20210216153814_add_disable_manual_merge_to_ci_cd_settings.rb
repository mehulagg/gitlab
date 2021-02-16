# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddDisableManualMergeToCiCdSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :project_ci_cd_settings, :merge_trains_manual_merge_disabled, :boolean, default: false
    end
  end
  
  def down
    with_lock_retries do
      remove_column :project_ci_cd_settings, :merge_trains_manual_merge_disabled
    end
  end
end
