# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class RemoveInstanceStatisticsVisibilityPrivateFromApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    remove_column :application_settings, :instance_statistics_visibility_private
  end

  def down
    add_column :application_settings, :instance_statistics_visibility_private, :boolean, default: false, null: false
  end
end
