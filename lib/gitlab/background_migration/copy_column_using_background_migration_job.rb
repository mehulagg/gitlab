# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Background migration built based on CopyColumn to update the value of a
    # column using the value of another column in the same table.
    #
    # - The {start_id, end_id} arguments are at the start so that it can be used
    #   with queue_background_migration_jobs_by_range_at_intervals
    # - The table that is migrated does _not_ need `id` as the primary key
    #   We use the provided primary_key column to perform the update.
    # - Provides support for background job tracking through the use of
    #   Gitlab::Database::BackgroundMigrationJob
    # - We skip the NULL checks as we may want to also copy columns with NULLs
    class CopyColumnUsingBackgroundMigrationJob
      # start_id - The start ID of the range of rows to update.
      # end_id - The end ID of the range of rows to update.
      # table - The name of the table that contains the columns.
      # primary_key - The primary key column of the table.
      # copy_from - The column containing the data to copy.
      # copy_to - The column to copy the data to.
      def perform(start_id, end_id, table, primary_key, copy_from, copy_to)
        quoted_table = connection.quote_table_name(table)
        quoted_primary_key = connection.quote_column_name(primary_key)
        quoted_copy_from = connection.quote_column_name(copy_from)
        quoted_copy_to = connection.quote_column_name(copy_to)

        connection.execute <<-SQL.strip_heredoc
        UPDATE #{quoted_table}
        SET #{quoted_copy_to} = #{quoted_copy_from}
        WHERE #{quoted_primary_key} BETWEEN #{start_id} AND #{end_id}
        SQL

        mark_job_as_succeeded(start_id, end_id, table, primary_key, copy_from, copy_to)
      end

      private

      def connection
        ActiveRecord::Base.connection
      end

      def mark_job_as_succeeded(*arguments)
        Gitlab::Database::BackgroundMigrationJob.mark_all_as_succeeded(self.class.name, arguments)
      end
    end
  end
end
