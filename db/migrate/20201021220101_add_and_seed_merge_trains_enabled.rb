# frozen_string_literal: true

class AddAndSeedMergeTrainsEnabled < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class ProjectCiCdSetting < ActiveRecord::Base
    self.table_name = 'project_ci_cd_settings'
  end

  def up
    # ProjectCiCdSetting.count # Any ActiveRecord calls on the model that caches the column information.

    add_column_with_default :project_ci_cd_settings, :merge_trains_enabled, :boolean, default: false, allow_null: false

    ProjectCiCdSetting.reset_column_information # The old schema is dropped from the cache.
    ProjectCiCdSetting.find_each do |setting|
      setting.merge_trains_enabled = true if setting.merge_pipelines_enabled == true # confirm # ActiveRecord sees the correct schema here.
      setting.save!
    end
  end

  def down
    remove_column :project_ci_cd_settings, :merge_trains_enabled
  end
end
