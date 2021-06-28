# frozen_string_literal: true

class AddTextLimitToMembersAreaOfFocus < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers
  disable_ddl_transaction!

  def up
    add_text_limit :members, :area_of_focus, 255
  end

  def down
    # Down is required as `add_text_limit` is not reversible
    remove_text_limit :members, :area_of_focus
  end
end
