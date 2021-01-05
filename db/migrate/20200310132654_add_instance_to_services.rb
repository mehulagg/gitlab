# frozen_string_literal: true

class AddInstanceToServices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  # rubocop:disable Migration/AddColumnWithDefault
  def up
    add_column_with_default(:services, :instance, :boolean, default: false)
  end
  # rubocop:enable Migration/AddColumnWithDefault

  def down
    remove_column(:services, :instance)
  end
end
