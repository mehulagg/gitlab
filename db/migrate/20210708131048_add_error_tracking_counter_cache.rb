# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddErrorTrackingCounterCache < ActiveRecord::Migration[6.1]
  def up
    add_column :error_tracking_errors, :events_count, :integer
  end

  def down
    remove_column :error_tracking_errors, :events_count
  end
end
