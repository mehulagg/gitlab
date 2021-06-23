# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateBannedUsers < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def change
    create_table :banned_users do |t|
      t.integer :user_id
      t.integer :ban_state

      t.timestamps_with_timezone null: false
    end
  end
end
