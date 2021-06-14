# frozen_string_literal: true

class AddTextLimitToDetectionMethod < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers
  disable_ddl_transaction!

  def up
    add_text_limit :vulnerability_occurrences, :detection_method, 255
  end

  def down
    remove_text_limit :vulnerability_occurrences, :detection_method
  end
end
