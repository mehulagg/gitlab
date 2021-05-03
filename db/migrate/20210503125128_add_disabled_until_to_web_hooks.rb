# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddDisabledUntilToWebHooks < ActiveRecord::Migration[6.0]
  def up
    add_column(:web_hooks, :disabled_until, :timestamptz)
  end

  def down
    remove_column(:web_hooks, :disabled_until)
  end
end
