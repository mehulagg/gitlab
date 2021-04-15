# frozen_string_literal: true

class AddCollapsedDefaultValueToListUserPreferences < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    change_column_default :list_user_preferences, :collapsed, from: nil, to: false
    change_column_null :list_user_preferences, :collapsed, false
  end

  def down
    change_column_null :list_user_preferences, :collapsed, true
    change_column_default :list_user_preferences, :collapsed, from: false, to: nil
  end
end
