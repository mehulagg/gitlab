# frozen_string_literal: true

module Repositories
  class ChangelogService
    DEFAULT_TRAILER = 'Changelog'
    DEFAULT_FILE = 'CHANGELOG.md'

    # rubocop: disable Metrics/ParameterLists
    def initialize(
      project,
      user,
      version:,
      from:,
      to:,
      date: DateTime.now,
      branches: [default_branch],
      trailer: DEFAULT_TRAILER,
      file: DEFAULT_FILE,
      message: "Add changelog for version #{version}"
    )
      @project = project
      @user = user
      @version = version
      @from = from
      @to = to
      @date = date
      @branches = branches
      @trailer = trailer
      @file = file
      @message = message
    end
    # rubocop: enable Metrics/ParameterLists

    def execute
      mrs_finder = MergeRequests::OldestPerCommitFinder.new(@project)
      config = Gitlab::Changelog::Config.from_git(@project)
      release = Gitlab::Changelog::Release
        .new(version: @version, date: @date, config: config)

      CommitsWithTrailerFinder
        .new(project: @project, from: @from, to: @to)
        .each_page(@trailer) do |page|
          mrs = mrs_finder.execute(page.map(&:id))

          # Preload the authors.
          page.each(&:lazy_author)

          page.each do |commit|
            release.add_entry(
              title: commit.subject,
              commit: commit,
              category: commit.trailers.fetch(@trailer),
              author: commit.author,
              merge_request: mrs[commit.id]
            )
          end
        end

      @branches.each do |branch|
        Gitlab::Changelog::Committer
          .new(@project, @user)
          .commit(release: release, file: @file, branch: branch, message: @message)
      end
    end

    def default_branch
      project.default_branch_or_master
    end
  end
end
