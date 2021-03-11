# frozen_string_literal: true

class CleanUpAssetProxyWhitelistRenameOnApplicationSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers::V2

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    # no-op
  end

  def down
    # no-op
  end
end
