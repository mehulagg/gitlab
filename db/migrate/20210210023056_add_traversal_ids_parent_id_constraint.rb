# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTraversalIdsParentIdConstraint < ActiveRecord::Migration[6.0]
  # Uncomment the following include if you require helper functions:
  # include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # When a migration requires downtime you **must** uncomment the following
  # constant and define a short and easy to understand explanation as to why the
  # migration requires downtime.
  # DOWNTIME_REASON = ''

  # When using the methods "add_concurrent_index", "remove_concurrent_index" or
  # "add_column_with_default" you must disable the use of transactions
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

  def up
    execute "ALTER TABLE namespaces ADD CONSTRAINT traversal_ids_id CHECK (id = traversal_ids[array_length(traversal_ids, 1)])"
    # Once we remove the feature flag the first part of the constraint should be:
    #   parent_id IS NULL AND traversal_ids = ARRAY[id]
    constraint = """
                 (
                   parent_id IS NULL
                 ) OR (
                   parent_id IS NOT NULL AND
                   array_length(traversal_ids, 1) >= 2 AND parent_id = traversal_ids[array_length(traversal_ids, 1)-1]
                 )
                 """
    execute "ALTER TABLE namespaces ADD CONSTRAINT traversal_ids_parent_id CHECK (#{constraint})"
  end

  def down
    execute "ALTER TABLE namespaces DROP CONSTRAINT traversal_ids_id"
    execute "ALTER TABLE namespaces DROP CONSTRAINT traversal_ids_parent_id"
  end
end
