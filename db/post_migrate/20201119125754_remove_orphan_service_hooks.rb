# frozen_string_literal: true

class RemoveOrphanServiceHooks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false

  def up
    migrate_async('RemoveOrphanServiceHooks')
  end

  def down
    # no-op
  end
end
