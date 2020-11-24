# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Importer
      class PullRequestMergeByImporter
        include Gitlab::Import::MergeRequestHelpers

        attr_reader :pull_request, :project, :client, :user_finder

        # pull_request - An instance of
        #                `Gitlab::GithubImport::Representation::PullRequest`.
        # project - An instance of `Project`
        # client - An instance of `Gitlab::GithubImport::Client`
        def initialize(pull_request, project, client)
          @pull_request = pull_request
          @project = project
          @client = client
          @user_finder = GithubImport::UserFinder.new(project, client)
        end

        def execute
          merge_request = project.merge_requests.find_by(iid: pull_request.number)
          metrics = merge_request.metrics || merge_request.build_metrics
          metrics.merged_by_id = user_finder(pull_request.merge_by)
          metrics.save
        end
      end
    end
  end
end
