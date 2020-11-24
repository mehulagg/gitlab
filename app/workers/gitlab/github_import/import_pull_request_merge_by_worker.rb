# frozen_string_literal: true

module Gitlab
  module GithubImport
    class ImportPullRequestMergeByWorker # rubocop:disable Scalability/IdempotentWorker
      include ObjectImporter

      def representation_class
        Gitlab::GithubImport::Representation::PullRequest
      end

      def importer_class
        Importer::PullRequestMergeByImporter
      end

      def counter_name
        :github_importer_imported_pull_requests_merged_by
      end

      def counter_description
        'The number of imported GitHub pull requests merged_by attributes'
      end
    end
  end
end
