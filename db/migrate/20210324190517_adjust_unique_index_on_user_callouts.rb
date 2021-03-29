# frozen_string_literal: true

class AdjustUniqueIndexOnUserCallouts < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  OLD_INDEX_NAME = 'index_user_callouts_on_user_id_and_feature_name'
  NEW_INDEX_NAME = 'index_user_callouts_on_user_id_feature_name_and_callout_scope'

  def up
    add_concurrent_index :user_callouts, [:user_id, :feature_name, :callout_scope], unique: true, name: NEW_INDEX_NAME
    remove_concurrent_index_by_name :user_callouts, OLD_INDEX_NAME
  end

  def down
    # Removing duplicate records that would prevent creating the narrower unique index.
    execute <<-SQL
      DELETE FROM user_callouts
      USING (
        SELECT user_id, feature_name, MIN(id) AS min_id
        FROM user_callouts
        GROUP BY user_id, feature_name
        HAVING COUNT(id) > 1
      ) AS user_callout_duplicates
      WHERE user_callout_duplicates.user_id = user_callouts.user_id
        AND user_callout_duplicates.feature_name = user_callouts.feature_name
        AND user_callout_duplicates.min_id <> user_callouts.id
    SQL
    add_concurrent_index :user_callouts, [:user_id, :feature_name], unique: true, name: OLD_INDEX_NAME
    remove_concurrent_index_by_name :user_callouts, NEW_INDEX_NAME
  end
end
