# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Migrates author and committer names and emails from
    # merge_request_diff_commits to two columns that point to
    # merge_request_diff_commit_users.
    #
    # rubocop: disable Style/Documentation
    class MigrateMergeRequestDiffCommitUsers
      # The number of user rows in merge_request_diff_commit_users to get in a
      # single query.
      ROWS_PER_QUERY = 1_000

      # The maximum number of characters a value in
      # merge_request_diff_commit_users can store.
      MAX_CHARS = 512

      class MergeRequestDiffCommit < ActiveRecord::Base
        extend ::SuppressCompositePrimaryKeyWarning

        self.table_name = 'merge_request_diff_commits'

        def self.rows_to_migrate(start_id, stop_id)
          MergeRequestDiffCommit
            .select([
              :merge_request_diff_id,
              :relative_order,
              :author_name,
              :author_email,
              :committer_name,
              :committer_email
            ])
            .where(merge_request_diff_id: start_id..stop_id)
        end
      end

      class MergeRequestDiffCommitUser < ActiveRecord::Base
        self.table_name = 'merge_request_diff_commit_users'

        def self.union(queries)
          from("(#{queries.join("\nUNION\n")}) #{table_name}")
        end

        def self.create_or_find(name, email)
          create!(name: name, email: email)
        rescue ActiveRecord::RecordNotUnique
          find_by(name: name, email: email)
        end
      end

      def perform(start_id, stop_id)
        # This Hash maps user names + emails to their corresponding rows in
        # merge_request_diff_commit_users.
        user_mapping = {}

        user_details, diff_rows_to_update = get_data_to_update(start_id, stop_id)

        get_user_rows_in_batches(user_details, user_mapping)
        create_missing_users(user_details, user_mapping)
        update_diff_rows(diff_rows_to_update, user_mapping)
      end

      # Returns the data we'll use to determine what merge_request_diff_commits
      # rows to update, and what data to use for populating their author_id and
      # committer_id columns.
      def get_data_to_update(start_id, stop_id)
        # This Set is used to retrieve users that already exist in
        # merge_request_diff_commit_users.
        users = Set.new

        # This Hash maps the primary key of every row in
        # merge_request_diff_commits to the (trimmed) author and committer
        # details to use for updating the row.
        to_update = {}

        MergeRequestDiffCommit.rows_to_migrate(start_id, stop_id).each do |row|
          author = [trim(row.author_name), trim(row.author_email)]
          committer = [trim(row.committer_name), trim(row.committer_email)]

          to_update[[row.merge_request_diff_id, row.relative_order]] =
            [author, committer]

          users << author
          users << committer
        end

        [users, to_update]
      end

      # Gets any existing rows in merge_request_diff_commit_users in batches.
      #
      # This method may end up having to retrieve lots of rows. To reduce the
      # overhead, we batch queries into a UNION query. We limit the number of
      # queries per UNION so we don't end up sending a single query containing
      # too many SELECT statements.
      def get_user_rows_in_batches(users, user_mapping)
        users.each_slice(ROWS_PER_QUERY) do |pairs|
          queries = pairs.map do |(name, email)|
            MergeRequestDiffCommitUser.where(name: name, email: email).to_sql
          end

          MergeRequestDiffCommitUser.union(queries).each do |row|
            user_mapping[row.name.to_s + row.email.to_s] = row
          end
        end
      end

      # Creates any users for which no row exists in
      # merge_request_diff_commit_users.
      #
      # Not all users queried may exist yet, so we need to create any missing
      # ones; making sure we handle concurrent creations of the same user
      def create_missing_users(users, mapping)
        users.each do |(name, email)|
          mapping[name + email] ||=
            MergeRequestDiffCommitUser.create_or_find(name, email)
        end
      end

      # Updates rows in merge_request_diff_commits with their new author_id and
      # committer_id values.
      def update_diff_rows(to_update, user_mapping)
        MergeRequestDiffCommitUser.transaction do
          to_update.each do |(diff_id, order), (author, committer)|
            author_id = user_mapping[author.join]&.id
            committer_id = user_mapping[committer.join]&.id

            MergeRequestDiffCommit
              .where(merge_request_diff_id: diff_id, relative_order: order)
              .update_all(author_id: author_id, committer_id: committer_id)
          end
        end
      end

      def trim(value)
        value.to_s[0..MAX_CHARS]
      end
    end
    # rubocop: enable Style/Documentation
  end
end
