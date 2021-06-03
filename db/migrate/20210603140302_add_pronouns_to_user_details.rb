# frozen_string_literal: true

class AddPronounsToUserDetails < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :user_details, :pronouns, :text, null: true

    add_text_limit :user_details, :pronouns, 50, constraint_name: 'user_details_pronouns'
  end

  def down
    remove_column :user_details, :pronouns
  end
end
