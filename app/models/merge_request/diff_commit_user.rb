# frozen_string_literal: true

class MergeRequest::DiffCommitUser < ApplicationRecord
  has_many :merge_request_diff_commits

  # The maximum number of characters for a name or Email address.
  MAX_CHARS = 512

  # The number of existing rows to get when bulk creating rows.
  ROWS_PER_QUERY = 1_000

  # Trims a name or Email address so it fits within the maximum number of
  # characters that can be stored.
  def self.trim(value)
    value.to_s[0..MAX_CHARS]
  end

  # Finds or creates rows for the given pairs of names and Emails.
  #
  # The `names_and_emails` argument must be an Array/Set of tuples like so:
  #
  #     [
  #       [name, email],
  #       [name, email],
  #       ...
  #     ]
  #
  # This method expects that the names and Emails have already been trimmed to
  # at most 512 characters.
  #
  # The return value is a Hash that maps these tuples to instances of this
  # model.
  def self.bulk_find_or_create(names_and_emails)
    queries = {}
    mapping = {}

    names_and_emails.each do |(name, email)|
      queries[[name, email]] = where(name: name, email: email).to_sql
    end

    # We may end up having to create many users. To ensure we don't hit any
    # query size limits, we get a fixed number of users at a time.
    queries.values.each_slice(ROWS_PER_QUERY).map do |slice|
      from("(#{slice.join("\nUNION\n")}) #{table_name}").each do |row|
        mapping[[row.name, row.email]] = row
      end
    end

    queries.keys.each do |(name, email)|
      mapping[[name, email]] ||=
        begin
          create!(name: name, email: email)
        rescue ActiveRecord::RecordNotUnique
          find_by(name: name, email: email)
        end
    end

    mapping
  end
end
