# frozen_string_literal: true

return if Rails.env.production?

module Tooling
  class MergeRequestFailedRSpecRakeTask < RSpec::Core::RakeTask
    def run_task(verbose)
      if pattern.empty?
        puts "No failed rspec tests in the merge request."
        return
      end

      super
    end
  end
end

namespace :spec do
  desc 'GitLab | RSpec | Run unit tests'
  RSpec::Core::RakeTask.new(:unit, :rspec_opts) do |t, args|
    require_test_level
    t.pattern = Quality::TestLevel.new.pattern(:unit)
    t.rspec_opts = args[:rspec_opts]
  end

  desc 'GitLab | RSpec | Run integration tests'
  RSpec::Core::RakeTask.new(:integration, :rspec_opts) do |t, args|
    require_test_level
    t.pattern = Quality::TestLevel.new.pattern(:integration)
    t.rspec_opts = args[:rspec_opts]
  end

  desc 'GitLab | RSpec | Run system tests'
  RSpec::Core::RakeTask.new(:system, :rspec_opts) do |t, args|
    require_test_level
    t.pattern = Quality::TestLevel.new.pattern(:system)
    t.rspec_opts = args[:rspec_opts]
  end

  desc 'GitLab | RSpec | Run merge request failed tests'
  Tooling::MergeRequestFailedRSpecRakeTask.new(:merge_request_failures, :rspec_opts) do |t, args|
    t.pattern = merge_request_rspec_failures
    t.rspec_opts = args[:rspec_opts]
  end

  desc 'Run the code examples in spec/requests/api'
  RSpec::Core::RakeTask.new(:api) do |t|
    t.pattern = 'spec/requests/api/**/*_spec.rb'
  end

  private

  def require_test_level
    require_relative '../../tooling/quality/test_level'
  end

  def get_branch_name_from_git
    `git branch --show-current`
  end

  def merge_request_rspec_failures
    require 'test_file_finder'

    project_path = 'gitlab-org/gitlab'
    merge_request_iid = 57998 # TODO: fetch MR IID from API based on local branch.

    tff = TestFileFinder::FileFinder.new
    tff.use TestFileFinder::MappingStrategies::GitlabMergeRequestRspecFailure.new(project_path: project_path, merge_request_iid: merge_request_iid)

    tff.test_files
  end
end
