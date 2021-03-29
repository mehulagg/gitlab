# frozen_string_literal: true

class AddTextLimitToCalloutScopeInUserCallouts < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_text_limit :user_callouts, :callout_scope, 255
  end

  def down
    remove_text_limit :user_callouts, :callout_scope
  end
end
