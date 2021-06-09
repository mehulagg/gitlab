# frozen_string_literal: true

class MergeRequestDiffCommit < ApplicationRecord
  extend SuppressCompositePrimaryKeyWarning

  include BulkInsertSafe
  include ShaAttribute
  include CachedCommit

  belongs_to :merge_request_diff
  belongs_to :author, class_name: 'MergeRequest::DiffCommitUser'
  belongs_to :committer, class_name: 'MergeRequest::DiffCommitUser'

  sha_attribute :sha
  alias_attribute :id, :sha

  serialize :trailers, Serializers::JSON # rubocop:disable Cop/ActiveRecordSerialize
  validates :trailers, json_schema: { filename: 'git_trailers' }

  # A list of keys of which their values need to be trimmed before they can be
  # inserted into the merge_request_diff_commit_users table.
  TRIM_USER_KEYS =
    %i[author_name author_email committer_name committer_email].freeze

  # Deprecated; use `bulk_insert!` from `BulkInsertSafe` mixin instead.
  # cf. https://gitlab.com/gitlab-org/gitlab/issues/207989 for progress
  def self.create_bulk(merge_request_diff_id, commits)
    user_tuples = Set.new

    commit_hashes = commits.map do |commit|
      hash = commit.to_hash.except(:parent_ids)

      TRIM_USER_KEYS.each do |key|
        hash[key] = MergeRequest::DiffCommitUser.trim(hash[key])
      end

      user_tuples << [hash[:author_name], hash[:author_email]]
      user_tuples << [hash[:committer_name], hash[:committer_email]]

      hash
    end

    users = MergeRequest::DiffCommitUser.bulk_find_or_create(user_tuples)

    rows = commit_hashes.map.with_index do |commit_hash, index|
      sha = commit_hash.delete(:id)
      author = users[[commit_hash[:author_name], commit_hash[:author_email]]]
      committer =
        users[[commit_hash[:committer_name], commit_hash[:committer_email]]]

      commit_hash.merge(
        author_id: author&.id,
        committer_id: committer&.id,
        merge_request_diff_id: merge_request_diff_id,
        relative_order: index,
        sha: Gitlab::Database::ShaAttribute.serialize(sha), # rubocop:disable Cop/ActiveRecordSerialize
        authored_date: Gitlab::Database.sanitize_timestamp(commit_hash[:authored_date]),
        committed_date: Gitlab::Database.sanitize_timestamp(commit_hash[:committed_date]),
        trailers: commit_hash.fetch(:trailers, {}).to_json
      )
    end

    Gitlab::Database.bulk_insert(self.table_name, rows) # rubocop:disable Gitlab/BulkInsert
  end

  def self.oldest_merge_request_id_per_commit(project_id, shas)
    # This method is defined here and not on MergeRequest, otherwise the SHA
    # values used in the WHERE below won't be encoded correctly.
    select(['merge_request_diff_commits.sha AS sha', 'min(merge_requests.id) AS merge_request_id'])
      .joins(:merge_request_diff)
      .joins(
        'INNER JOIN merge_requests ' \
          'ON merge_requests.latest_merge_request_diff_id = merge_request_diffs.id'
      )
      .where(sha: shas)
      .where(
        merge_requests: {
          target_project_id: project_id,
          state_id: MergeRequest.available_states[:merged]
        }
      )
      .group(:sha)
  end
end
