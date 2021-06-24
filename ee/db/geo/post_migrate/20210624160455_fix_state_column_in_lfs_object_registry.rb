# frozen_string_literal: true

class FixStateColumnInLfsObjectRegistry < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_column_in_batches(:lfs_object_registry, :state, 2) do |table, query|
      query.where(table[:success].eq(true))
    end
  end

  def down
    # no-op
  end
end
