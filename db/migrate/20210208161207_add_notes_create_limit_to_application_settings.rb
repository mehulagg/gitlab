# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddNotesCreateLimitToApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :application_settings, :notes_create_limit, :integer, default: 300, null: false
  end
end
