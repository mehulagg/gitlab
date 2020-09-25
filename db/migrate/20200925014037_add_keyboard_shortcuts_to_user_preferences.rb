# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddKeyboardShortcutsToUserPreferences < ActiveRecord::Migration[6.0]
  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    add_column :user_preferences, :keyboard_shortcuts, :json
  end
end
