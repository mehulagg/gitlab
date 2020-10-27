# frozen_string_literal: true

class AddIndexToOauthAccessGrantsResourceOwnerId < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_oauth_access_grants_on_resource_owner_id'

  disable_ddl_transaction!

  def up
    add_concurrent_index(
      :oauth_access_grants,
        :resource_owner_id,
      name: INDEX_NAME
    )
  end

  def down
    remove_concurrent_index_by_name(:oauth_access_grants, INDEX_NAME)
  end
end
