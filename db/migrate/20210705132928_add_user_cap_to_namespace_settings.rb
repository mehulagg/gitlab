# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddUserCapToNamespaceSettings < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def up
    with_lock_retries do
      add_column :namespace_settings, :user_cap, :integer, null: true
    end
  end

  def down
    with_lock_retries do
      remove_column :namespace_settings, :user_cap
    end
  end
end
