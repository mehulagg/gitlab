# frozen_string_literal: true

# Finder for obtaining commits between two refs, with a Git trailer set.
class CommitsWithTrailerFinder
  # The maximum number of commits to retrieve per page.
  #
  # This value is arbitrarily chosen. Lowering it means more Gitaly calls, but
  # less data being loaded into memory at once. Increasing it has the opposite
  # effect.
  #
  # This amount is based around the number of commits that usually go in a
  # GitLab release. Some examples for GitLab's own releases:
  #
  # * 13.6.0: 4636 commits
  # * 13.5.0: 5912 commits
  # * 13.4.0: 5541 commits
  #
  # Using this limit should result in most (very large) projects only needing
  # 5-10 Gitaly calls, while keeping memory usage at a reasonable amount.
  COMMITS_PER_PAGE = 1024

  def initialize(project:, from:, to:)
    @project = project
    @from = from
    @to = to
  end

  # Fetches all commits that have the given trailer set.
  #
  # Example:
  #
  #     CommitsWithTrailerFinder.new(...).find_with_trailer('Signed-off-by')
  def find_with_trailer(trailer)
    commits = []
    offset = 0
    response = fetch_commits

    # We may end up having to fetch thousands of commits, while we may only need
    # a subset of those commits. To prevent loading all this data into memory at
    # once, we process commits in batches.
    while response.any?
      response.each do |commit|
        commits.push(commit) if commit.trailers.key?(trailer)
      end

      offset += response.length
      response = fetch_commits(offset)
    end

    commits
  end

  private

  def fetch_commits(offset = 0)
    range = "#{@from}..#{@to}"

    @project.repository.commits(range, limit: COMMITS_PER_PAGE, offset: offset)
  end
end
