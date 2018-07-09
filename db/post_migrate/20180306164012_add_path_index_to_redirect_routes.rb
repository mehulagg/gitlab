# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddPathIndexToRedirectRoutes < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false
  disable_ddl_transaction!

  INDEX_NAME = 'index_redirect_routes_on_path_unique_text_pattern_ops'

  # Indexing on LOWER(path) varchar_pattern_ops speeds up the LIKE query in
  # RedirectRoute.matching_path_and_descendants
  #
  # This same index is also added in the `ReworkRedirectRoutesIndexes` so this
  # is a no-op in most cases. But this migration is also called from the
  # `setup_postgresql.rake` task when setting up a new database, in which case
  # we want to create the index.
  def up
    return unless Gitlab::Database.postgresql?

    disable_statement_timeout(transaction: false) do
      unless index_exists_by_name?(:redirect_routes, INDEX_NAME)
        execute("CREATE UNIQUE INDEX CONCURRENTLY #{INDEX_NAME} ON redirect_routes (lower(path) varchar_pattern_ops);")
      end
    end
  end

  def down
    # Do nothing in the DOWN. Since the index above is originally created in the
    # `ReworkRedirectRoutesIndexes`. This migration wouldn't have actually
    # created any new index.
    #
    # This migration is only here to be called form `setup_postgresql.rake` so
    # any newly created database would have this index.
  end
end
