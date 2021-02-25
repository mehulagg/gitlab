# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTextLimitToUserPreferencesCompanyName < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_text_limit :user_preferences, :company_name, 512
  end

  def down
    # Down is required as `add_text_limit` is not reversible
    remove_text_limit :user_preferences, :company_name
  end
end
