# frozen_string_literal: true

module MergeRequests
  # OldestPerCommitFinder is used to retrieve the oldest merge requests for
  # every given commit, grouped per commit SHA.
  #
  # This finder is useful when you need to efficiently retrieve the first/oldest
  # merge requests for multiple commits, and you want to do so in batches;
  # instead of running a query for every commit.
  class OldestPerCommitFinder
    def initialize(project)
      @project = project
    end

    def execute(commits)
      # TODO: move to class methods
      id_rows = MergeRequest
        .select([
          'merge_request_diff_commits.sha AS commit_sha',
          'min(merge_requests.id) AS id'
        ])
        .joins('INNER JOIN merge_request_diffs ON merge_requests.latest_merge_request_diff_id = merge_request_diffs.id')
        .joins('INNER JOIN merge_request_diff_commits ON merge_request_diff_commits.merge_request_diff_id = merge_request_diffs.id')
        .where(target_project_id: @project.id)
        .and(
          'merge_request_diff_commits.sha IN (?)',
          commits.map(&:id)
        )
        .group_by(:commit_sha)

      mrs = MergeRequest
        .where(id: id_rows.map { |r| r[:id] })
        .each_with_object({}) do |row, hash|
          hash[row.id] = row
        end

      mr_ids.each_with_object({}) do |row, hash|
        hash[row[:commit_sha]] = mrs[row[:id]]
      end
    end
  end
end
