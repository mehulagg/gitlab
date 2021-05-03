# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class TestMigration < ActiveRecord::Migration[6.0]
  # Uncomment the following include if you require helper functions:
  # include Gitlab::Database::MigrationHelpers

  # When using the methods "add_concurrent_index" or "remove_concurrent_index"
  # you must disable the use of transactions
  # as these methods can not run in an existing transaction.
  # When using "add_concurrent_index" or "remove_concurrent_index" methods make sure
  # that either of them is the _only_ method called in the migration,
  # any other changes should go in a separate migration.
  # This ensures that upon failure _only_ the index creation or removing fails
  # and can be retried or reverted easily.
  #
  # To disable transactions uncomment the following line and remove these
  # comments:
  # disable_ddl_transaction!

  def change
    add_column :user_statuses, :test, :integer
  end
end
